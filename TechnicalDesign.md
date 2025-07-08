# Tokeo Technical Design (TTD)

## Cardano Swift
Integrate Cardano functionality in Swift, natively.

## Contents

- [Tokeo Technical Design (TTD)](#tokeo-technical-design-ttd)	1
- [Contents](#contents)	2
- [1 Overview](#1-overview)	3
  - [1.1 Background](#11-background)	3
  - [1.2 Problems to Solve](#12-problems-to-solve)	3
  - [1.3 Objectives & Key Outcomes](#13-objectives--key-outcomes)	3
  - [1.4 Document Scope](#14-document-scope)	4
    - [1.41 What this library is](#141-what-this-library-is)	4
    - [1.4.2 What this library is not.](#142-what-this-library-is-not)	4
- [2 Technical Design](#2-technical-design)	5
  - [2.1 Overview](#21-overview)	5
  - [2.1 Standards](#21-standards)	5
- [3.0. Key Components](#30-key-components)	6
  - [3.1 Rust Wrapper](#31-rust-wrapper)	6
  - [3.2 Swift API Layer](#32-swift-api-layer)	7
    - [3.2.1 Instantiation](#321-instantiation)	7
    - [3.2.2 Transactions - Pay](#322-transactions---pay)	7
    - [3.2.2 Transactions - Sign](#322-transactions---sign)	8
    - [3.2.3 Transactions - Stake](#323-transactions---stake)	8
    - [3.2.3 Transactions - Governance](#323-transactions---governance)	9
    - [3.2.4 Query](#324-query)	9
    - [3.2.5 Smart Contract Execution](#325-smart-contract-execution)	10
  - [3.3 Third-Party Integration](#33-third-party-integration)	10
  - [3.4 Exceptions and Error Handling](#34-exceptions-and-error-handling)	11
- [4 Implementation Plan](#4-implementation-plan)	11
  - [4.1 Milestones](#41-milestones)	11
  - [4.2 Testing Strategy](#42-testing-strategy)	12
- [5 References](#5-references)	12
- [6 Conclusion](#6-conclusion)	12

## 1 Overview

### 1.1 Background
The Cardano Swift library serves as a wrapper around the Cardano Serialization Library (CSL), exposing core Cardano primitives and basic transaction-building capabilities. 
The library enables developers to integrate Cardano blockchain features into native Swift-based mobile applications, abstracting much of the complexity associated with blockchain interactions.

### 1.2 Problems to Solve
The original Cardano Swift library faces several limitations that hinder its adoption and usability:
- Outdated Library: The library has not been updated to reflect recent Cardano hard forks (e.g., Conway era) or CSL changes, Plutus changes (v1 to v3) leading to compatibility issues.
- Limited Features: It supports only basic transaction building, lacking advanced features like DRep voting, smart contract execution, or asset minting.
- Limited Third-Party Support: The library is restricted to Blockfrost as a data provider, limiting flexibility for developers who prefer alternatives like Maestro.
- Deprecated Swift Code: The codebase uses outdated Swift design patterns, making it less maintainable and incompatible with modern Swift practices (e.g., async/await, actors).

### 1.3 Objectives & Key Outcomes
The modernization of the Cardano Swift library aims to achieve the following:
- Upgrade the library to support the latest CSL release (as of May 2025).
- Extend functionality to include new Cardano features, such as DRep voting (CIP-1694) and Plutus smart contract execution.
- Modernize the codebase to leverage contemporary Swift design patterns (e.g., async/await, protocols, and dependency injection).
- Provide a simplified, developer-friendly API that abstracts UTxO management, coin selection, and transaction building.
- Enable seamless integration with multiple third-party data providers (e.g., Blockfrost, Maestro).
- Demonstrate ease of use through comprehensive documentation and example projects to encourage community adoption.

### 1.4 Document Scope
This document outlines the technical and architectural components required to develop and finalize the modernized Cardano Swift library. It defines the library’s structure, key functionalities, and integration points while addressing developer usability and extensibility.

#### 1.41 What this library is
The Cardano Swift library is an off-chain framework inspired by libraries like Lucid, designed to simplify transaction building and wallet management for Cardano-based applications. On Cardano, most computation occurs off-chain, with smart contracts (validators) acting as scripts that lock UTxOs. Transactions must satisfy validator constraints to spend these UTxOs. The library abstracts the complexities of UTxO management, transaction construction, and interaction with Cardano’s blockchain, allowing developers to focus on application logic. It provides a Swift-native interface to the CSL, enhanced with modern Swift paradigms and third-party provider support.

#### 1.4.2 What this library is not.
The Cardano Swift library is not a smart contract language or a tool for creating validators. It does not execute on-chain logic or replace the need for Plutus scripts. Instead, it focuses on off-chain operations, such as constructing transactions, managing wallets, and querying blockchain data, to streamline the development of Cardano-based dApps.

## 2 Technical Design

### 2.1 Overview 
The Cardano Swift library is built on the Cardano Serialization Library (CSL), a Rust-based library that provides low-level primitives for Cardano blockchain interactions. The library uses a layered architecture:
- Rust Wrapper: Interfaces with the CSL to expose Cardano primitives and functions.
- Swift API Layer: Provides a high-level, Swift-native interface that abstracts CSL complexities.
- Third-Party Integration: Supports data providers like Blockfrost and Maestro for blockchain queries and transaction submission.

At the time of writing, the latest CSL release (version [TBD, e.g., 11.x.x]) is targeted. The Rust wrapper will be implemented as a C-compatible interface to bridge CSL with Swift, using Swift’s foreign function interface (FFI) capabilities.

### 2.1 Standards 
The standards as defined by a number of Cardano Improvement Proposals (CIPs) will be implemented by this model which include:

| CIP | Description | Notes |
|-----|-------------|-------|
| CIP-0003 | Wallet Key Generation | https://cips.cardano.org/cip/CIP-0003 |
| CIP-0010 | Transaction metadata | https://cips.cardano.org/cip/CIP-0010 |
| CIP-0011 | Staking keychain | https://cips.cardano.org/cip/CIP-0011 |
| CIP-0016 | Cryptographic Key Serialisation Formats | https://cips.cardano.org/cip/CIP-0016 |
| CIP-0019 | Cardano Addresses | https://cips.cardano.org/cip/CIP-0019 |
| CIP-030 | Cardano dApp-Wallet Web Bridge| https://cips.cardano.org/cip/CIP-0030 |
| CIP-095 | Governance web bridge | https://cips.cardano.org/cip/CIP-0095 |
| CIP-0105 | Conway era Key Chains for HD Wallets | https://cips.cardano.org/cip/CIP-0105 |
| CIP-1694 | Governance | https://github.com/cardano-foundation/CIPs/commit/a85ffb7eddcd60a95ede453d923ab7cdbffadad3 | 

## 3.0. Key Components

### 3.1 Rust Wrapper
The Rust wrapper serves as the intermediary between the CSL and the Swift API layer. It exposes the following CSL primitives and functions:
- Transaction Builder: Constructs transactions, including UTxO selection, fee calculation, and script execution.
- Transaction Signer: Signs a transaction and provides the ability to submit transaction to network via integration partners
- Address: Handles Bech32 address encoding/decoding for payment, stake and DRep addresses.
- Value: Manages ADA and native asset balances.
- Datum: Supports inline and hash-based datums for Plutus scripts.
- ScriptRef: References Plutus scripts for smart contract execution.
- DRepVoting: Supports CIP-1694 governance actions, such as registering DReps and voting on proposals.

The wrapper will be compiled as a static library, linked to the Swift codebase via FFI. To ensure compatibility, the wrapper will be tested against the latest CSL release and Cardano network parameters (mainnet and preprod).

### 3.2 Swift API Layer
The Swift API layer provides a high-level, developer-friendly interface that abstracts CSL complexities. It leverages modern Swift features (e.g., async/await, protocols, and enums) to ensure maintainability and usability. The API is organized into the following modules:

#### 3.2.1 Instantiation
When a Wallet is instantiated, Swift Cardano will attempt to derive a number of Payment Addresses. These are then validated to see if they have ever been used.

When a Payment Address is requested from the library the default is to return the address at Index 0, however it should be possible for the developer to request an address at a supplied Index or even a get new address which will create a new, never seen on chain address.

From mnemonic:
```swift
let wallet = try await CardanoWallet.fromMnemonic(accountIndex: 0, "word1 word2 ... word24")
```

From private key:
```swift
let wallet = try CardanoWallet.fromPrivateKey("private_key_hex")
```

Select provider:
```swift
wallet.selectProvider(.blockfrost(apiKey: "project_id", network: .mainnet))
wallet.selectProvider(.maestro(apiKey: "api_key", network: .preprod))
```

#### 3.2.2 Transactions - Pay
Send ADA: Transfers ADA to a specified address.
```swift
let tx = try await wallet.newTx()
  .spend(txId: “hash”, index: 1, redeemer: Redeemer)
  .spend(utxo: Utxo, redeemer: Redeemer)
  .attachScript(script: Script) // Script is a Native or PlutusV(1|2|3) script
  .payTo(address: "addr...", amount: 5_000_000) // 5 ADA
  .payTo(address: “addr123”, amount: Value)
  .payTo(address: “addr123”, amount: Value, datum: Datum)
  .payTo(address: “addr123”, amount: Value, scriptRef: ScriptRef)
  .payTo(address: “addr123”, amount: Value, datum: Datum, scriptRef: ScriptRef)
  .commit()
```

Send Assets: Transfers native assets alongside ADA.
```swift
let tx = try await wallet.newTx()
  .payTo(address: "addr...", assets: ["policy_id.asset_name": 100])
  .commit()
```

Metadata: Attaches metadata to transactions (e.g., CIP-20).
```swift
let tx = try await wallet.newTx()
  .withMetadata(["key": "value"])
  .commit()
```

Mint Assets: Mints native assets with a provided policy.
```swift
let tx = try await wallet.newTx()
  .mintAssets(policyId: "policy_id", assets: ["asset_name": 100])
  .commit()
```

#### 3.2.2 Transactions - Sign
Build Transaction - Accepts transaction HEX and parses into a structured Cardano transaction

Sign Transaction - Signs a transaction by inspecting required signers on the transaction.

#### 3.2.3 Transactions - Stake
Register Stake Key: Registers a stake key for delegation.
```swift
let tx = try await wallet.newTx()
  .registerStakeKey()
  .commit()
```

De-register Stake Key: Removes a stake key.
```swift
let tx = try await wallet.newTx()
  .deregisterStakeKey()
  .commit()
```

Delegate to Stake Pool: Delegates to a stake pool.
```swift
let tx = try await wallet.newTx()
  .delegateTo(poolId: "pool_id")
  .commit()
```

Withdraw Reward: Withdraws staking rewards.
```swift
let tx = try await wallet.newTx()
  .withdrawReward()
  .commit()
```

#### 3.2.3 Transactions - Governance
Register DRep: Registers a delegated representative (DRep) per CIP-1694.
```swift
let tx = try await wallet.newTx()
  .registerDRep()
  .commit()
```

Vote on Proposal: Submits a governance vote.
```swift
let tx = try await wallet.newTx()
  .voteOnProposal(proposalId: "proposal_id", vote: .yes)
  .commit()
```

#### 3.2.4 Query
Get UTxOs: Retrieves available UTxOs for the wallet.
```swift
let utxos = try await wallet.getUTxOs()
```

Get Rewards: Queries staking rewards.
```swift
let rewards = try await wallet.getRewards()
```

Get Locked Lovelace: Returns lovelace locked against Native Assets.
```swift
let locked = try await wallet.getLockedLovelace()
```

To do this we look at all UTxOs against a Wallet, we then take all Native Assets and put them into a Single TX Input, once we have calculated the Minimum Lovelace needed to correctly create this Asset rich TX Input we have the “locked lovelace”.
When building a transaction the amount of Locked Lovelace will change based upon what the transaction is trying to do. For example if a transaction is sending Native Assets to a different wallet, then the “locked lovelace” will decrease - i.e., lovelace will be freed up to be able to be spent.

Get Available Lovelace: Returns spendable lovelace.
```swift
let available = try await wallet.getAvailableLovelace()
```

This is the inverse of the getLockedLovelace method from above.

Get Addresses: Retrieves payment, stake, and enterprise addresses.
```swift
let payment = try await wallet.getPaymentAddress(index: 0)
let all = try await wallet.getAllPaymentAddresses()
let enterprise = try await wallet.getEnterpriseAddress()
let stake = try await wallet.getStakeAddress()
let drep = try await wallet.getDRepAddress()
```

Get Keys: Accesses private and public keys or mnemonic.
```swift
let rootPrivateKey = try wallet.getRootPrivateKey()
let privateKey = try wallet.getPrivateKey()
let publicKey = try wallet.getPublicKey()
let mnemonic = try wallet.getMnemonic()
```

Generate Mnemonic: Creates a new BIP-39 mnemonic.
```swift
let mnemonic = try CardanoWallet.generateMnemonic(words: .WORDS_24)
```

#### 3.2.5 Smart Contract Execution
[Content not provided in the original text.]

### 3.3 Third-Party Integration
The library supports multiple data providers for blockchain queries and transaction submission:
- Blockfrost: Configured with an API key and network (mainnet, preprod, or preview).
```swift
let provider = BlockfrostProvider(apiKey: "project_id", network: .mainnet)
```
- Maestro: Configured with an API key and optional turbo submission.
```swift
let provider = MaestroProvider(apiKey: "api_key", network: .preprod, turboSubmit: false)
```

A Provider protocol ensures extensibility:
```swift
protocol CardanoProvider {
    func fetchUTxOs(address: String) async throws -> [UTxO]
    func submitTx(_ tx: Transaction) async throws -> String
    // Additional methods
}
```

### 3.4 Exceptions and Error Handling
The library uses Swift’s error handling to manage exceptions. Errors are categorized into:
- CSL Errors: Issues from the Rust wrapper (e.g., invalid address, serialization failure).
- Provider Errors: Network or API issues (e.g., invalid API key, rate limits).
- Validation Errors: Transaction constraints not met (e.g., insufficient funds).
- User Errors: Incorrect inputs (e.g., invalid mnemonic).

Errors are thrown as typed enums:
```swift
enum CardanoError: Error {
    case cslError(message: String)
    case providerError(statusCode: Int, message: String)
    case validationError(details: String)
    case userError(details: String)
}
```

The API includes detailed error messages and recovery suggestions to aid debugging.

## 3 Model

### 3.1 Types
The library defines the following key types:
- CardanoWallet: The main interface for wallet operations, encapsulating key management, transaction building, and queries.
- Transaction: Represents a transaction under construction, with methods to add payments, metadata, or scripts.
- UTxO: Models an unspent transaction output, including address, value, and datum.
- PlutusData: Represents Plutus data (e.g., integers, lists, or constructors) for smart contract interactions.
- Value: Encapsulates ADA and native asset amounts.
- Address: Handles Bech32-encoded payment and stake addresses.
- DRep: Represents a delegated representative for governance actions.

### 3.2 Data Flow
The data flow follows a layered approach:
- Application Layer: Calls Swift API methods (e.g., wallet.newTx().payTo(...)).
- Swift API Layer: Translates calls into CSL operations via the Rust wrapper.
- Rust Wrapper: Interacts with CSL to perform low-level operations.
- Provider Layer: Queries blockchain data or submits transactions via Blockfrost or Maestro.

### 3.3 Security Considerations
Security is a critical aspect of the Cardano Swift library, given its role in managing cryptographic keys, signing transactions, and interacting with external services. The following measures ensure the library operates securely:

**Key Management:**
- Outside the scope of this library and it is assumed the application layer (developer) stores Private keys and BIP-39 mnemonics are securely using iOS’s Keychain Services or Secure Enclave (where supported) to prevent unauthorized access.

**Transaction Signing:**
- All transaction signing occurs locally on the device, ensuring private keys are never exposed to third-party providers or external services.
- Transactions are validated before signing to prevent malformed or malicious inputs, using CSL’s built-in checks for UTxO consistency and fee calculation.
- The library supports multi-signature transactions, allowing developers to implement additional security controls for high-value operations.

**Third-Party Provider Security:**
- API keys for providers (e.g., Blockfrost, Maestro) are encrypted during transit using HTTPS and stored securely in the Keychain.
- The library implements rate-limiting detection and exponential backoff to handle provider errors gracefully, reducing the risk of denial-of-service attacks.
- Providers are treated as untrusted; all data retrieved (e.g., UTxOs, chain state) is validated against CSL rules to prevent tampering.

**Data Privacy:**
- No personally identifiable information (PII) is included in transaction metadata unless explicitly added by the developer.
- The library minimizes data sent to providers, requesting only the necessary UTxOs or chain data required for transaction construction.
- Logging is implemented with care, ensuring no sensitive data (e.g., private keys, mnemonics) is included in logs, even in debug mode.

**Secure Communication:**
- All network requests to third-party providers use TLS 1.2 or higher, with certificate pinning optional for enhanced security.
- The library supports proxy configurations (e.g., Tor) for privacy-conscious developers, configurable via the CardanoProvider protocol.

**Auditing and Transparency:**
- The library includes detailed logging (configurable by developers) for transaction construction and submission, aiding in debugging without exposing sensitive data.
- All cryptographic operations (e.g., signing, key derivation) use audited CSL implementations, reducing the risk of vulnerabilities.
- The codebase will be open-sourced, allowing community audits and contributions to enhance security.

Developers are encouraged to follow best practices, such as validating user inputs, using secure storage for keys, and testing on Cardano testnets before deploying to mainnet.

## 4 Implementation Plan

### 4.1 Milestones
- CSL Upgrade: Integrate the latest CSL release and test on mainnet/preprod.
- Rust Wrapper: Develop and test the C-compatible interface.
- Swift API: Implement the core API with modern Swift patterns.
- Provider Integration: Add support for Blockfrost and Maestro.
- Governance Features: Implement DRep voting and related actions.
- Smart Contract Support: Add Plutus script execution capabilities.
- Documentation: Create comprehensive guides and example projects.
- Testing: Conduct unit, integration, and end-to-end tests.
- Release: Publish the library to Swift Package Manager and GitHub.

### 4.2 Testing Strategy
- Unit Tests: Validate individual components (e.g., address encoding, transaction building).
- Integration Tests: Test interactions with Blockfrost and Maestro on testnets.
- End-to-End Tests: Simulate real-world scenarios (e.g., sending ADA, voting).
- Fuzz Testing: Ensure robustness against malformed inputs.

## 5 References
[Content not provided in the original text.]

## 6 Conclusion
The modernized Cardano Swift library will provide a robust, developer-friendly interface for building Cardano-based applications on iOS. By leveraging the latest CSL, supporting new features like DRep voting, and integrating multiple data providers, the library will lower the barrier to entry for Swift developers and foster innovation in the Cardano ecosystem.
