namespace Backend.Models.DTOs;

public class CreateTokenRequest
{
    public required string Name { get; set; }
    public required string Symbol { get; set; }
    public required ulong Supply { get; set; }
    public IFormFile? Image { get; set; }
    public bool ImFeelingLucky { get; set; } = false; // If true, the backend will generate a random image instead of using the provided one.
}
