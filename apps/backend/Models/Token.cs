namespace Backend.Models;

/// <summary>
/// Represents a token in the Solana blockchain.
/// </summary>
public class Token
{
    public Guid Id { get; set; }
    public string MintAddress { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Symbol { get; set; } = string.Empty;
    public ulong Supply { get; set; }
    public byte Decimals { get; set; }
    public byte[] ImageData { get; set; } = [];
    public string ImageContentType { get; set; } = string.Empty;
    public Guid CreatedByUserId { get; set; }
    public User CreatedBy { get; set; } = null!;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<UserToken> UserTokens { get; set; } = [];
}
