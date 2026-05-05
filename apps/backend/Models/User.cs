namespace Backend.Models;

/// <summary>
/// Represents a <c>User</c> in the app.
/// </summary>
public class User
{
    public Guid Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string WalletPublicKey { get; set; } = string.Empty;
    public string WalletPrivateKey { get; set; } = string.Empty;
    public string RefreshTokenHash { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<UserToken> UserTokens { get; set; } = [];
}
