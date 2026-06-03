using Backend.Data;
using Backend.Models;
using Backend.Models.DTOs;
using Microsoft.EntityFrameworkCore;
using Google.GenAI;
using Google.GenAI.Types;

namespace Backend.Services;

/// <summary>
/// Handles token creation logic.
/// </summary>
/// <param name="db">Injected database context.</param>
/// <param name="solanaService">Injected Solana service.</param>
public class TokensService(AppDbContext db, SolanaService solanaService, IConfiguration configuration)
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
        using var ms = new MemoryStream();

        if (!request.ImFeelingLucky && request.Image is null)
            throw new InvalidOperationException("Image is required unless 'I'm Feeling Lucky' is selected.");

        string imageContentType;

        if (request.Image is null)
        {
            var apiKey = configuration["GoogleApiKey"] ?? throw new InvalidOperationException("GoogleApiKey is not configured.");
            var client = new Client(apiKey: apiKey);

            var response = await client.Models.GenerateImagesAsync(
                model: "imagen-4.0-generate-001",
                prompt: $"Generate a fun meme coin logo for a token called '{request.Name}' ({request.Symbol}). Make it vibrant and crypto-themed.",
                config: new GenerateImagesConfig
                {
                    NumberOfImages = 1,
                    AspectRatio = "1:1",
                    OutputMimeType = "image/png",
                }
            );

            var imageBytes = response.GeneratedImages?.FirstOrDefault()?.Image?.ImageBytes;
            if (imageBytes is null or { Length: 0 })
                throw new Exception("Image generation failed: no image data returned.");

            await ms.WriteAsync(imageBytes);
            imageContentType = "image/png";
        }
        else
        {
            if (request.Image.Length > MaxImageBytes)
                throw new InvalidOperationException($"Image must be under {MaxImageBytes / 1024 / 1024} MB.");

            await request.Image.CopyToAsync(ms);
            imageContentType = request.Image.ContentType;
        }

        var imageData = ms.ToArray();

        var token = new Token
        {
            Id = Guid.NewGuid(),
            MintAddress = null,
            Name = request.Name,
            Symbol = request.Symbol,
            Supply = request.Supply,
            ImageData = imageData,
            ImageContentType = imageContentType,
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
        var rows = await db.Tokens
            .Where(t => t.Status == TokenStatus.Completed)
            .OrderByDescending(t => t.CreatedAt)
            .Select(t => new
            {
                t.Id,
                t.MintAddress,
                t.Name,
                t.Symbol,
                t.Price,
                t.PriceOpenDay,
                t.PriceUpdatedAt,
                t.CreatedAt
            })
            .ToListAsync();

        var results = new List<TokenListResponse>(rows.Count);
        foreach (var row in rows)
        {
            var (price, openDay, updatedAt, changed) = ComputeNewPrice(row.Price, row.PriceOpenDay, row.PriceUpdatedAt);
            if (changed)
                await db.Tokens.Where(t => t.Id == row.Id).ExecuteUpdateAsync(s => s
                    .SetProperty(t => t.Price, price)
                    .SetProperty(t => t.PriceOpenDay, openDay)
                    .SetProperty(t => t.PriceUpdatedAt, updatedAt));

            results.Add(new TokenListResponse
            {
                Id = row.Id,
                MintAddress = row.MintAddress!,
                Name = row.Name,
                Symbol = row.Symbol,
                ImgUrl = $"{baseUrl}/tokens/{row.Id}/image",
                Price = price,
                GainsPercent = openDay > 0 ? Math.Round((price - openDay) / openDay * 100, 2) : 0,
            });
        }
        return results;
    }

    public async Task<(byte[] Data, string ContentType)?> GetTokenImageAsync(Guid tokenId)
    {
        var token = await db.Tokens
            .Where(t => t.Id == tokenId)
            .Select(t => new { t.ImageData, t.ImageContentType })
            .FirstOrDefaultAsync();

        return token is null ? null : (token.ImageData, token.ImageContentType);
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
