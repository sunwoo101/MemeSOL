using Backend.Data;
using Backend.Models;
using Backend.Models.DTOs;

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
}
