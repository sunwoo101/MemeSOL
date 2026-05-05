namespace Backend.Models.DTOs;

public record WalletBalancesResponse
{
    public required decimal TotalValue { get; init; }
    public required decimal GainLoss { get; init; }
    public required decimal GainLossPercent { get; init; }
}
