# CardanoKit

CardanoKit is a Swift library designed to integrate Cardano blockchain functionality into iOS applications. It provides tools for wallet management, transaction creation, and interaction with the Cardano network, enabling developers to build secure and efficient Web3 applications.

## Overview

CardanoKit simplifies the process of connecting iOS apps to the Cardano blockchain. Key features include:
- Wallet creation and management
- Transaction signing and submission
- Querying blockchain data
- Integration with Cardano's smart contract capabilities

This library is ideal for developers building DeFi, NFT, or other blockchain-based applications on the Cardano network.

## Prerequisites

Before integrating CardanoKit into your iOS app, ensure you meet the following requirements:

- **Xcode**: Version 15.0 or later
- **Swift**: Version 5.7 or later
- **iOS**: Minimum deployment target of iOS 15.0
- **Swift Package Manager (SPM)**: Supported for dependency management
- **Network Access**: Ensure your app has internet access to communicate with Cardano nodes
- **Cardano Node**: Access to a Cardano node (mainnet, preprod, or testnet) or a third-party API service (e.g., Blockfrost)

## Supported Devices

CardanoKit is compatible with the following Apple devices running iOS 15.0 or later:
- **iPhone**: All models from iPhone 6S and newer
- **iPad**: All models supporting iPadOS 15.0 or later
- **Architecture**: arm64 (physical devices and simulators)

Note: For optimal performance, we recommend using devices with A12 Bionic chips or later (iPhone XR, iPhone XS, or newer).

## Installation

Follow these steps to integrate CardanoKit into your iOS app using Swift Package Manager (SPM).

### Step 1: Add CardanoKit as a Dependency

1. Open your project in Xcode.
2. Navigate to **File > Add Package Dependencies**.
3. In the package search field, enter the repository URL:
   ```
   https://github.com/TokeoPay/CardanoKit
   ```
4. Select the CardanoKit package and choose the latest version (or specify a version, e.g., `1.0.0`).
5. Click **Add Package** to include CardanoKit in your project.

### Step 2: Configure Your Project

1. In your Xcode project, select your target under **Targets**.
2. Go to the **General** tab and ensure CardanoKit appears under **Frameworks, Libraries, and Embedded Content**.
3. If you need to configure network permissions, add the following to your `Info.plist`:
   ```xml
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsArbitraryLoads</key>
       <true/>
   </dict>
   ```
   **Note**: For production apps, configure specific domains instead of allowing arbitrary loads to comply with App Store guidelines.

### Step 3: Import and Use CardanoKit

In your Swift files, import the CardanoKit module and start using its APIs. Example:

```swift
import CardanoKit

class WalletViewModel: ObservableObject {
    func createWallet() async throws {
        let wallet = try await CardanoKit.Wallet.create(
            mnemonic: "your 24-word mnemonic phrase",
            network: .mainnet
        )
        print("Wallet Address: \(wallet.address)")
    }
}
```

### Step 4: Handle Errors and Async Calls

CardanoKit uses Swift's modern concurrency model. Ensure you handle errors and use `try await` for asynchronous operations, as shown in the example above. Wrap calls in `do-catch` blocks to manage potential errors:

```swift
do {
    let balance = try await wallet.getBalance()
    print("Balance: \(balance) ADA")
} catch {
    print("Error fetching balance: \(error)")
}
```

## Example Usage

Below is a basic example of creating a wallet and checking its balance in a SwiftUI view:

```swift
import SwiftUI
import CardanoKit

struct ContentView: View {
    @StateObject private var viewModel = WalletViewModel()
    
    var body: some View {
        VStack {
            Text("Cardano Wallet")
            Button("Create Wallet") {
                Task {
                    try await viewModel.createWallet()
                }
            }
        }
    }
}
```

## Configuration

To interact with the Cardano blockchain, configure CardanoKit with a node or API provider. For example, if using Blockfrost:

```swift
CardanoKit.configure(apiKey: "your-blockfrost-api-key", network: .mainnet)
```

Obtain an API key from a provider like [Blockfrost](https://blockfrost.io) or run your own Cardano node.

## Troubleshooting

- **Dependency Errors**: Ensure your Xcode and Swift versions meet the prerequisites. Update SPM by selecting **File > Packages > Update to Latest Package Versions**.
- **Network Issues**: Verify your node or API provider is accessible and your app has proper network permissions.
- **Simulator Limitations**: Some cryptographic operations may require a physical device due to Secure Enclave dependencies.

For additional support, check the [Issues](https://github.com/TokeoPay/CardanoKit/issues) section on GitHub or contact the Tokeo team at [Team@tokeopay.com](mailto:Team@tokeopay.com).

## Contributing

We welcome contributions to CardanoKit! To contribute:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Commit your changes (`git commit -m "Add your feature"`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a Pull Request.

Please read our [Contributing Guidelines](CONTRIBUTING.md) for more details.

## License

CardanoKit is licensed under the [MIT License](LICENSE). See the LICENSE file for details.

## About Tokeo

CardanoKit is developed by [Tokeo](https://tokeopay.io), a comprehensive dApp and wallet solution for the Cardano blockchain. Tokeo aims to empower users with secure, efficient, and user-friendly tools for managing digital assets. Learn more at [tokeopay.io](https://tokeopay.io).[](https://medium.com/%40patryk_karter/cardano-defi-016-tokeo-08583d1c8bfc)
