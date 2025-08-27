# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CardanoKit is a Swift Package that provides Cardano blockchain integration for iOS applications. It wraps the CSL (Cardano Serialization Library) mobile bridge to offer Swift-friendly APIs for Cardano address handling and blockchain operations.

## Build & Test Commands

### Building the Package
```bash
# Build the package
swift build

# Build for specific platform
swift build -c release

# Build with Xcode (if opened as project)
xcodebuild -scheme CardanoKit -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### Testing
```bash
# Run all tests
swift test

# Run tests with Xcode
xcodebuild -scheme CardanoKit -destination 'platform=iOS Simulator,name=iPhone 15' test

# Run specific test
swift test --filter CardanoKitTests.example
```

### Package Resolution
```bash
# Update package dependencies
swift package update

# Resolve dependencies
swift package resolve

# Reset package state
swift package reset
```

## Architecture

### Core Structure
- **CardanoKit.swift**: Main module containing the `Address` struct that wraps CSL functionality
- **Package.swift**: Defines the Swift Package with dependency on `csl-mobile-bridge`
- **CSL Integration**: Built on top of the Cardano Serialization Library mobile bridge (Rust-based)

### Key Components

#### Address Structure
The `Address` struct is the primary interface:
- Wraps `OpaqueRustPointer<CSLKit.Types.CSL_Address>` from CSL mobile bridge
- Supports creation from Bech32 and hex formats
- Provides conversion methods for different address formats
- Handles payment credential extraction

#### Dependencies
- **CSLKit**: From `csl-mobile-bridge` repository, pinned to specific revision
- **Foundation**: For basic Swift functionality
- **Testing/XCTest**: For unit testing

### Platform Requirements
- **Minimum iOS**: 13.0
- **Minimum macOS**: 10.15
- **Swift Version**: 6.1+
- **Xcode**: 15.0+

## Development Patterns

### Error Handling
All CSL operations can throw errors - always use `try` blocks when calling CardanoKit methods:
```swift
do {
    let address = try Address(bech32: "addr1...")
    let hex = try address.asHex()
} catch {
    // Handle CSL errors
}
```

### Testing Strategy
Tests use both the new Swift Testing framework (`@Test`) and XCTest (`XCTAssertEqual`) for compatibility.

### CSL Bridge Integration
The library acts as a Swift wrapper around Rust-based CSL functionality through opaque pointers. All operations delegate to the underlying CSL implementation.

## Common Development Tasks

### Adding New Address Operations
1. Add method to `Address` struct in `Sources/CardanoKit/CardanoKit.swift`
2. Call appropriate CSL function from CSLKit
3. Handle error propagation with `throws`
4. Add corresponding test case

### Updating CSL Dependency
1. Update revision in `Package.swift` dependencies
2. Run `swift package update`
3. Verify tests still pass
4. Update any breaking API changes

### Testing Address Functionality
Use real Cardano addresses in tests - the current test uses a mainnet address that converts between bech32 and hex formats for validation.