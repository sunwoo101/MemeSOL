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

        var rentResponse = await client.GetMinimumBalanceForRentExemptionAsync(TokenProgram.MintAccountDataSize);
        if (!rentResponse.WasRequestSuccessfullyHandled)
            throw new InvalidOperationException("Failed to fetch rent exemption from Solana RPC.");

        var blockhashResponse = await client.GetLatestBlockHashAsync();
        if (!blockhashResponse.WasRequestSuccessfullyHandled || blockhashResponse.Result?.Value is null)
            throw new InvalidOperationException("Failed to fetch latest blockhash from Solana RPC.");

        var tx = new TransactionBuilder()
            .SetRecentBlockHash(blockhashResponse.Result.Value.Blockhash)
            .SetFeePayer(payer.PublicKey)
            .AddInstruction(SystemProgram.CreateAccount(
                payer.PublicKey, mint.PublicKey, rentResponse.Result,
                TokenProgram.MintAccountDataSize, TokenProgram.ProgramIdKey))
            .AddInstruction(TokenProgram.InitializeMint(
                mint.PublicKey, TokenDecimals, payer.PublicKey, payer.PublicKey))
            .Build(new List<Account> { payer, mint });

        var result = await client.SendTransactionAsync(tx);
        if (!result.WasRequestSuccessfullyHandled)
            throw new InvalidOperationException($"Failed to create token: {result.Reason}");

        await WaitForConfirmationAsync(client, result.Result);

        return (mint.PublicKey.Key, TokenDecimals);
    }

    /// <summary>
    /// Polls until a transaction reaches confirmed status or throws if it times out.
    /// </summary>
    private static async Task WaitForConfirmationAsync(IRpcClient client, string signature, int maxAttempts = 30)
    {
        for (var i = 0; i < maxAttempts; i++)
        {
            await Task.Delay(1000);
            var statusResponse = await client.GetSignatureStatusesAsync(new List<string> { signature });
            var status = statusResponse.Result?.Value?[0];
            if (status is null) continue;
            if (status.Error is not null)
                throw new InvalidOperationException($"Transaction {signature} failed on-chain: {status.Error}");
            if (status.ConfirmationStatus is "confirmed" or "finalized") return;
        }
        throw new InvalidOperationException("Transaction was not confirmed in time.");
    }
}
