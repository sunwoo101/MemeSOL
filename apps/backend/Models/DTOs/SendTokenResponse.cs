namespace Backend.Models.DTOs;

public record SendTokenResponse
{
    public required string Signature { get; init; }
}
