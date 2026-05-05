namespace Backend.Models.DTOs;

public record AppleSignInRequest : BaseRequest
{
    public required string IdentityToken { get; init; }
}
