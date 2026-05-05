using Backend.Data;
using Backend.Models;
using Backend.Models.DTOs;
using Microsoft.EntityFrameworkCore;

namespace Backend.Services;

/// <summary>
/// Handles token creation logic.
/// </summary>
/// <param name="db">Injected database context.</param>
/// <param name="solanaService">Injected Solana service.</param>
public class TokensService(AppDbContext db, SolanaService solanaService)
{
    /// <summary>
    /// Creates a new token on Solana devnet and saves it to the database.
    /// Saves a Pending record first so partial failures are recoverable.
    /// </summary>
    /// <param name="request">The token creation request.</param>
    /// <param name="userId">The ID of the authenticated user creating the token.</param>
    private const int MaxImageBytes = 5 * 1024 * 1024; // 5 MB

    public async Task<TokenResponse> CreateTokenAsync(CreateTokenRequest request, Guid userId)
    {
        if (request.Image.Length > MaxImageBytes)
            throw new InvalidOperationException($"Image must be under {MaxImageBytes / 1024 / 1024} MB.");

        using var ms = new MemoryStream();
        await request.Image.CopyToAsync(ms);
        var imageData = ms.ToArray();

        var token = new Token
        {
            Id = Guid.NewGuid(),
            MintAddress = null,
            Name = request.Name,
            Symbol = request.Symbol,
            Supply = request.Supply,
            ImageData = imageData,
            ImageContentType = request.Image.ContentType,
            CreatedByUserId = userId,
            Status = TokenStatus.Pending,
        };

        db.Tokens.Add(token);
        await db.SaveChangesAsync();

        try
        {
            var (mintAddress, decimals) = await solanaService.CreateTokenAsync(request.Supply);
            token.MintAddress = mintAddress;
            token.Decimals = decimals;
            token.Status = TokenStatus.Completed;
            db.UserTokens.Add(new UserToken { UserId = userId, TokenId = token.Id });
        }
        catch
        {
            token.Status = TokenStatus.Failed;
            await db.SaveChangesAsync();
            throw;
        }

        await db.SaveChangesAsync();

        return new TokenResponse
        {
            Id = token.Id,
            MintAddress = token.MintAddress!,
            Name = token.Name,
            Symbol = token.Symbol,
            Supply = token.Supply,
            Decimals = token.Decimals,
            CreatedAt = token.CreatedAt,
        };
    }

    public async Task<List<TokenListResponse>> GetAllTokensAsync(string baseUrl)
    {
        var tokens = await db.Tokens
            .Where(t => t.Status == TokenStatus.Completed)
            .OrderByDescending(t => t.CreatedAt)
            .ToListAsync();

        foreach (var token in tokens)
            UpdatePrice(token);

        await db.SaveChangesAsync();

        return tokens.Select(t => new TokenListResponse
        {
            Id = t.Id,
            MintAddress = t.MintAddress!,
            Name = t.Name,
            Symbol = t.Symbol,
            ImgUrl = $"{baseUrl}/tokens/{t.Id}/image",
            Price = t.Price,
            GainsPercent = t.PriceOpenDay > 0
                ? Math.Round((t.Price - t.PriceOpenDay) / t.PriceOpenDay * 100, 2)
                : 0,
        }).ToList();
    }

    public async Task<List<WalletTokenResponse>> GetWalletTokensAsync(Guid userId, string baseUrl)
    {
        var user = await db.Users.FindAsync(userId)
            ?? throw new InvalidOperationException("User not found.");

        var tokens = await db.UserTokens
            .Where(ut => ut.UserId == userId)
            .Select(ut => ut.Token)
            .Where(t => t.Status == TokenStatus.Completed)
            .OrderByDescending(t => t.CreatedAt)
            .ToListAsync();

        foreach (var token in tokens)
            UpdatePrice(token);

        await db.SaveChangesAsync();

        var balances = await Task.WhenAll(
            tokens.Select(t => solanaService.GetTokenBalanceAsync(user.WalletPublicKey, t.MintAddress!))
        );

        return tokens.Select((t, i) => new WalletTokenResponse
        {
            Id = t.Id,
            MintAddress = t.MintAddress!,
            Name = t.Name,
            Symbol = t.Symbol,
            ImgUrl = $"{baseUrl}/tokens/{t.Id}/image",
            Price = t.Price,
            Balance = balances[i],
            GainsPercent = t.PriceOpenDay > 0
                ? Math.Round((t.Price - t.PriceOpenDay) / t.PriceOpenDay * 100, 2)
                : 0,
        }).ToList();
    }

    public async Task<(byte[] Data, string ContentType)?> GetTokenImageAsync(Guid tokenId)
    {
        var token = await db.Tokens
            .Where(t => t.Id == tokenId)
            .Select(t => new { t.ImageData, t.ImageContentType })
            .FirstOrDefaultAsync();

        return token is null ? null : (token.ImageData, token.ImageContentType);
    }

    private static void UpdatePrice(Token token)
    {
        var now = DateTime.UtcNow;

        if (token.PriceUpdatedAt is null)
        {
            token.Price = (decimal)(Random.Shared.NextDouble() * 190 + 10);
            token.PriceOpenDay = token.Price;
            token.PriceUpdatedAt = now;
            return;
        }

        if (token.PriceUpdatedAt.Value.Date < now.Date)
            token.PriceOpenDay = token.Price;

        if ((now - token.PriceUpdatedAt.Value).TotalHours >= 1)
        {
            var delta = (decimal)(Random.Shared.NextDouble() * 0.10 - 0.05);
            token.Price = Math.Max(0.001m, token.Price * (1 + delta));
            token.PriceUpdatedAt = now;
        }
    }
}
