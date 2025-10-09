//
//  Wallet.swift
//  CardanoKit
//
//  Created by Gavin Harris on 15/7/2025.
//

import Foundation

public enum WordCount: Int {
    case POOR = 128
    case WEAK = 160
    case OKAY = 192
    case GOOD = 224
    case SOLID = 256
}

public class CardanoWallet {
    private var network: Int64 = 1
    private var rootKeychain: Keychain
    private var dataProvider: TransactionDataProvider?
    private var foundAddresses: [String: AddressMapping] = [:] // TODO: I need to provide a way for the Developer to provide this data. Could look at using a proper local data store
    
    init(network: Int64 = 1, keychain: Keychain) {
        self.rootKeychain = keychain
        self.network = network
        
//        self.rootKeychain.getPaymentKey(index: 0)
        
//        keychain.rootKeyPair.
    }
    
    convenience init() throws {
        try self.init(keychain: Keychain(strength: 256))
    }
    
    convenience init(network: Int64, accountIndex: Int64, mnemonic: String) throws {
        try self.init(network: network, keychain: Keychain(accountIndex: accountIndex, mnemonic: mnemonic.components(separatedBy: " ")))
    }
    
    public static func generate(network: Int64 = 0, accountIndex: Int64, wordCount: WordCount) throws -> CardanoWallet {
        CardanoWallet(network: network, keychain:try Keychain(strength: wordCount.rawValue))
    }
    
    public static func fromMnemonic(network: Int64 = 0, accountIndex: Int64, words: String) throws  -> CardanoWallet {
        return try CardanoWallet(network: network, accountIndex: accountIndex, mnemonic: words)
    }
    
    public static func fromEntropy(network: Int64 = 0, accountIndex: Int64, entropy: [UInt8]) throws -> CardanoWallet {
        CardanoWallet(network: network, keychain:try Keychain(accountIndex: accountIndex, entropy: entropy, password: nil))
    }
    
    public func getRootPrivateKey() throws -> Bip32PrivateKey {
        return self.rootKeychain.getRootKey()
    }
    
    public func getPaymentPrivateKey(index: Int64 = 0) throws -> Bip32PrivateKey {
        return try self.rootKeychain.getPaymentKey(index: index)
    }
    
    public func getStakingPrivateKey(index: Int64) throws -> Bip32PrivateKey {
        return try self.rootKeychain.getStakingKey(index: index)
    }
    
    public func getStakingAddress(index: Int64 = 0) throws -> StakeAddress {
        return try StakeAddress(network: network, stake_cred: self.getStakingPrivateKey(index: index).toPublic().credential() )
    }
    
    public func addDataProvider(dataProvider: TransactionDataProvider) {
        self.dataProvider = dataProvider
    }
    
    public func signData(data: Data, withAddress: String) throws -> DataSignature? {
        print(">> signData: ", withAddress)
        
        let address = try Address(bech32: withAddress)
        var foundKey: Bip32PrivateKey? = nil
        var index: Int64 = 0
        
        if let paymentCred = try address.getPaymentCred() {
            print(" >> Have a Payment Cred")
            repeat {
                let pk = try self.rootKeychain
                    .getKey(index: index, role: 0)
                if (try pk
                    .toPublic()
                    .credential()
                    .matches(other: paymentCred)) {
                    
                    foundKey = pk
                }
                index = index + 1
            } while (foundKey == nil && index < 20)
        } else {
            
            if let stakingCredential = address.stakingCredential {
                let pk = try self.rootKeychain.getStakingKey(index: 0)
                if (try pk
                    .toPublic()
                    .credential()
                    .matches(other: stakingCredential)) {
                    
                    foundKey = pk
                }
            }
        }
        
        if let foundKey = foundKey {
            return try DataSignature.fromJson(json: try foundKey.toRaw()
                .signData(data: data, address: address))
        }

        return nil
    }
    
    public func signTransaction(transaction: FixedTransaction, utxos: TransactionUnspentOutputs) throws {
        
        let requiredSigners = try transaction.getRequiredSignerKeyHashes(utxos: utxos)
        
        var keysToSignWith: [Bip32PrivateKey] = []
        let stakePrivKey = try self.rootKeychain.getStakingKey(index: 0)
        let stakeKey = try stakePrivKey.toPublic().hash().toHex()
        
        try requiredSigners.forEach {
            let requiredKey = $0.hexEncodedString()
            
            var index: Int64 = 0
            
            if (stakeKey == requiredKey) {
                keysToSignWith.append(stakePrivKey)
                return
            }
            var keyFound = false
            repeat {
                let pk = try self.rootKeychain
                    .getKey(index: index, role: 0)
                if (try pk
                    .toPublic()
                    .hash()
                    .toHex() == requiredKey) {
                    keyFound = true
                    keysToSignWith.append(pk)
                }
                index = index + 1
//                print(" >> Have we found anything: keyFound=\(keyFound) - next index: \(index)")
            } while (!keyFound && index < 20)
        }
        
        try keysToSignWith.forEach { key in
            try key.toRaw().signTxn(txn: transaction)
        }
        
        
    }
    
    public func discoverAccountAddresses() async throws {
        guard let dataProvider = self.dataProvider else {
            throw WalletError.NoDataProviderSet
        }
        
        let stakeAddress = try self.getStakingAddress().asBech32()
        
        let accountAddresses = try await dataProvider.getStakeAccountAddresses(stake_account_address: stakeAddress)
        
        try (0...accountAddresses.count + 20).forEach { index in
            let myCred = try getPaymentPrivateKey(index: Int64(index)).toPublic().credential()
            
            if try accountAddresses.first(where: { if let cred = $0.paymentCredential { try myCred.matches(other: cred) } else { false }  }) != nil {
                try foundAddresses[try myCred.toHex()] = AddressMapping(type: .Payment, index: Int64(index), credHash: myCred.toHex())
            }
        }
        
    }
    
    public func submitTransaction(transaction: FixedTransaction) async throws -> String {
        guard let dataProvider = self.dataProvider else {
            throw WalletError.NoDataProviderSet
        }
        
        return try await dataProvider.submit(transaction: transaction)
    }
    
    public func getMnumonic() -> [String] {
        self.rootKeychain.getMnumonic()
    }
    
    public func newTx() async throws -> TransactionBuilder<NoInputsYet> {
        guard let dataProvider = self.dataProvider else {
            throw WalletError.NoDataProviderSet
        }
        
        let config = try await dataProvider.getTransactionBuilderConfig()
        return try TransactionBuilder(config: config.ptr)
    }
    
    public func newSendAllTx(address_to: Address, utxos: TransactionUnspentOutputs) async throws -> TransactionBatchList {
        guard let dataProvider = self.dataProvider else {
            throw WalletError.NoDataProviderSet
        }
        let config = try await dataProvider.getTransactionBuilderConfig()
        
        return try TransactionBatchList(address: address_to, utxos: utxos, builderConfig: config)
    }
    
    public func getUtxos() async throws -> TransactionUnspentOutputs {
        guard let dataProvider = self.dataProvider else {
            throw WalletError.NoDataProviderSet
        }
        
        return try await dataProvider.getUtxosForMultipleAddresses(addresses: [self.getPaymentAddress().asBech32()])
    }
        
    public func getPaymentAddress(index: Int64 = 0) throws -> Address {
        
        let paymentKeyHash = try self.rootKeychain.getPaymentKey(index: index).toPublic()
        let stakingKeyHash = try self.rootKeychain.getStakingKey(index: 0).toPublic()
        
//        print("Spend > PubKey", try paymentKeyHash.toBech32())
//        print("Stake > PubKey", try stakingKeyHash.toBech32())
        
        return try Address(network: network, paymentCred: paymentKeyHash.credential(), stakingCred: stakingKeyHash.credential())
    }
}

private enum AddressType {
    case Payment
    case Staking
    case DRep
}

private struct AddressMapping: Sendable {
    var type: AddressType
    var index: Int64
    var credHash: String
}





public enum WalletError: Error {
    case NoDataProviderSet
}

public struct DataSignature: Codable {
    var signature: String
    var key: String
    
    public static func fromJson(json: String) throws -> DataSignature {
        guard let jsonData = json.data(using: .utf8) else {
            fatalError("Failed to convert JSON string to Data.")
        }
        return try JSONDecoder().decode(DataSignature.self, from: jsonData)
    }
    
    public func forCip30() throws -> String {
        return String(data: try JSONEncoder().encode(self), encoding: .utf8)!
    }
}
