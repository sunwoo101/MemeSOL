namespace Backend.Models.DTOs;

public record RegisterRequest : BaseRequest
{
    public required string Email { get; init; }
    public required string Password { get; init; }
}
