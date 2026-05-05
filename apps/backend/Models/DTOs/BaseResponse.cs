namespace Backend.Models.DTOs;

public record BaseResponse
{
    public required string AccessToken { get; init; }
}
