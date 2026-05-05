using System.ComponentModel.DataAnnotations;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Backend.Data;
using Backend.Models;
using Backend.Models.DTOs;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Backend.Utilities;
using Solnet.Wallet;
using Solnet.Wallet.Bip39;

namespace Backend.Services;

/// <summary>
/// Handles auth logic.
/// </summary>
/// <param name="db">Injected database context.</param>
/// <param name="config">Injected configuration for accessing secrets.</param>
/// <param name="passwordHasher">Injected password hasher.</param>
public class AuthService(AppDbContext db, IConfiguration config, PasswordHasher<User> passwordHasher)
{
    private readonly PasswordHasher<User> _passwordHasher = passwordHasher;

    /// <summary>
    /// Registers a new user with email and password.
    /// </summary>
    public async Task<AuthResponse> RegisterAsync(string email, string password)
    {
        email = email.ToLower().Trim();

        if (!new EmailAddressAttribute().IsValid(email))
            throw new InvalidOperationException("Invalid email address.");

        if (password.Length < 8)
            throw new InvalidOperationException("Password must be at least 8 characters.");

        if (!password.Any(char.IsUpper))
            throw new InvalidOperationException("Password must contain at least one uppercase letter.");

        if (!password.Any(char.IsDigit))
            throw new InvalidOperationException("Password must contain at least one digit.");

        if (password.All(char.IsAsciiLetterOrDigit))
            throw new InvalidOperationException("Password must contain at least one special character.");

        if (await db.Users.AnyAsync(u => u.Email == email))
            throw new InvalidOperationException("Email already in use.");

        var wallet = GenerateSolanaWallet();
        var rawRefreshToken = GenerateRefreshToken();

        var user = new User
        {
            Id = Guid.NewGuid(),
            Email = email,
            WalletPublicKey = wallet.PublicKey,
            WalletPrivateKey = wallet.PrivateKey,
            RefreshTokenHash = HashUtils.Hash(rawRefreshToken),
        };
        user.PasswordHash = _passwordHasher.HashPassword(user, password);

        db.Users.Add(user);

        try
        {
            await db.SaveChangesAsync();
        }
        catch (DbUpdateException)
        {
            throw new InvalidOperationException("Email already in use.");
        }

        return new AuthResponse
        {
            AccessToken = GenerateJwt(user),
            WalletPublicKey = user.WalletPublicKey,
            RefreshToken = rawRefreshToken,
        };
    }

    /// <summary>
    /// Authenticates an existing user with email and password.
    /// </summary>
    public async Task<AuthResponse> LoginAsync(string email, string password)
    {
        email = email.ToLower().Trim();

        var user = await db.Users.FirstOrDefaultAsync(u => u.Email == email)
            ?? throw new UnauthorizedAccessException("Invalid email or password.");

        var verifyResult = _passwordHasher.VerifyHashedPassword(user, user.PasswordHash, password);
        if (verifyResult == PasswordVerificationResult.Failed)
            throw new UnauthorizedAccessException("Invalid email or password.");

        var rawRefreshToken = GenerateRefreshToken();
        user.RefreshTokenHash = HashUtils.Hash(rawRefreshToken);

        if (verifyResult == PasswordVerificationResult.SuccessRehashNeeded)
            user.PasswordHash = _passwordHasher.HashPassword(user, password);

        await db.SaveChangesAsync();

        return new AuthResponse
        {
            AccessToken = GenerateJwt(user),
            WalletPublicKey = user.WalletPublicKey,
            RefreshToken = rawRefreshToken,
        };
    }

    /// <summary>
    /// Validates a refresh token, issues a new JWT, and rotates the refresh token.
    /// </summary>
    public async Task<AuthResponse> RefreshAsync(string refreshToken)
    {
        var hash = HashUtils.Hash(refreshToken);
        var user = await db.Users.FirstOrDefaultAsync(u => u.RefreshTokenHash == hash)
            ?? throw new UnauthorizedAccessException("Invalid or expired refresh token.");

        var newRawRefreshToken = GenerateRefreshToken();
        user.RefreshTokenHash = HashUtils.Hash(newRawRefreshToken);

        try
        {
            await db.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            throw new UnauthorizedAccessException("Invalid or expired refresh token.");
        }

        return new AuthResponse
        {
            AccessToken = GenerateJwt(user),
            WalletPublicKey = user.WalletPublicKey,
            RefreshToken = newRawRefreshToken,
        };
    }

    /// <summary>
    /// Generates a JWT access token for the authenticated user, containing their user ID as a claim.
    /// The token is signed using a secret key from configuration and has an expiration time.
    /// </summary>
    /// <param name="user">The authenticated user for whom the JWT is being generated.</param>
    private string GenerateJwt(User user)
    {
        var secret = config["Jwt:Secret"]
            ?? throw new InvalidOperationException("Jwt:Secret not configured");
        var issuer = config["Jwt:Issuer"] ?? "backend";
        var audience = config["Jwt:Audience"] ?? "ios-app";
        var expiryMinutes = int.Parse(config["Jwt:ExpiryMinutes"] ?? "60");

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secret));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: [new Claim(ClaimTypes.NameIdentifier, user.Id.ToString())],
            expires: DateTime.UtcNow.AddMinutes(expiryMinutes),
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    /// <summary>
    /// Generates a new Solana wallet using the Solnet library.
    /// </summary>
    private static (string PublicKey, string PrivateKey) GenerateSolanaWallet()
    {
        var mnemonic = new Mnemonic(WordList.English, WordCount.TwentyFour);
        var wallet = new Wallet(mnemonic);
        var account = wallet.GetAccount(0);
        return (account.PublicKey.Key, account.PrivateKey.Key);
    }

    /// <summary>
    /// Generates a secure random refresh token as a base64 string.
    /// This token can be stored in the database and used to issue
    /// new access tokens when the current one expires.
    /// </summary>
    private static string GenerateRefreshToken()
    {
        var bytes = RandomNumberGenerator.GetBytes(64);
        return Convert.ToBase64String(bytes);
    }
}
