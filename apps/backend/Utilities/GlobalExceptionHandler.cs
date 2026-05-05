using Backend.Models.DTOs;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.IdentityModel.Tokens;

namespace Backend.Utilities;

/// <summary>
/// Handles unhandled exceptions globally and maps them to appropriate HTTP responses.
/// SecurityTokenException and UnauthorizedAccessException return 401, all others return 500.
/// </summary>
public class GlobalExceptionHandler : IExceptionHandler
{
    /// <summary>
    /// Maps the exception to a status code and writes a JSON error response.
    /// </summary>
    public async ValueTask<bool> TryHandleAsync(HttpContext context, Exception exception, CancellationToken cancellationToken)
    {
        var (statusCode, message) = exception switch
        {
            SecurityTokenException => (StatusCodes.Status401Unauthorized, exception.Message),
            UnauthorizedAccessException => (StatusCodes.Status401Unauthorized, exception.Message),
            InvalidOperationException => (StatusCodes.Status400BadRequest, exception.Message),
            _ => (StatusCodes.Status500InternalServerError, "An unexpected error occurred.")
        };

        context.Response.StatusCode = statusCode;
        await context.Response.WriteAsJsonAsync(new ErrorResponse(message), cancellationToken);
        return true;
    }
}
