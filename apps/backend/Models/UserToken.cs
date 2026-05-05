namespace Backend.Models;

/// <summary>
/// Represents <c>Token</c>s on the Solana blockchain that <c>User</c>s have added to their wallet.
/// </summary>
public class UserToken
{
    public Guid UserId { get; set; }
    public User User { get; set; } = null!;
    public Guid TokenId { get; set; }
    public Token Token { get; set; } = null!;
    public DateTime AddedAt { get; set; } = DateTime.UtcNow;
}
