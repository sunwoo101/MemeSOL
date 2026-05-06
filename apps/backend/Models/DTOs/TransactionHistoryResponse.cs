namespace Backend.Models.DTOs;

public record TransactionHistoryResponse
{
    public required string Signature { get; init; }
    public required DateTime Timestamp { get; init; }
    public required bool Success { get; init; }
    public required string MintAddress { get; init; }
    public required string TokenName { get; init; }
    public required string TokenSymbol { get; init; }
    public required string ImgUrl { get; init; }
    public decimal? Amount { get; init; }
    public string? TransactionType { get; init; }
}
