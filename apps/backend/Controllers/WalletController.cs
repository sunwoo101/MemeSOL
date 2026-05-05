using System.Security.Claims;
using Backend.Models.DTOs;
using Backend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class WalletController(WalletService walletService) : ControllerBase
{
    [HttpGet("tokens")]
    public async Task<ActionResult<List<WalletTokenResponse>>> GetWalletTokens()
    {
        var userId = GetUserId();
        if (userId is null) return Unauthorized();

        var baseUrl = $"{Request.Scheme}://{Request.Host}/api";
        return Ok(await walletService.GetWalletTokensAsync(userId.Value, baseUrl));
    }

    [HttpPost("tokens/{mintAddress}")]
    public async Task<IActionResult> AddWalletToken(string mintAddress)
    {
        var userId = GetUserId();
        if (userId is null) return Unauthorized();

        await walletService.AddWalletTokenAsync(userId.Value, mintAddress);
        return StatusCode(StatusCodes.Status201Created);
    }

    [HttpDelete("tokens/{mintAddress}")]
    public async Task<IActionResult> RemoveWalletToken(string mintAddress)
    {
        var userId = GetUserId();
        if (userId is null) return Unauthorized();

        await walletService.RemoveWalletTokenAsync(userId.Value, mintAddress);
        return NoContent();
    }

    [HttpGet("balance")]
    public async Task<ActionResult<WalletBalancesResponse>> GetWalletBalance()
    {
        var userId = GetUserId();
        if (userId is null) return Unauthorized();

        return Ok(await walletService.GetWalletBalanceAsync(userId.Value));
    }

    private Guid? GetUserId()
    {
        var claim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return claim is not null && Guid.TryParse(claim, out var id) ? id : null;
    }
}
