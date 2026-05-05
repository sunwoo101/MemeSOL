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
    /// Creates a new SPL token mint on Solana devnet.
    /// Supply is tracked in the database; tokens are minted to users on distribution.
    /// </summary>
    /// <param name="supply">The intended token supply (stored in DB, not yet minted on-chain).</param>
    /// <returns>The mint address and decimals of the created token.</returns>
    public async Task<(string MintAddress, byte Decimals)> CreateTokenAsync(ulong supply)
    {
        var client = ClientFactory.GetClient(Cluster.DevNet);

        var mnemonicString = config["Solana:ServerMnemonic"]
            ?? throw new InvalidOperationException("Solana:ServerMnemonic not configured.");

        var wallet = new Wallet(new Mnemonic(mnemonicString));
        var payer = wallet.GetAccount(0);
        var mint = new Account();

        var mintRent = (await client.GetMinimumBalanceForRentExemptionAsync(TokenProgram.MintAccountDataSize)).Result;
        var blockhash = (await client.GetLatestBlockHashAsync()).Result.Value.Blockhash;

        var tx = new TransactionBuilder()
            .SetRecentBlockHash(blockhash)
            .SetFeePayer(payer.PublicKey)
            .AddInstruction(SystemProgram.CreateAccount(
                payer.PublicKey, mint.PublicKey, mintRent,
                TokenProgram.MintAccountDataSize, TokenProgram.ProgramIdKey))
            .AddInstruction(TokenProgram.InitializeMint(
                mint.PublicKey, TokenDecimals, payer.PublicKey, payer.PublicKey))
            .Build(new List<Account> { payer, mint });

        var result = await client.SendTransactionAsync(tx);
        if (!result.WasRequestSuccessfullyHandled)
            throw new InvalidOperationException($"Failed to create token: {result.Reason}");

        return (mint.PublicKey.Key, TokenDecimals);
    }
}
