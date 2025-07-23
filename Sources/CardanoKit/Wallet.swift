//
//  Wallet.swift
//  CardanoKit
//
//  Created by Gavin Harris on 15/7/2025.
//

public class CardanoWallet {
    private var rootKeychain: Keychain
    
    init(keychain: Keychain) {
        self.rootKeychain = keychain
        
//        self.rootKeychain.getPaymentKey(index: 0)
        
//        keychain.rootKeyPair.
    }
    
    convenience init() throws {
        try self.init(keychain: Keychain(strength: 512))
    }
    
    convenience init(accountIndex: Int64, mnemonic: String) throws {
        try self.init(keychain: Keychain(accountIndex: accountIndex, mnemonic: mnemonic.components(separatedBy: " ")))
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
    
    public func getPaymentAddress(index: Int64 = 0) throws -> Address {
        
        let paymentKeyHash = try self.rootKeychain.getPaymentKey(index: 0).toPublic()
        let stakingKeyHash = try self.rootKeychain.getStakingKey(index: 0).toPublic()
        
//        print("Spend > PubKey", try paymentKeyHash.toBech32())
//        print("Stake > PubKey", try stakingKeyHash.toBech32())
        
        return try Address(paymentCred: paymentKeyHash.credential(), stakingCred: stakingKeyHash.credential())
    }
}
