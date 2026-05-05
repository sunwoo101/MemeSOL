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

    public async Task<SendTokenResponse> SendTokenAsync(Guid userId, string mintAddress, SendTokenRequest request)
    {
        var user = await db.Users.FindAsync(userId)
            ?? throw new InvalidOperationException("User not found.");

        var token = await db.Tokens
            .Where(t => t.MintAddress == mintAddress && t.Status == TokenStatus.Completed)
            .Select(t => new { t.Decimals })
            .FirstOrDefaultAsync()
            ?? throw new KeyNotFoundException("Token not found.");

        if (request.Amount <= 0)
            throw new InvalidOperationException("Amount must be greater than zero.");

        var scaledAmount = request.Amount * (decimal)Math.Pow(10, token.Decimals);
        if (scaledAmount != Math.Floor(scaledAmount))
            throw new InvalidOperationException($"Amount exceeds the precision of this token ({token.Decimals} decimal places).");
        if (scaledAmount > ulong.MaxValue)
            throw new InvalidOperationException("Amount is too large.");

        var rawAmount = (ulong)scaledAmount;

        var signature = await solanaService.SendTokenAsync(
            user.WalletPublicKey, user.WalletPrivateKey,
            mintAddress, request.RecipientAddress,
            rawAmount, token.Decimals);

        return new SendTokenResponse { Signature = signature };
    }

    public async Task<List<TransactionHistoryResponse>> GetTransactionsAsync(Guid userId, string mintAddress, string baseUrl)
    {
        var user = await db.Users.FindAsync(userId)
            ?? throw new InvalidOperationException("User not found.");

        var token = await db.Tokens
            .Where(t => t.MintAddress == mintAddress && t.Status == TokenStatus.Completed)
            .Select(t => new { t.Id, t.Name, t.Symbol })
            .FirstOrDefaultAsync()
            ?? throw new KeyNotFoundException("Token not found.");

        var raw = await solanaService.GetTokenTransactionsAsync(user.WalletPublicKey, mintAddress);

        return raw.Select(r => new TransactionHistoryResponse
        {
            Signature = r.Signature,
            Timestamp = r.Timestamp,
            Success = r.Success,
            MintAddress = mintAddress,
            TokenName = token.Name,
            TokenSymbol = token.Symbol,
            ImgUrl = $"{baseUrl}/tokens/{token.Id}/image",
        }).ToList();
    }

    public async Task<List<TransactionHistoryResponse>> GetAllTransactionsAsync(Guid userId, string baseUrl)
    {
        var user = await db.Users.FindAsync(userId)
            ?? throw new InvalidOperationException("User not found.");

        var tokens = await db.UserTokens
            .Where(ut => ut.UserId == userId && ut.Token.Status == TokenStatus.Completed)
            .Select(ut => new { ut.Token.Id, ut.Token.MintAddress, ut.Token.Name, ut.Token.Symbol })
            .ToListAsync();

        var txLists = await Task.WhenAll(
            tokens.Select(t => solanaService.GetTokenTransactionsAsync(user.WalletPublicKey, t.MintAddress!))
        );

        return tokens
            .SelectMany((t, i) => txLists[i].Select(r => new TransactionHistoryResponse
            {
                Signature = r.Signature,
                Timestamp = r.Timestamp,
                Success = r.Success,
                MintAddress = t.MintAddress!,
                TokenName = t.Name,
                TokenSymbol = t.Symbol,
                ImgUrl = $"{baseUrl}/tokens/{t.Id}/image",
            }))
            .OrderByDescending(r => r.Timestamp)
            .ToList();
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
            .Select(ut => new { ut.Token.Id, ut.Token.MintAddress, ut.Token.Price, ut.Token.PriceOpenDay, ut.Token.PriceUpdatedAt })
            .ToListAsync();

        var balances = await Task.WhenAll(
            tokens.Select(t => solanaService.GetTokenBalanceAsync(user.WalletPublicKey, t.MintAddress!))
        );

        var totalValue = 0m;
        var openDayValue = 0m;

        for (var i = 0; i < tokens.Count; i++)
        {
            var t = tokens[i];
            var (price, openDay, updatedAt, changed) = ComputeNewPrice(t.Price, t.PriceOpenDay, t.PriceUpdatedAt);
            if (changed)
                await db.Tokens.Where(x => x.Id == t.Id).ExecuteUpdateAsync(s => s
                    .SetProperty(x => x.Price, price)
                    .SetProperty(x => x.PriceOpenDay, openDay)
                    .SetProperty(x => x.PriceUpdatedAt, updatedAt));
            totalValue += price * balances[i];
            openDayValue += openDay * balances[i];
        }

        var gainLoss = totalValue - openDayValue;
        var gainLossPercent = openDayValue > 0 ? gainLoss / openDayValue * 100 : 0;

        return new WalletBalancesResponse
        {
            TotalValue = Math.Round(totalValue, 2),
            GainLoss = Math.Round(gainLoss, 2),
            GainLossPercent = Math.Round(gainLossPercent, 2),
        };
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
