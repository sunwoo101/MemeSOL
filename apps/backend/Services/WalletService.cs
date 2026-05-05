using Backend.Data;
using Backend.Models;
using Backend.Models.DTOs;
using Microsoft.EntityFrameworkCore;

namespace Backend.Services;

/// <summary>
/// Handles wallet operations: listing, adding, removing tokens, and computing portfolio value.
/// </summary>
/// <param name="db">Injected database context.</param>
/// <param name="solanaService">Injected Solana service.</param>
public class WalletService(AppDbContext db, SolanaService solanaService)
{
    public async Task<List<WalletTokenResponse>> GetWalletTokensAsync(Guid userId, string baseUrl)
    {
        var user = await db.Users.FindAsync(userId)
            ?? throw new InvalidOperationException("User not found.");

        var rows = await db.UserTokens
            .Where(ut => ut.UserId == userId && ut.Token.Status == TokenStatus.Completed)
            .OrderByDescending(ut => ut.Token.CreatedAt)
            .Select(ut => new {
                ut.Token.Id, ut.Token.MintAddress, ut.Token.Name, ut.Token.Symbol,
                ut.Token.Price, ut.Token.PriceOpenDay, ut.Token.PriceUpdatedAt, ut.Token.CreatedAt
            })
            .ToListAsync();

        var balances = await Task.WhenAll(
            rows.Select(r => solanaService.GetTokenBalanceAsync(user.WalletPublicKey, r.MintAddress!))
        );

        var results = new List<WalletTokenResponse>(rows.Count);
        for (var i = 0; i < rows.Count; i++)
        {
            var row = rows[i];
            var (price, openDay, updatedAt, changed) = ComputeNewPrice(row.Price, row.PriceOpenDay, row.PriceUpdatedAt);
            if (changed)
                await db.Tokens.Where(t => t.Id == row.Id).ExecuteUpdateAsync(s => s
                    .SetProperty(t => t.Price, price)
                    .SetProperty(t => t.PriceOpenDay, openDay)
                    .SetProperty(t => t.PriceUpdatedAt, updatedAt));

            results.Add(new WalletTokenResponse
            {
                Id = row.Id,
                MintAddress = row.MintAddress!,
                Name = row.Name,
                Symbol = row.Symbol,
                ImgUrl = $"{baseUrl}/tokens/{row.Id}/image",
                Price = price,
                Balance = balances[i],
                GainsPercent = openDay > 0 ? Math.Round((price - openDay) / openDay * 100, 2) : 0,
            });
        }
        return results;
    }

    public async Task AddWalletTokenAsync(Guid userId, string mintAddress)
    {
        var token = await db.Tokens
            .Where(t => t.MintAddress == mintAddress && t.Status == TokenStatus.Completed)
            .Select(t => new { t.Id })
            .FirstOrDefaultAsync()
            ?? throw new KeyNotFoundException("Token not found.");

        var exists = await db.UserTokens.AnyAsync(ut => ut.UserId == userId && ut.TokenId == token.Id);
        if (exists)
            throw new InvalidOperationException("Token is already in your wallet.");

        db.UserTokens.Add(new UserToken { UserId = userId, TokenId = token.Id });
        try
        {
            await db.SaveChangesAsync();
        }
        catch (DbUpdateException)
        {
            throw new InvalidOperationException("Token is already in your wallet.");
        }
    }

    public async Task RemoveWalletTokenAsync(Guid userId, string mintAddress)
    {
        var userToken = await db.UserTokens
            .Where(ut => ut.UserId == userId && ut.Token.MintAddress == mintAddress)
            .FirstOrDefaultAsync()
            ?? throw new KeyNotFoundException("Token not found in wallet.");

        db.UserTokens.Remove(userToken);
        await db.SaveChangesAsync();
    }

    public async Task<WalletBalancesResponse> GetWalletBalanceAsync(Guid userId)
    {
        var user = await db.Users.FindAsync(userId)
            ?? throw new InvalidOperationException("User not found.");

        var tokens = await db.UserTokens
            .Where(ut => ut.UserId == userId && ut.Token.Status == TokenStatus.Completed)
            .Select(ut => new { ut.Token.MintAddress, ut.Token.Price, ut.Token.PriceOpenDay, ut.Token.PriceUpdatedAt })
            .ToListAsync();

        var balances = await Task.WhenAll(
            tokens.Select(t => solanaService.GetTokenBalanceAsync(user.WalletPublicKey, t.MintAddress!))
        );

        var totalValue = tokens
            .Select((t, i) => ComputeNewPrice(t.Price, t.PriceOpenDay, t.PriceUpdatedAt).Price * balances[i])
            .Sum();

        return new WalletBalancesResponse { TotalValue = Math.Round(totalValue, 2) };
    }

    private static (decimal Price, decimal PriceOpenDay, DateTime PriceUpdatedAt, bool Changed) ComputeNewPrice(
        decimal price, decimal openDay, DateTime? lastUpdated)
    {
        var now = DateTime.UtcNow;

        if (lastUpdated is null)
        {
            var initial = (decimal)(Random.Shared.NextDouble() * 190 + 10);
            return (initial, initial, now, true);
        }

        var newOpenDay = lastUpdated.Value.Date < now.Date ? price : openDay;

        if ((now - lastUpdated.Value).TotalHours >= 1)
        {
            var delta = (decimal)(Random.Shared.NextDouble() * 0.10 - 0.05);
            var newPrice = Math.Max(0.001m, price * (1 + delta));
            return (newPrice, newOpenDay, now, true);
        }

        return (price, newOpenDay, lastUpdated.Value, newOpenDay != openDay);
    }
}
