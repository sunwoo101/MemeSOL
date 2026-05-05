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
    /// </summary>
    /// <param name="request">The token creation request.</param>
    /// <param name="userId">The ID of the authenticated user creating the token.</param>
    public async Task<TokenResponse> CreateTokenAsync(CreateTokenRequest request, Guid userId)
    {
        using var ms = new MemoryStream();
        await request.Image.CopyToAsync(ms);
        var imageData = ms.ToArray();

        var (mintAddress, decimals) = await solanaService.CreateTokenAsync(request.Supply);

        var token = new Token
        {
            Id = Guid.NewGuid(),
            MintAddress = mintAddress,
            Name = request.Name,
            Symbol = request.Symbol,
            Supply = request.Supply,
            Decimals = decimals,
            ImageData = imageData,
            ImageContentType = request.Image.ContentType,
            CreatedByUserId = userId,
        };

        db.Tokens.Add(token);
        await db.SaveChangesAsync();

        return new TokenResponse
        {
            Id = token.Id,
            MintAddress = token.MintAddress,
            Name = token.Name,
            Symbol = token.Symbol,
            Supply = token.Supply,
            Decimals = token.Decimals,
            CreatedAt = token.CreatedAt,
        };
    }
}
