namespace Backend.Models;

/// <summary>
/// Represents a token in the Solana blockchain.
/// </summary>
public class Token
{
    public Guid Id { get; set; }
    public string? MintAddress { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Symbol { get; set; } = string.Empty;
    public ulong Supply { get; set; }
    public byte Decimals { get; set; }
    public TokenStatus Status { get; set; } = TokenStatus.Pending;
    public byte[] ImageData { get; set; } = [];
    public string ImageContentType { get; set; } = string.Empty;
    public Guid CreatedByUserId { get; set; }
    public User CreatedBy { get; set; } = null!;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public decimal Price { get; set; }
    public decimal PriceOpenDay { get; set; }
    public DateTime? PriceUpdatedAt { get; set; }

    public ICollection<UserToken> UserTokens { get; set; } = [];
}
