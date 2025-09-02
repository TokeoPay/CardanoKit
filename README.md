# CardanoKit

[![Swift](https://img.shields.io/badge/Swift-6.1-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2013.0%2B%20%7C%20macOS%2010.15%2B-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Development Status](https://img.shields.io/badge/Status-Active%20Development-yellow.svg)](https://github.com/TokeoPay/CardanoKit)

A Swift library for Cardano blockchain integration in iOS applications. CardanoKit provides a clean, Swift-native API for Cardano address handling and blockchain operations, built on top of the robust CSL (Cardano Serialization Library) mobile bridge.

**🚧 Development Status**: CardanoKit is currently in active development but provides a working end-to-end solution for iOS applications. The core address functionality is stable and production-ready, with additional features being actively developed.

## ✨ Features

### Core Wallet Functionality ✅
- **HD Wallet Creation**: Generate new wallets with 12-24 word mnemonics
- **Wallet Recovery**: Restore wallets from mnemonic phrases or entropy
- **Address Generation**: Hierarchical deterministic address derivation
- **Multiple Address Types**: Payment addresses with staking credential support

### Transaction Operations ✅  
- **Transaction Parsing**: Parse Cardano transactions from CBOR hex format
- **Transaction Signing**: Full transaction signing with wallet private keys
- **UTXO Management**: Handle unspent transaction outputs and collections
- **Fee Calculation**: Extract transaction fees and metadata

### Address Management ✅
- **Multiple Address Formats**: Full support for Bech32 and hex address formats
- **Credential Extraction**: Extract and work with payment/staking credentials
- **Address Validation**: Validate and convert between address formats
- **Network Support**: Mainnet and testnet address compatibility

### Developer Experience ✅
- **Swift-Native API**: Clean, idiomatic Swift interface with modern async/await support
- **CSL Integration**: Built on the battle-tested Cardano Serialization Library
- **Memory Safe**: Automatic cleanup of cryptographic resources
- **iOS/macOS Optimized**: Platform-specific optimizations and integrations

## Requirements

### iOS Version
- **Minimum iOS Version**: iOS 17.0+
- **Minimum macOS Version**: macOS 15.0+

### Swift Version
- **Minimum Swift Version**: Swift 6.0
- **Xcode Version**: Xcode 15.0+

### Dependencies
- **CSL Mobile Bridge**: 0.0.1-alpha.5 (Cardano Serialization Library)
- **Bip39.swift**: 0.2.0+ (BIP39 mnemonic support)

### Supported Devices
- iPhone (iOS 17.0+)
- iPad (iOS 17.0+)
- Mac (macOS 15.0+)

## Installation

### Swift Package Manager (Recommended)

1. **Add the Package to Your Project**
   - Open your iOS project in Xcode
   - Go to **File** → **Add Package Dependencies...**
   - Enter the repository URL: `https://github.com/TokeoPay/CardanoKit.git`
   - Select the latest version or main branch
   - Click **Add Package**

2. **Add to Your Target**
   - Select your iOS app target
   - Go to the **General** tab
   - Scroll down to **Frameworks, Libraries, and Embedded Content**
   - Click the **+** button
   - Select **CardanoKit** from the list
   - Click **Add**

### Manual Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/TokeoPay/CardanoKit.git
   cd CardanoKit
   ```

2. **Add to Your Xcode Project**
   - Drag the `CardanoKit` folder into your Xcode project
   - Make sure "Copy items if needed" is checked
   - Select your target when prompted

### Package.swift Integration

Add CardanoKit to your Package.swift dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/TokeoPay/CardanoKit.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["CardanoKit"]
    )
]
```

## 🚀 Usage

### Quick Start - Wallet Creation

```swift
import CardanoKit

// Create a new wallet with different word counts
// Available options:
// .PISS_WEAK (12 words - 128 bits)
// .LITTLE_BETTER (15 words - 160 bits)
// .NEARLY_THERE (18 words - 192 bits)
// .SHOULD_BE_GOOD (21 words - 224 bits)
// .SOLID (24 words - 256 bits) - Recommended

let wallet = try CardanoWallet.generate(accountIndex: 0, wordCount: .SOLID)
let mnemonic = wallet.getMnumonic()
print("Generated mnemonic: \(mnemonic.joined(separator: " "))")

// Get payment address
let paymentAddress = try wallet.getPaymentAddress(index: 0)
print("Payment address: \(try paymentAddress.asBech32())")
```

### Quick Start - Address Operations

```swift
import CardanoKit

let bech32Address = "addr1qydqycuh5r253yp70572k2u80yy7hajyy5r9vd6nl9kcxndftu32t8ma5rrlus948vc8wcm0wj5nq6yz5p532lth67xq4hd8ee"

do {
    // Create address from Bech32 format
    let address = try Address(bech32: bech32Address)
    
    // Convert to different formats
    let hexFormat = try address.asHex()
    let bech32Format = try address.asBech32()
    
    print("Bech32: \(bech32Format)")
    print("Hex: \(hexFormat)")
    
    // Extract payment credentials
    let paymentCred = try address.getPaymentCred()
    print("Payment credential extracted successfully")
    
} catch {
    print("Address operation failed: \(error)")
}
```

### Wallet Recovery

```swift
import CardanoKit

// Restore wallet from mnemonic
let words = "art forum devote street sure rather head chuckle guard poverty release quote oak craft enemy"
let wallet = try CardanoWallet.fromMnemonic(accountIndex: 0, words: words)

// Generate multiple addresses
for i in 0..<5 {
    let address = try wallet.getPaymentAddress(index: Int64(i))
    print("Address \(i): \(try address.asBech32())")
}
```

### Transaction Signing

```swift
import CardanoKit

// Parse a transaction from CBOR hex
let txHex = "84a300d90102818258207e98967ba336f16739f1465171a2089a16042bdff12dc9d2dfead6234c06aa09010182a3005839110f5ace66a2d997176735c1042d5cbdc69cfed2265fd856d83210d6bf1847f764f368dfa8ca5a4e96ab7fca3bdbc803050b6b9510796c6f01..."

let transaction = try FixedTransaction.fromHex(hex: txHex)
print("Transaction hash: \(try transaction.hash())")
print("Transaction fee: \(try transaction.getFee() ?? 0) lovelace")

// Sign transaction with wallet
let utxos = try TransactionUnspentOutputs()
// ... add relevant UTXOs ...
try wallet.signTransaction(transaction: transaction, utxos: utxos)
print("Signed transaction: \(try transaction.toHex())")
```

### Data Signing (CIP-30)

```swift
import CardanoKit

// Sign arbitrary data with a specific address
let wallet = try CardanoWallet.fromMnemonic(accountIndex: 0, words: mnemonic)
let message = "Hello, Cardano!"
let messageData = Data(message.utf8)

// Sign data with specific address (e.g., address at index 15)
let signature = try wallet.signData(
    data: messageData, 
    withAddress: try wallet.getPaymentAddress(index: 15).asBech32()
)

print("Signature: \(signature.signature)")
print("Public Key: \(signature.key)")
```

### Working with Assets

```swift
import CardanoKit

// Create and manage multi-assets
var assets = try Assets()

// Add tokens to the asset collection
try assets.add(assetName: "MyToken", amount: 100)
try assets.add(assetName: "MyToken", amount: 50) // Adds to existing
try assets.add(assetName: "AnotherToken", amount: 25)

// Convert to map for processing
let assetMap = try await assets.toMap()
for (asset, quantity) in assetMap {
    print("Asset: \(asset.name), Quantity: \(quantity)")
}

// Create a Value object with ADA and tokens
let value = try Value(ada: BigInt(5_000_000)) // 5 ADA in lovelace
try value.setMultiAsset(multiAsset: assets.toMultiAsset())
```

### UTXO Management

```swift
import CardanoKit

// Create UTXO from hex
let utxoHex = "828258207233486deda2a6c5258a1c758e48a4e6adf5dd936e448c58819afb97f73e2c65008258390179467c69a9ac66280174d09d62575ba955748b21dec3b483a9469a658df11bbb405a7d1cab4f3041c9ba6efce2edff9b027b6ca4c73e97d3821a004c4b40a1581c2341201e2508eaebd9acaecbaa7630350cee6ebf437c52cc42bab23ea350477265656479476f626c696e733536340151477265656479476f626c696e73313336350151477265656479476f626c696e733333333701"
let utxo = try TransactionUnspentOutput.fromHex(hex: utxoHex)

// Create UTXO collection
let utxos = try TransactionUnspentOutputs()
try utxos.addUtxo(utxo: utxo)

// Extract required signers from transaction
let requiredSigners = try transaction.getRequiredSignerKeyHashes(utxos: utxos)
for signer in requiredSigners {
    print("Required signer: \(signer.hexEncodedString())")
}
```

### Wallet Creation from Entropy

```swift
import CardanoKit

// Create wallet from entropy bytes (16 bytes for 12 words)
let entropy: [UInt8] = [0xdf, 0x9e, 0xd2, 0x5e, 0xd1, 0x46, 0xbf, 0x43, 
                        0x33, 0x6a, 0x5d, 0x7c, 0xf7, 0x39, 0x59, 0x94]
let wallet = try CardanoWallet.fromEntropy(accountIndex: 0, entropy: entropy)

// Get the payment private key in Bech32 format
let privateKeyBech32 = try wallet.getPaymentPrivateKey().toString()
print("Private key: \(privateKeyBech32)")

// Generate addresses from entropy-based wallet
let address = try wallet.getPaymentAddress(index: 0)
print("Address: \(try address.asBech32())")
```

### Transaction Analysis

```swift
import CardanoKit

// Parse and analyze transaction details
let transaction = try FixedTransaction.fromHex(hex: txCbor)

// Get transaction body for detailed analysis
let body = try transaction.getBody()

// Analyze inputs
let inputs = try body.inputs()
for input in inputs {
    print("Input TX: \(input.txHash?.utf8 ?? "unknown")#\(input.index)")
}

// Analyze outputs  
let outputs = try body.outputs()
for output in outputs {
    let address = try output.address.asBech32()
    let lovelace = output.amount?.lovelace ?? 0
    print("Output to \(address): \(lovelace) lovelace")
    
    // Check for multi-assets
    if let multiAsset = output.amount?.multiAsset {
        // Process tokens in this output
    }
}

// Extract detailed transaction information
let provider = TxDetailsFactory(provider: yourDataProvider)
let txDetails = try provider.makeDetails(transaction: transaction)

// Access summarized inputs and outputs
for input in txDetails.inputSummary {
    print("Input: \(input.address) - \(input.value)")
}

for output in txDetails.outputSummary {
    print("Output: \(output.address) - \(output.value)")
}
```

### Comprehensive Example - Complete Wallet Flow

```swift
import CardanoKit

// Complete example showing wallet creation, address generation, and transaction signing
class CardanoWalletExample {
    
    func completeWalletFlow() async throws {
        // 1. Create a new wallet
        let wallet = try CardanoWallet.generate(accountIndex: 0, wordCount: .SOLID)
        let mnemonic = wallet.getMnumonic()
        print("Generated wallet with mnemonic: \(mnemonic.joined(separator: " "))")
        
        // 2. Generate multiple addresses
        var addresses: [Address] = []
        for i in 0..<5 {
            let address = try wallet.getPaymentAddress(index: Int64(i))
            addresses.append(address)
            print("Address \(i): \(try address.asBech32())")
        }
        
        // 3. Sign some data (CIP-30 compatible)
        let message = "Welcome to Cardano!"
        let signature = try wallet.signData(
            data: Data(message.utf8),
            withAddress: try addresses[0].asBech32()
        )
        print("Message signature: \(signature.signature)")
        
        // 4. Parse and analyze a transaction
        let txHex = "84a500818258207233486deda2a6c5258a1c758e48a4e6adf5dd936e448c58819afb97f73e2c6500..."
        let transaction = try FixedTransaction.fromHex(hex: txHex)
        
        // 5. Prepare UTXOs for signing
        let utxoHex = "828258207233486deda2a6c5258a1c758e48a4e6adf5dd936e448c58819afb97f73e2c65008258390179467c69a9ac66280174d09d62575ba955748b21dec3b483a9469a658df11bbb405a7d1cab4f3041c9ba6efce2edff9b027b6ca4c73e97d3821a004c4b40a1581c2341201e2508eaebd9acaecbaa7630350cee6ebf437c52cc42bab23ea350477265656479476f626c696e733536340151477265656479476f626c696e73313336350151477265656479476f626c696e733333333701"
        let utxo = try TransactionUnspentOutput.fromHex(hex: utxoHex)
        let utxos = try TransactionUnspentOutputs()
        try utxos.addUtxo(utxo: utxo)
        
        // 6. Get required signers
        let requiredSigners = try transaction.getRequiredSignerKeyHashes(utxos: utxos)
        print("Required signers: \(requiredSigners.count)")
        
        // 7. Sign the transaction
        try wallet.signTransaction(transaction: transaction, utxos: utxos)
        let signedTxHex = try transaction.toHex()
        print("Signed transaction ready for submission")
        
        // 8. Analyze transaction details
        let body = try transaction.getBody()
        let fee = try transaction.getFee() ?? 0
        print("Transaction fee: \(fee) lovelace (\(Double(fee) / 1_000_000) ADA)")
    }
}
```

### Advanced Usage Examples

#### Working with Different Address Formats

```swift
import CardanoKit

class CardanoAddressManager {
    
    func validateAndConvertAddress(_ addressString: String) -> (isValid: Bool, hex: String?, bech32: String?) {
        // Try as Bech32 first
        if let address = try? Address(bech32: addressString) {
            let hex = try? address.asHex()
            let bech32 = try? address.asBech32()
            return (true, hex, bech32)
        }
        
        // Try as hex format
        if let address = try? Address(hex: addressString) {
            let hex = try? address.asHex()
            let bech32 = try? address.asBech32()
            return (true, hex, bech32)
        }
        
        return (false, nil, nil)
    }
    
    func extractPaymentInfo(from addressString: String) throws -> String {
        let address = try Address(bech32: addressString)
        let paymentCred = try address.getPaymentCred()
        return "Payment credential extracted for address: \(addressString)"
    }
}
```

#### Integration with SwiftUI

```swift
import SwiftUI
import CardanoKit

struct AddressValidatorView: View {
    @State private var inputAddress = ""
    @State private var validationResult = ""
    @State private var isValid = false
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter Cardano Address", text: $inputAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Validate Address") {
                validateAddress()
            }
            .disabled(inputAddress.isEmpty)
            
            Text(validationResult)
                .foregroundColor(isValid ? .green : .red)
                .font(.caption)
        }
        .padding()
    }
    
    private func validateAddress() {
        do {
            let address = try Address(bech32: inputAddress)
            let hex = try address.asHex()
            validationResult = "Valid address!\nHex: \(hex)"
            isValid = true
        } catch {
            validationResult = "Invalid address: \(error.localizedDescription)"
            isValid = false
        }
    }
}
```

#### Transaction Data Provider Implementation

```swift
import CardanoKit

// Implement a data provider for transaction analysis
struct MyTransactionDataProvider: TransactionDataProvider {
    func getUtxos(for transactionInputs: TransactionInputs) throws -> TransactionUnspentOutputs {
        let utxos = try TransactionUnspentOutputs()
        
        try transactionInputs.forEach { input in
            // Fetch UTXO data from your source (blockchain, database, etc.)
            let txoHex = fetchTransactionOutput(for: input) // Your implementation
            let txo = try TransactionOutput(hex: txoHex)
            try utxos.addUtxo(utxo: TransactionUnspentOutput(input: input, output: txo))
        }
        
        return utxos
    }
}

// Use the provider for transaction analysis
let provider = TxDetailsFactory(provider: MyTransactionDataProvider())
let txDetails = try provider.makeDetails(transaction: transaction)
```

#### Comprehensive Wallet Management

```swift
import CardanoKit

class WalletManager {
    private let wallet: CardanoWallet
    
    init(mnemonic: String, accountIndex: Int32 = 0) throws {
        self.wallet = try CardanoWallet.fromMnemonic(
            accountIndex: accountIndex, 
            words: mnemonic
        )
    }
    
    // Generate multiple addresses for privacy
    func generateAddresses(count: Int) throws -> [Address] {
        return try (0..<count).map { index in
            try wallet.getPaymentAddress(index: Int64(index))
        }
    }
    
    // Sign multiple transactions in batch
    func batchSignTransactions(_ transactions: [FixedTransaction], 
                              utxos: TransactionUnspentOutputs) throws {
        for transaction in transactions {
            try wallet.signTransaction(transaction: transaction, utxos: utxos)
        }
    }
    
    // Export wallet information securely
    func exportWalletInfo() throws -> WalletExport {
        return WalletExport(
            rootPublicKey: try wallet.getRootPrivateKey().toPublic().toString(),
            firstAddress: try wallet.getPaymentAddress(index: 0).asBech32(),
            accountIndex: wallet.accountIndex
        )
    }
}

struct WalletExport {
    let rootPublicKey: String
    let firstAddress: String
    let accountIndex: Int32
}
```

#### Multi-Asset Token Management

```swift
import CardanoKit

class TokenManager {
    
    // Create a transaction output with multiple tokens
    func createMultiAssetOutput(address: Address, 
                               ada: Int64, 
                               tokens: [(policyId: String, assetName: String, amount: Int64)]) throws -> TransactionOutput {
        
        var value = try Value(ada: BigInt(ada))
        var multiAsset = try MultiAsset()
        
        // Group tokens by policy
        let tokensByPolicy = Dictionary(grouping: tokens) { $0.policyId }
        
        for (policyId, policyTokens) in tokensByPolicy {
            let policy = try Policy(hex: policyId)
            var assets = try Assets()
            
            for token in policyTokens {
                try assets.add(assetName: token.assetName, amount: token.amount)
            }
            
            try multiAsset.insert(policy: policy, assets: assets)
        }
        
        try value.setMultiAsset(multiAsset: multiAsset)
        
        return try TransactionOutput(address: address, amount: value)
    }
}
```

#### Error Handling Best Practices

```swift
import CardanoKit

enum CardanoKitError: Error {
    case invalidAddress
    case conversionFailed
    case credentialExtractionFailed
    case insufficientFunds
    case invalidTransaction
}

class SafeCardanoOperations {
    
    func safeAddressConversion(_ input: String) -> Result<(hex: String, bech32: String), CardanoKitError> {
        do {
            let address = try Address(bech32: input)
            let hex = try address.asHex()
            let bech32 = try address.asBech32()
            return .success((hex: hex, bech32: bech32))
        } catch {
            return .failure(.invalidAddress)
        }
    }
    
    func safePaymentCredExtraction(_ input: String) -> Result<String, CardanoKitError> {
        do {
            let address = try Address(bech32: input)
            _ = try address.getPaymentCred()
            return .success("Payment credential extracted successfully")
        } catch {
            return .failure(.credentialExtractionFailed)
        }
    }
    
    func safeTransactionSigning(wallet: CardanoWallet, 
                               txHex: String, 
                               utxoHexList: [String]) -> Result<String, CardanoKitError> {
        do {
            let transaction = try FixedTransaction.fromHex(hex: txHex)
            let utxos = try TransactionUnspentOutputs()
            
            for utxoHex in utxoHexList {
                let utxo = try TransactionUnspentOutput.fromHex(hex: utxoHex)
                try utxos.addUtxo(utxo: utxo)
            }
            
            try wallet.signTransaction(transaction: transaction, utxos: utxos)
            return .success(try transaction.toHex())
        } catch {
            return .failure(.invalidTransaction)
        }
    }
}
```

## 🛠️ Dependencies

CardanoKit is built on proven, battle-tested components:

- **[CSL Mobile Bridge](https://github.com/TokeoPay/csl-mobile-bridge)**: Cardano Serialization Library mobile bridge providing Rust-based Cardano functionality
- **Foundation**: Apple's fundamental framework for Swift development
- **Swift 6.1+**: Latest Swift language features and memory safety

## 🗺️ Development Roadmap

### ✅ Completed (v0.1.0)
- [x] Basic address creation and validation
- [x] Bech32 and hex format conversion
- [x] Payment credential extraction
- [x] CSL mobile bridge integration
- [x] iOS/macOS platform support
- [x] Comprehensive test coverage


## 🤝 Contributing

CardanoKit is actively developed and we welcome contributions! Here's how you can help:

### 🐛 Reporting Issues
- Use the [GitHub Issues](https://github.com/TokeoPay/CardanoKit/issues) to report bugs
- Provide detailed reproduction steps and environment information
- Include relevant code snippets and error messages

### 📝 Submitting Changes
1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Make** your changes with clear, descriptive commits
4. **Add** tests for new functionality
5. **Run** the test suite (`swift test`)
6. **Submit** a pull request with a clear description

### 📜 Development Setup
```bash
# Clone the repository
git clone https://github.com/TokeoPay/CardanoKit.git
cd CardanoKit

# Build the project
swift build

# Run tests
swift test

# Open in Xcode (optional)
open Package.swift
```


## 💬 Support & Community

- **Issues**: [GitHub Issues](https://github.com/TokeoPay/CardanoKit/issues) for bug reports and feature requests
- **Discussions**: [GitHub Discussions](https://github.com/TokeoPay/CardanoKit/discussions) for questions and community chat
- **Email**: For security issues or private matters, contact [security@tokeopay.com](mailto:security@tokeopay.com)

## 📄 License

CardanoKit is released under the MIT License. See [LICENSE](LICENSE) for details.

## 🚪 Acknowledgments

- **[Cardano Foundation](https://cardanofoundation.org/)** for the Cardano blockchain
- **[Input Output (IOHK)](https://iohk.io/)** for the Cardano Serialization Library
- **[Emurgo](https://emurgo.io/)** for continued Cardano ecosystem development
- **The Cardano Community** for ongoing support and feedback

---

**Built with ❤️ by the [TokeoPay](https://github.com/TokeoPay) team** 
## About Tokeo

CardanoKit is developed by [Tokeo](https://tokeopay.io), a comprehensive dApp and wallet solution for the Cardano blockchain. Tokeo aims to empower users with secure, efficient, and user-friendly tools for managing digital assets. Learn more at [tokeopay.io](https://tokeopay.io).[](https://medium.com/%40patryk_karter/cardano-defi-016-tokeo-08583d1c8bfc)
