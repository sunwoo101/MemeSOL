namespace Backend.Models.DTOs;

public record TokenResponse
{
    public required Guid Id { get; init; }
    public required string MintAddress { get; init; }
    public required string Name { get; init; }
    public required string Symbol { get; init; }
    public required ulong Supply { get; init; }
    public required byte Decimals { get; init; }
    public required DateTime CreatedAt { get; init; }
}
