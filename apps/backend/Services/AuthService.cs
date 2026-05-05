using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Backend.Data;
using Backend.Models;
using Backend.Models.DTOs;
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
/// <param name="httpClientFactory">Injected HTTP client factory for fetching Apple's public keys.</param>
public class AuthService(AppDbContext db, IConfiguration config, IHttpClientFactory httpClientFactory)
{
    private const string AppleKeysUrl = "https://appleid.apple.com/auth/keys";

    /// <summary>
    /// Handles Apple Sign-In flow.
    /// </summary>
    /// <param name="identityToken">The JWT identity token received from the iOS app after Apple Sign-In.</param>
    public async Task<AuthResponse> AppleSignInAsync(string identityToken)
    {
        var appleUserId = await ValidateAppleTokenAsync(identityToken);

        var user = await db.Users.FirstOrDefaultAsync(u => u.AppleUserId == appleUserId);

        var rawRefreshToken = GenerateRefreshToken();

        if (user is null)
        {
            var wallet = GenerateSolanaWallet();
            user = new User
            {
                Id = Guid.NewGuid(),
                AppleUserId = appleUserId,
                WalletPublicKey = wallet.PublicKey,
                WalletPrivateKey = wallet.PrivateKey,
                RefreshTokenHash = HashUtils.Hash(rawRefreshToken),
            };
            db.Users.Add(user);
        }
        else
        {
            user.RefreshTokenHash = HashUtils.Hash(rawRefreshToken);
        }

        await db.SaveChangesAsync();

        return new AuthResponse
        {
            WalletPublicKey = user.WalletPublicKey,
            AccessToken = GenerateJwt(user),
            RefreshToken = rawRefreshToken,
        };
    }

    /// <summary>
    /// Validates the Apple identity token by fetching Apple's public keys and verifying the JWT signature and claims.
    /// </summary>
    /// <param name="identityToken">The JWT identity token from Apple Sign-In.</param>
    private async Task<string> ValidateAppleTokenAsync(string identityToken)
    {
        var client = httpClientFactory.CreateClient("Apple");
        var jwks = await client.GetStringAsync(AppleKeysUrl);
        var keySet = new JsonWebKeySet(jwks);

        var bundleId = config["Apple:BundleId"]
            ?? throw new InvalidOperationException("Apple:BundleId not configured");

        var validationParams = new TokenValidationParameters
        {
            ValidIssuer = "https://appleid.apple.com",
            ValidAudience = bundleId,
            IssuerSigningKeys = keySet.GetSigningKeys(),
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
        };

        var handler = new JwtSecurityTokenHandler();

        ClaimsPrincipal principal;
        try
        {
            principal = handler.ValidateToken(identityToken, validationParams, out _);
        }
        catch (Exception ex) when (ex is SecurityTokenException or ArgumentException)
        {
            throw new UnauthorizedAccessException("Invalid Apple identity token.");
        }

        return principal.FindFirst(ClaimTypes.NameIdentifier)?.Value
            ?? throw new UnauthorizedAccessException("Missing sub claim in Apple identity token.");
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
