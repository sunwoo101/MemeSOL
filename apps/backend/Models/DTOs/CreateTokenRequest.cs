namespace Backend.Models.DTOs;

public class CreateTokenRequest
{
    public required string Name { get; set; }
    public required string Symbol { get; set; }
    public required ulong Supply { get; set; }
    public required IFormFile Image { get; set; }
}
