using Backend.Models.DTOs;
using Solnet.Rpc.Types;
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
    internal const byte TokenDecimals = 9;

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
    /// Transfers SPL tokens from the sender's ATA to the recipient's ATA.
    /// The server wallet acts as fee payer; the sender wallet signs as transfer authority.
    /// Creates the recipient's ATA if it does not already exist.
    /// </summary>
    public async Task<string> SendTokenAsync(
        string senderPublicKey, string senderPrivateKey,
        string mintAddress, string recipientPublicKey,
        ulong rawAmount)
    {
        if (rawAmount == 0)
            throw new ArgumentException("Transfer amount must be greater than zero.", nameof(rawAmount));

        var client = ClientFactory.GetClient(Cluster.DevNet);

        var mnemonicString = config["Solana:ServerMnemonic"]
            ?? throw new InvalidOperationException("Solana:ServerMnemonic not configured.");
        var serverWallet = new Wallet(new Mnemonic(mnemonicString));
        var feePayer = serverWallet.GetAccount(0);

        var senderPrivKey = new PrivateKey(senderPrivateKey);
        var senderAccount = new Account(senderPrivKey.KeyBytes, new PublicKey(senderPublicKey).KeyBytes);

        var mintPubKey = new PublicKey(mintAddress);
        var recipientPubKey = new PublicKey(recipientPublicKey);

        var senderAta = AssociatedTokenAccountProgram.DeriveAssociatedTokenAccount(senderAccount.PublicKey, mintPubKey);
        var recipientAta = AssociatedTokenAccountProgram.DeriveAssociatedTokenAccount(recipientPubKey, mintPubKey);

        var blockhashResponse = await client.GetLatestBlockHashAsync();
        if (!blockhashResponse.WasRequestSuccessfullyHandled || blockhashResponse.Result?.Value is null)
            throw new InvalidOperationException("Failed to fetch blockhash.");

        var txBuilder = new TransactionBuilder()
            .SetRecentBlockHash(blockhashResponse.Result.Value.Blockhash)
            .SetFeePayer(feePayer.PublicKey);

        var recipientAtaInfo = await client.GetAccountInfoAsync(recipientAta);
        if (!recipientAtaInfo.WasRequestSuccessfullyHandled)
            throw new InvalidOperationException("Failed to check recipient token account.");
        if (recipientAtaInfo.Result?.Value is null)
            txBuilder.AddInstruction(AssociatedTokenAccountProgram.CreateAssociatedTokenAccount(
                feePayer.PublicKey, recipientPubKey, mintPubKey));

        txBuilder.AddInstruction(TokenProgram.TransferChecked(
            senderAta, recipientAta, rawAmount, TokenDecimals, senderAccount.PublicKey, mintPubKey));

        var tx = txBuilder.Build(new List<Account> { feePayer, senderAccount });
        var result = await client.SendTransactionAsync(tx);
        if (!result.WasRequestSuccessfullyHandled)
            throw new InvalidOperationException($"Transfer failed: {result.Reason}");
        if (string.IsNullOrEmpty(result.Result))
            throw new InvalidOperationException("Transfer submitted but returned no signature.");

        await WaitForConfirmationAsync(client, result.Result);
        return result.Result;
    }

    /// <summary>
    /// Returns the most recent raw transaction records for the given wallet's ATA for a token.
    /// </summary>
    public async Task<List<(string Signature, DateTime Timestamp, bool Success, decimal? Amount, string? TransactionType)>> GetTokenTransactionsAsync(
        string walletPublicKey, string mintAddress, int limit = 20)
    {
        if (limit < 1 || limit > 1000)
            throw new ArgumentOutOfRangeException(nameof(limit), "Limit must be between 1 and 1000.");

        var client = ClientFactory.GetClient(Cluster.DevNet);
        var ata = AssociatedTokenAccountProgram.DeriveAssociatedTokenAccount(
            new PublicKey(walletPublicKey),
            new PublicKey(mintAddress)
        );
        var ataKey = ata.Key;

        var response = await client.GetSignaturesForAddressAsync(ataKey, (ulong)limit);
        if (!response.WasRequestSuccessfullyHandled || response.Result is null)
            throw new InvalidOperationException(
                $"Failed to fetch transactions for wallet {walletPublicKey}, mint {mintAddress}: {response.RawRpcResponse}");

        var detailTasks = response.Result
            .Select(s => client.GetTransactionAsync(s.Signature, Commitment.Confirmed))
            .ToList();
        var details = await Task.WhenAll(detailTasks);

        return response.Result.Select((s, i) =>
        {
            var timestamp = s.BlockTime.HasValue
                ? DateTimeOffset.FromUnixTimeSeconds((long)s.BlockTime.Value).UtcDateTime
                : DateTime.UtcNow;

            decimal? amount = null;
            string? txType = null;

            try
            {
                var tx = details[i];
                if (tx.WasRequestSuccessfullyHandled
                    && tx.Result?.Transaction?.Message?.AccountKeys is { } keys
                    && tx.Result.Meta?.PreTokenBalances is { } pre
                    && tx.Result.Meta?.PostTokenBalances is { } post)
                {
                    var ataIndex = Array.IndexOf(keys, ataKey);
                    if (ataIndex >= 0)
                    {
                        var preAmt = pre.FirstOrDefault(b => b.AccountIndex == ataIndex)?.UiTokenAmount.AmountUlong ?? 0UL;
                        var postAmt = post.FirstOrDefault(b => b.AccountIndex == ataIndex)?.UiTokenAmount.AmountUlong ?? 0UL;
                        var delta = (long)postAmt - (long)preAmt;
                        if (delta != 0)
                        {
                            amount = Math.Abs(delta) / (decimal)Math.Pow(10, TokenDecimals);
                            txType = delta > 0 ? "received" : "sent";
                        }
                    }
                }
            }
            catch { }

            return (
                Signature: s.Signature,
                Timestamp: timestamp,
                Success: s.Error is null,
                Amount: amount,
                TransactionType: txType
            );
        }).ToList();
    }

    /// <summary>
    /// Mints tokens to the user's ATA using the server wallet as mint authority.
    /// Creates the ATA if it does not already exist.
    /// </summary>
    public async Task<string> MintTokensAsync(string userWalletPublicKey, string mintAddress, ulong rawAmount)
    {
        if (rawAmount == 0)
            throw new ArgumentException("Mint amount must be greater than zero.", nameof(rawAmount));

        var client = ClientFactory.GetClient(Cluster.DevNet);

        var mnemonicString = config["Solana:ServerMnemonic"]
            ?? throw new InvalidOperationException("Solana:ServerMnemonic not configured.");
        var serverWallet = new Wallet(new Mnemonic(mnemonicString));
        var mintAuthority = serverWallet.GetAccount(0);

        var mintPubKey = new PublicKey(mintAddress);
        var userPubKey = new PublicKey(userWalletPublicKey);
        var userAta = AssociatedTokenAccountProgram.DeriveAssociatedTokenAccount(userPubKey, mintPubKey);

        var blockhashResponse = await client.GetLatestBlockHashAsync();
        if (!blockhashResponse.WasRequestSuccessfullyHandled || blockhashResponse.Result?.Value is null)
            throw new InvalidOperationException("Failed to fetch blockhash.");

        var txBuilder = new TransactionBuilder()
            .SetRecentBlockHash(blockhashResponse.Result.Value.Blockhash)
            .SetFeePayer(mintAuthority.PublicKey);

        var ataInfo = await client.GetAccountInfoAsync(userAta);
        if (!ataInfo.WasRequestSuccessfullyHandled)
            throw new InvalidOperationException("Failed to check user token account.");
        if (ataInfo.Result?.Value is null)
            txBuilder.AddInstruction(AssociatedTokenAccountProgram.CreateAssociatedTokenAccount(
                mintAuthority.PublicKey, userPubKey, mintPubKey));

        txBuilder.AddInstruction(TokenProgram.MintTo(mintPubKey, userAta, rawAmount, mintAuthority.PublicKey));

        var tx = txBuilder.Build(mintAuthority);
        var result = await client.SendTransactionAsync(tx);
        if (!result.WasRequestSuccessfullyHandled)
            throw new InvalidOperationException($"Mint failed: {result.Reason}");
        if (string.IsNullOrEmpty(result.Result))
            throw new InvalidOperationException("Mint submitted but returned no signature.");

        await WaitForConfirmationAsync(client, result.Result);
        return result.Result;
    }

    /// <summary>
    /// Returns the human-readable token balance for the given wallet and mint.
    /// Returns 0 if the Associated Token Account doesn't exist yet.
    /// </summary>
    public async Task<decimal> GetTokenBalanceAsync(string walletPublicKey, string mintAddress)
    {
        try
        {
            var client = ClientFactory.GetClient(Cluster.DevNet);
            var ata = AssociatedTokenAccountProgram.DeriveAssociatedTokenAccount(
                new PublicKey(walletPublicKey),
                new PublicKey(mintAddress)
            );

            var response = await client.GetTokenAccountBalanceAsync(ata);
            if (!response.WasRequestSuccessfullyHandled || response.Result?.Value is null)
                return 0m;

            var raw = response.Result.Value.AmountUlong;
            var decimals = response.Result.Value.Decimals;
            return (decimal)raw / (decimal)Math.Pow(10, decimals);
        }
        catch
        {
            return 0m;
        }
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
