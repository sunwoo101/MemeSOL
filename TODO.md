# Memecoin Wallet App — Todo

## Backend
- [x] Set up database models (User, Token)
- [x] Run initial EF Core migration
- [x] `POST /auth/register` — create wallet and return JWT, refresh token + public wallet address
- [x] `POST /auth/login` — validate login and return JWT, refresh token + public wallet address
- [x] `POST /tokens` — create SPL token on Solana devnet
- [x] `GET /tokens` — list all tokens on the platform
- ~~`GET /tokens/{mintAddress}` — get token details~~
- [x] `GET /wallet/tokens` — list tokens in user's wallet
- [x] `POST /wallet/tokens/{mintAddress}` — add a token to user's wallet
- [x] `DELETE /wallet/tokens/{mintAddress}` — remove a token from user's wallet
- [x] `GET /wallet/balance` — get user's total portfolio value
- [x] `POST /tokens/{mintAddress}/send` — transfer tokens to another address
- [x] `GET /wallet/{mintAddress}/transactions` — transaction history for a specific token
- [x] Fund backend devnet wallet with airdropped SOL

## iOS
- [ ] Apple Sign In flow (`ASAuthorizationAppleIDProvider`)
- [x] JWT storage in Keychain
- [x] API client (networking layer using `URLSession`)
- [ ] Portfolio screen — list holdings with live prices and overall balance with gains/losses for today
- [ ] Create token screen — name, symbol, supply
- [ ] Token detail screen — balance, transactions
- [ ] Send screen — recipient address + amount
- [ ] Receive screen — display public wallet address + QR code

## Design
- [ ] Agree on UI style/theme as a team
- [ ] Design main screens (portfolio, create token, token detail, send, receive)
