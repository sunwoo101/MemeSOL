namespace Backend.Models.DTOs;

public record SendTokenRequest
{
    public required string RecipientAddress { get; init; }
    public required decimal Amount { get; init; }
}
