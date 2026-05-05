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
public class TokensController(TokensService tokensService, WalletService walletService) : ControllerBase
{
    [HttpGet("{id:guid}/image")]
    [AllowAnonymous]
    public async Task<IActionResult> GetTokenImage(Guid id)
    {
        var image = await tokensService.GetTokenImageAsync(id);
        if (image is null) return NotFound();
        return File(image.Value.Data, image.Value.ContentType);
    }

    [HttpGet]
    public async Task<ActionResult<List<TokenListResponse>>> GetAllTokens()
    {
        var baseUrl = $"{Request.Scheme}://{Request.Host}/api";
        var result = await tokensService.GetAllTokensAsync(baseUrl);
        return Ok(result);
    }

    [HttpPost("{mintAddress}/send")]
    public async Task<ActionResult<SendTokenResponse>> SendToken(string mintAddress, [FromBody] SendTokenRequest request)
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (userIdClaim is null || !Guid.TryParse(userIdClaim, out var userId))
            return Unauthorized();

        var result = await walletService.SendTokenAsync(userId, mintAddress, request);
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
