using Backend.Models.DTOs;
using Backend.Services;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers;

/// <summary>
/// Controller containing auth endpoints.
/// </summary>
/// <param name="authService">The auth service.</param>
[ApiController]
[Route("api/[controller]")]
public class AuthController(AuthService authService) : ControllerBase
{
    /// <summary>
    /// Endpoint for signing in with Apple.
    /// </summary>
    /// <param name="request">The request containing the Apple identity token.</param>
    [HttpPost("apple")]
    public async Task<ActionResult<AuthResponse>> AppleSignIn([FromBody] AppleSignInRequest request)
    {
        var result = await authService.AppleSignInAsync(request.IdentityToken);
        return Ok(result);
    }
}
