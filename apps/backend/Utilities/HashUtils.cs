using System.Security.Cryptography;
using System.Text;

namespace Backend.Utilities;

public static class HashUtils
{
    public static string Hash(string value)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(value));
        return Convert.ToHexString(bytes).ToLowerInvariant();
    }
}
