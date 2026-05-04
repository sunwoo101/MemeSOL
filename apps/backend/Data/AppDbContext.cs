using Backend.Models;
using Microsoft.EntityFrameworkCore;

namespace Backend.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<Token> Tokens => Set<Token>();
    public DbSet<UserToken> UserTokens => Set<UserToken>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<UserToken>()
            .HasKey(ut => new { ut.UserId, ut.TokenId });

        modelBuilder.Entity<User>()
            .HasIndex(u => u.AppleUserId)
            .IsUnique();

        modelBuilder.Entity<Token>()
            .HasIndex(t => t.MintAddress)
            .IsUnique();
    }
}
