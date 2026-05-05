namespace Backend.Models.DTOs;

public record RefreshRequest
{
    public required string RefreshToken { get; init; }
}
