# Memecoin Wallet App — Todo

## Backend
- [x] Set up database models (User, Token)
- [x] Run initial EF Core migration
- [x] `POST /auth/apple` — verify Apple identity token, return JWT + public wallet address
- [ ] `POST /tokens` — create SPL token on Solana devnet
- [ ] `GET /tokens` — list all tokens on the platform
- [ ] `GET /tokens/{mintAddress}` — get token details
- [ ] `GET /wallet/tokens` — list tokens in user's wallet
- [ ] `POST /wallet/tokens/{mintAddress}` — add a token to user's wallet
- [ ] `DELETE /wallet/tokens/{mintAddress}` — remove a token from user's wallet
- [ ] `GET /wallet/balances` — get user's balance for all wallet tokens
- [ ] `POST /tokens/{mintAddress}/send` — transfer tokens to another address
- [ ] `GET /wallet/{mintAddress}/transactions` — transaction history for a specific token
- [ ] Fund backend devnet wallet with airdropped SOL

## iOS
- [ ] Apple Sign In flow (`ASAuthorizationAppleIDProvider`)
- [ ] JWT storage in Keychain
- [ ] API client (networking layer using `URLSession`)
- [ ] Portfolio screen — list holdings with live prices and overall balance with gains/losses for today
- [ ] Create token screen — name, symbol, supply
- [ ] Token detail screen — balance, transactions
- [ ] Send screen — recipient address + amount
- [ ] Receive screen — display public wallet address + QR code

## Design
- [ ] Agree on UI style/theme as a team
- [ ] Design main screens (portfolio, create token, token detail, send, receive)
