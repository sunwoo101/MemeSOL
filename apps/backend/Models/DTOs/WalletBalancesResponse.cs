namespace Backend.Models.DTOs;

public record WalletBalancesResponse
{
    public required decimal TotalValue { get; init; }
}
