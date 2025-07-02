# CardanoKit

[![Swift](https://img.shields.io/badge/Swift-6.1-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2013.0%2B%20%7C%20macOS%2010.15%2B-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Development Status](https://img.shields.io/badge/Status-Active%20Development-yellow.svg)](https://github.com/TokeoPay/CardanoKit)

A Swift library for Cardano blockchain integration in iOS applications. CardanoKit provides a clean, Swift-native API for Cardano address handling and blockchain operations, built on top of the robust CSL (Cardano Serialization Library) mobile bridge.

**🚧 Development Status**: CardanoKit is currently in active development but provides a working end-to-end solution for iOS applications. The core address functionality is stable and production-ready, with additional features being actively developed.

## ✨ Features

- ✅ **Cardano Address Management**: Create, validate, and convert Cardano addresses
- ✅ **Multiple Address Formats**: Full support for Bech32 and hex address formats
- ✅ **Payment Credentials**: Extract and work with payment credentials
- ✅ **Swift-Native API**: Clean, idiomatic Swift interface
- ✅ **CSL Integration**: Built on the battle-tested Cardano Serialization Library
- ✅ **iOS Optimized**: Designed specifically for iOS/macOS applications
- 🚧 **More Features Coming**: Transaction building, staking, and advanced operations

## Requirements

### iOS Version
- **Minimum iOS Version**: iOS 13.0+
- **Recommended iOS Version**: iOS 14.0+

### Swift Version
- **Minimum Swift Version**: Swift 6.1
- **Xcode Version**: Xcode 15.0+

### Supported Devices
- iPhone (iOS 13.0+)
- iPad (iOS 13.0+)
- iPod touch (iOS 13.0+)

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

### Quick Start

```swift
import CardanoKit

// CardanoKit provides simple, clean APIs for Cardano address operations
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

#### Error Handling Best Practices

```swift
import CardanoKit

enum CardanoKitError: Error {
    case invalidAddress
    case conversionFailed
    case credentialExtractionFailed
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

### 🚧 In Progress
- [ ] Transaction building and signing
- [ ] Multi-asset support (Native tokens)
- [ ] Staking operations
- [ ] Metadata handling
- [ ] Enhanced error types and messages

### 🔮 Future Releases
- [ ] Smart contract interaction
- [ ] Hardware wallet integration
- [ ] Plutus script support
- [ ] Advanced transaction features
- [ ] Comprehensive documentation site
- [ ] More comprehensive examples and tutorials

### 🎯 Current Focus
We're currently focusing on:
1. **Transaction Building**: Core transaction creation and signing functionality
2. **Multi-Asset Support**: Native token handling and operations
3. **Enhanced Testing**: Expanding test coverage for all scenarios
4. **Documentation**: Improving guides and API documentation

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

### 🔍 Areas Where We Need Help
- 🧪 **Testing**: More comprehensive test cases and edge case coverage
- 📝 **Documentation**: API documentation and usage guides
- 🔍 **Code Review**: Review pull requests and provide feedback
- 🐛 **Bug Reports**: Test the library and report any issues
- ✨ **Feature Requests**: Suggest new features and improvements

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
