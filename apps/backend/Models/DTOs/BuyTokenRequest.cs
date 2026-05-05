namespace Backend.Models.DTOs;

public record BuyTokenRequest
{
    public required decimal Amount { get; init; }
}
