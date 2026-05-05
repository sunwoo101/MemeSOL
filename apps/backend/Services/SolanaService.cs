using Solnet.Programs;
using Solnet.Rpc;
using Solnet.Rpc.Builders;
using Solnet.Wallet;
using Solnet.Wallet.Bip39;

namespace Backend.Services;

/// <summary>
/// Handles interactions with the Solana blockchain.
/// </summary>
/// <param name="config">Injected configuration for accessing secrets.</param>
public class SolanaService(IConfiguration config)
{
    private const byte TokenDecimals = 9;

    /// <summary>
    /// Creates a new SPL token mint on Solana devnet and mints the initial supply
    /// to the server wallet's token account.
    /// </summary>
    /// <param name="supply">The initial token supply to mint.</param>
    /// <returns>The mint address and decimals of the created token.</returns>
    public async Task<(string MintAddress, byte Decimals)> CreateTokenAsync(ulong supply)
    {
        var client = ClientFactory.GetClient(Cluster.DevNet);

        var mnemonicString = config["Solana:ServerMnemonic"]
            ?? throw new InvalidOperationException("Solana:ServerMnemonic not configured.");

        var wallet = new Wallet(new Mnemonic(mnemonicString));
        var payer = wallet.GetAccount(0);
        var mint = new Account();
        var tokenAccount = new Account();

        var mintRent = (await client.GetMinimumBalanceForRentExemptionAsync(TokenProgram.MintAccountDataSize)).Result;
        var tokenAccountRent = (await client.GetMinimumBalanceForRentExemptionAsync(TokenProgram.TokenAccountDataSize)).Result;
        var blockhash = (await client.GetLatestBlockHashAsync()).Result.Value.Blockhash;

        var tx = new TransactionBuilder()
            .SetRecentBlockHash(blockhash)
            .SetFeePayer(payer.PublicKey)
            .AddInstruction(SystemProgram.CreateAccount(
                payer.PublicKey, mint.PublicKey, mintRent,
                TokenProgram.MintAccountDataSize, TokenProgram.ProgramIdKey))
            .AddInstruction(TokenProgram.InitializeMint(
                mint.PublicKey, TokenDecimals, payer.PublicKey, payer.PublicKey))
            .AddInstruction(SystemProgram.CreateAccount(
                payer.PublicKey, tokenAccount.PublicKey, tokenAccountRent,
                TokenProgram.TokenAccountDataSize, TokenProgram.ProgramIdKey))
            .AddInstruction(TokenProgram.InitializeAccount(
                tokenAccount.PublicKey, mint.PublicKey, payer.PublicKey))
            .AddInstruction(TokenProgram.MintTo(
                mint.PublicKey, tokenAccount.PublicKey, supply, payer.PublicKey))
            .Build([payer, mint, tokenAccount]);

        var result = await client.SendTransactionAsync(tx);
        if (!result.WasRequestSuccessfullyHandled)
            throw new InvalidOperationException($"Failed to create token: {result.Reason}");

        return (mint.PublicKey.Key, TokenDecimals);
    }
}
