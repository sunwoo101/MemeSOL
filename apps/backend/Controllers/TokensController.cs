using System.Security.Claims;
using Backend.Models.DTOs;
using Backend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers;

/// <summary>
/// Controller containing token endpoints.
/// </summary>
/// <param name="tokensService">The tokens service.</param>
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TokensController(TokensService tokensService) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<List<TokenResponse>>> GetAllTokens()
    {
        var result = await tokensService.GetAllTokensAsync();
        return Ok(result);
    }

    /// <summary>
    /// Creates a new token on Solana devnet.
    /// </summary>
    /// <param name="request">The token creation request containing name, symbol, supply, and image.</param>
    [HttpPost]
    [Consumes("multipart/form-data")]
    public async Task<ActionResult<TokenResponse>> CreateToken([FromForm] CreateTokenRequest request)
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (userIdClaim is null || !Guid.TryParse(userIdClaim, out var userId))
            return Unauthorized();

        var result = await tokensService.CreateTokenAsync(request, userId);
        return StatusCode(StatusCodes.Status201Created, result);
    }
}
