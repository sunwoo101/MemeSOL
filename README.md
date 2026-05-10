# MemeSOL 

A crypto wallet app that lets users manage tokens, send and receive transfers and track transaction history.

## Features
### Authentication

- Email and password registration with strong password validation (minimum 8 characters, at least one uppercase letter, one digit, one special character)
- Login with persistent session via Keychain
- Auto login on app relaunch using securely stored credentials

### Dashboard

- Portfolio balance display with gain/loss indicators
- Percentage change tracking
- Quick-action buttons for Send, Receive and Buy flows
- Token list with live data from the backend

### Tokens

- Browse all available tokens (AllCoinsView)
- View detailed token information including price, percent change and mint address (TokenDetailsView)
- Create new tokens (CreateTokenView)
- Purchase tokens via an in-app buy flow (BuyMenuView, BuyTokenView)

### Transactions

- Send tokens to any wallet address (SendView)
- Receive tokens via auto-generated QR code (ReceiveView)
- Scan QR codes to auto-fill recipient addresses (powered by CodeScanner)
- Full transaction history with status indicators (TransactionHistoryView)

### Onboarding

- First-launch onboarding flow introducing the app's core features

## Tech Stack

- **SwiftUI** (iOS 17+)
: UI framework

- **Observation framework** (`@Observable`, `@Bindable`)
: State management

- **async/await**
: Networking and concurrency

- **Keychain Services**
: Secure credential storage

- **CodeScanner 2.5.2**
: QR code scanning (Swift Package)

## Architecture

This project follows the **MVVM** (Model–View–ViewModel) pattern.

- **Models** are pure data types, such as `Token`. They have no logic, no dependencies and no SwiftUI imports — just `Codable` structs that map to API responses.

- **Views** are SwiftUI views grouped by feature. They contain only UI code: layout, styling and bindings to their view model. Views never make network calls or hold business logic.

- **ViewModels** are `@Observable` classes that hold state and business logic. There is one view model per screen. They expose inputs (bound to the UI), outputs (read by the UI) and intent methods (`login()`, `loadTokens()`, etc.) that the view calls.

- **Services** form the network and persistence layer. This includes API clients (`AuthAPI`, `TokenAPI`, `WalletAPI`), the session manager (`AuthSession`) and Keychain helpers. View models depend on services, never the other way around.

- **DesignSystem** holds shared layout constants, colors and typography. Anything visual that could be reused across screens lives here.

- The dependency flow is one-directional: `View → ViewModel → Service → Model`. Views never reach past their view model. This keeps every screen previewable, swappable and testable in isolation.

## Folder Structure 
```
App/
├── Main.swift              App entry point
│
├── Components/             Reusable UI building blocks
│   ├── ActionButton
│   ├── AllTransactionsView
│   └── TokenRow
│
├── DesignSystem/           Colors, typography, layout constants
│   ├── AppColors
│   ├── TypographyLayout
│   ├── BalanceLayout
│   ├── GainLossLayout
│   ├── OnboardingLayout
│   ├── SharedLayout
│   ├── TabBarLayout
│   ├── TokenLayout
│   ├── TransactionLayout
│   └── ActionButtonLayout
│
├── Models/                 Data types
│   └── Token
│
├── Resources/              Assets and app icon
│
├── Services/
│   ├── API/                Network clients
│   │   ├── APIClient
│   │   ├── AuthAPI
│   │   ├── TokenAPI
│   │   └── WalletAPI
│   └── Auth/               Session and credential management
│       ├── AuthSession
│       └── KeychainHelper
│
├── ViewModels/             Grouped by feature
│   ├── Authentication/     (LoginViewModel, RegisterViewModel)
│   ├── Dashboard/          (DashboardViewModel)
│   ├── Tokens/             (BuyViewModel, CreateTokenViewModel, TokenDetailsViewModel)
│   └── Transactions/       (SendViewModel, ReceiveViewModel)
│
├── Views/                  Grouped by feature
│   ├── Authentication/     (LoginView, RegisterView)
│   ├── Dashboard/          (ContentView, DashboardView)
│   ├── Onboarding/         (OnboardingView)
│   ├── Tokens/             (AllCoinsView, BuyMenuView, BuyTokenView,
│   │                        CreateTokenView, TokenDetailsView)
│   └── Transactions/       (SendView, ReceiveView, TransactionHistoryView)
│
└── TestViews/              Dev-only testing screens
```
## Getting Started
Requirements

- macOS with Xcode 16 or later iOS 17+ deployment target Swift 5.9+

Setup

1. Clone the repository:
```bash
git clone https://github.com/sunwoo101/ios-assignment-3.git
cd ios-assignment-3/apps/ios
```
Then in Xcode:

2. Open `App.xcodeproj`.
3. Wait for Swift Package Manager to resolve dependencies (CodeScanner).
4. Select an iOS 17+ simulator. Tested on iPhone 17 Pro; iPhone 15 and later should also work.
5. Press **⌘R** to build and run.

For backend setup, see the backend README. Once it's running, ensure the base URL in `Services/API/APIClient.swift` points to the correct host.

## Backend 

See the backend README for setup instructions.

## Contributing
See CONTRIBUTING.md in the repo root for commit message conventions and PR guidelines.
   
