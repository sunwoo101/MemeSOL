namespace Backend.Models.DTOs;

public record WalletTokenResponse
{
    public required Guid Id { get; init; }
    public required string MintAddress { get; init; }
    public required string Name { get; init; }
    public required string Symbol { get; init; }
    public required string ImgUrl { get; init; }
    public required decimal Price { get; init; }
    public required decimal Balance { get; init; }
    public required decimal GainsPercent { get; init; }
}
