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
    /// Registers a new user with email and password.
    /// </summary>
    /// <param name="request">The request containing the user's email and password.</param>
    [HttpPost("register")]
    public async Task<ActionResult<AuthResponse>> Register([FromBody] RegisterRequest request)
    {
        var result = await authService.RegisterAsync(request.Email, request.Password);
        return Ok(result);
    }

    /// <summary>
    /// Authenticates an existing user with email and password.
    /// </summary>
    /// <param name="request">The request containing the user's email and password.</param>
    [HttpPost("login")]
    public async Task<ActionResult<AuthResponse>> Login([FromBody] LoginRequest request)
    {
        var result = await authService.LoginAsync(request.Email, request.Password);
        return Ok(result);
    }
}
