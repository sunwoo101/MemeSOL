namespace Backend.Models.DTOs;

public record LoginRequest : BaseRequest
{
    public required string Email { get; init; }
    public required string Password { get; init; }
}
