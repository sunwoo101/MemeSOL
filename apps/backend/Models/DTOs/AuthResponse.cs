namespace Backend.Models.DTOs;

public record AuthResponse : BaseResponse
{
    public required string WalletPublicKey { get; init; }
    public required string RefreshToken { get; init; }
}
