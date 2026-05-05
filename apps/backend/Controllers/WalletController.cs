using System.Security.Claims;
using Backend.Models.DTOs;
using Backend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class WalletController(TokensService tokensService) : ControllerBase
{
    [HttpGet("tokens")]
    public async Task<ActionResult<List<WalletTokenResponse>>> GetWalletTokens()
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (userIdClaim is null || !Guid.TryParse(userIdClaim, out var userId))
            return Unauthorized();

        var baseUrl = $"{Request.Scheme}://{Request.Host}/api";
        var result = await tokensService.GetWalletTokensAsync(userId, baseUrl);
        return Ok(result);
    }
}
