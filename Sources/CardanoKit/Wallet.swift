//
//  Wallet.swift
//  CardanoKit
//
//  Created by Gavin Harris on 15/7/2025.
//

import Foundation

public enum WordCount: Int {
    case PISS_WEAK = 128
    case LITTLE_BETTER = 160
    case NEARLY_THERE = 192
    case SHOULD_BE_GOOD = 224
    case SOLID = 256
}

public class CardanoWallet {
    private var rootKeychain: Keychain
    
    init(keychain: Keychain) {
        self.rootKeychain = keychain
        
//        self.rootKeychain.getPaymentKey(index: 0)
        
//        keychain.rootKeyPair.
    }
    
    convenience init() throws {
        try self.init(keychain: Keychain(strength: 256))
    }
    
    convenience init(accountIndex: Int64, mnemonic: String) throws {
        try self.init(keychain: Keychain(accountIndex: accountIndex, mnemonic: mnemonic.components(separatedBy: " ")))
    }
    
    public static func generate(accountIndex: Int64, wordCount: WordCount) throws -> CardanoWallet {
        CardanoWallet(keychain:try Keychain(strength: wordCount.rawValue))
    }
    
    public static func fromMnemonic(accountIndex: Int64, words: String) throws  -> CardanoWallet {
        return try CardanoWallet(accountIndex: accountIndex, mnemonic: words)
    }
    
    public static func fromEntropy(accountIndex: Int64, entropy: [UInt8]) throws -> CardanoWallet {
        CardanoWallet(keychain:try Keychain(accountIndex: accountIndex, entropy: entropy, password: nil))
    }
    
    public func getRootPrivateKey() throws -> Bip32PrivateKey {
        return self.rootKeychain.getRootKey()
    }
    
    public func getPaymentPrivateKey(index: Int64 = 0) throws -> Bip32PrivateKey {
        return try self.rootKeychain.getPaymentKey(index: index)
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
                print(" >> Have we found anything: \(foundKey != nil) - next index: \(index)")
            } while (foundKey == nil && index < 2000)
        } else {
            
            if let stakingCredential = address.stakingCredential {
                print(" >> Have a Staking Cred")
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
         
            print("Found the Private Key")
            return try DataSignature.fromJson(json: try foundKey.toRaw()
                .signData(data: data, address: address))
        }

        return nil
    }
    
    public func getMnumonic() -> [String] {
        self.rootKeychain.getMnumonic()
    }
        
    public func getPaymentAddress(index: Int64 = 0) throws -> Address {
        
        let paymentKeyHash = try self.rootKeychain.getPaymentKey(index: index).toPublic()
        let stakingKeyHash = try self.rootKeychain.getStakingKey(index: 0).toPublic()
        
//        print("Spend > PubKey", try paymentKeyHash.toBech32())
//        print("Stake > PubKey", try stakingKeyHash.toBech32())
        
        return try Address(paymentCred: paymentKeyHash.credential(), stakingCred: stakingKeyHash.credential())
    }
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
}
