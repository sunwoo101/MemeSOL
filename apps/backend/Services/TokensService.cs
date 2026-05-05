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

    public async Task<List<TokenResponse>> GetAllTokensAsync()
    {
        return await db.Tokens
            .Where(t => t.Status == TokenStatus.Completed)
            .OrderByDescending(t => t.CreatedAt)
            .Select(t => new TokenResponse
            {
                Id = t.Id,
                MintAddress = t.MintAddress!,
                Name = t.Name,
                Symbol = t.Symbol,
                Supply = t.Supply,
                Decimals = t.Decimals,
                CreatedAt = t.CreatedAt,
            })
            .ToListAsync();
    }

    public async Task<List<TokenResponse>> GetWalletTokensAsync(Guid userId)
    {
        return await db.UserTokens
            .Where(ut => ut.UserId == userId)
            .Select(ut => ut.Token)
            .Where(t => t.Status == TokenStatus.Completed)
            .OrderByDescending(t => t.CreatedAt)
            .Select(t => new TokenResponse
            {
                Id = t.Id,
                MintAddress = t.MintAddress!,
                Name = t.Name,
                Symbol = t.Symbol,
                Supply = t.Supply,
                Decimals = t.Decimals,
                CreatedAt = t.CreatedAt,
            })
            .ToListAsync();
    }
}
