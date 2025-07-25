//
//  Keychain.swift
//  CardanoKit
//
//  Created by Gavin Harris on 19/6/2025.
//

import Foundation
import Bip39
import CSLKit

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}

public class KeyPair {
    let publicKey: OpaqueRustPointer<CSLKit.Types.CSL_Bip32PublicKey>
    fileprivate let privateKey: OpaqueRustPointer<CSLKit.Types.CSL_Bip32PrivateKey>
    
    init(entropy: Data) throws {
        self.privateKey = try CSLKit.bip32PrivateKeyFromBip39Entropy(entropy_data: Data(entropy), password_data: Data())
        
        print(" >>  entropy >> privateKey", try CSLKit.bip32PrivateKeyToBech32(self_rptr: self.privateKey))
        
//        self.privateKey = try CSLKit.privateKeyFromNormalBytes(bytes_data: Data(entropy))
        self.publicKey = try CSLKit.bip32PrivateKeyToPublic(self_rptr: self.privateKey)
        
        
        
//        try CSLKit.bip32PrivateKeyDerive(self_rptr: self.bip32PrivateKey, index_u32: 1852)
    }
    
    public func privateKeyBech32() throws -> String {
        return try CSLKit.bip32PrivateKeyToBech32(self_rptr: self.privateKey)
    }
    
    public func vkeyWitness(transactionHash: OpaqueRustPointer<CSLKit.Types.CSL_TransactionHash>) throws {
//        CSLKit.vkeywitnessNew(vkey_rptr: <#T##OpaqueRustPointer<CSLKit.Types.CSL_Vkey>#>, signature_rptr: <#T##OpaqueRustPointer<CSLKit.Types.CSL_Ed25519Signature>#>)
    }
}


public class Bip32PublicKey {
    private var retainedSourceParent: Bip32PrivateKey? = nil
    private var ptr: OpaqueRustPointer<CSLKit.Types.CSL_Bip32PublicKey>
    
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_Bip32PublicKey>, parent: Bip32PrivateKey) {
        ptr.debug(prefix: "Bip32PublicKey")
        self.retainedSourceParent = parent
        self.ptr = ptr
    }
    
    public func hash() throws -> Ed25519KeyHash {
        let rawKey = try CSLKit.bip32PublicKeyToRawKey(self_rptr: self.ptr)
        return Ed25519KeyHash(ptr: try CSLKit.publicKeyHash(self_rptr: rawKey), parent: self)
    }
    
    public func credential() throws -> Credential {
        return try Credential.fromKeyHash(keyHash: self.hash())
    }
    
    public func toBech32() throws -> String {
        try CSLKit.bip32PublicKeyToBech32(self_rptr: self.ptr)
    }
}

extension Bip32PublicKey: Ed25519KeyHashParent {}

public protocol Ed25519KeyHashParent: AnyObject {
}


public class Ed25519KeyHash {
    internal var ptr: OpaqueRustPointer<CSLKit.Types.CSL_Ed25519KeyHash>
    private var retainedSourceParent: Ed25519KeyHashParent? = nil
    
    internal init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_Ed25519KeyHash>, parent: Ed25519KeyHashParent) {
        ptr.debug(prefix: "CSL_Ed25519KeyHash")
        self.retainedSourceParent = parent
        self.ptr = ptr
    }
    
    public func toHex() throws -> String {
        return try CSLKit.ed25519KeyHashToHex(self_rptr: self.ptr)
    }
}

public class Bip32PrivateKey {
    private var ptr: OpaqueRustPointer<CSLKit.Types.CSL_Bip32PrivateKey>
    
    convenience init(bech32: String) throws {
        self.init(ptr: try CSLKit.bip32PrivateKeyFromBech32(bech32_str_str: bech32))
    }
    
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_Bip32PrivateKey>) {
        ptr.debug(prefix: "Bip32PrivateKey")
        self.ptr = ptr
    }
    
    public func toPublic() throws -> Bip32PublicKey {
        return try Bip32PublicKey(ptr: CSLKit.bip32PrivateKeyToPublic(self_rptr: self.ptr), parent: self)
    }
    
    public func toString() throws -> String {
        return try CSLKit.bip32PrivateKeyToBech32(self_rptr: self.ptr)
    }
    
    public func toRaw() throws -> PrivateKey {
        let privateKey = try CSLKit.bip32PrivateKeyToRawKey(self_rptr: self.ptr)
        return PrivateKey(ptr: privateKey, parent: self)
    }
        
    public func derive(index: Int64, harden: Bool) throws -> Bip32PrivateKey {
        
        let index = if harden {
            Bip32PrivateKey._harden(index: index)
        } else {
            index
        }
        
//        print("  >>  > Derive ", index)
        
        let derivedKeyPtr = try CSLKit.bip32PrivateKeyDerive(self_rptr: self.ptr, index_u32: index)
        
        let derivedKey = Bip32PrivateKey(ptr: derivedKeyPtr)
        
//        print("  >>  > Derive > Key > ", try derivedKey.toString())
        
        return derivedKey
    }
    
    private static let harden: Int64 = 0x80000000
    private static func _harden(index: Int64) -> Int64 {
        return index | harden
    }
}

public class Keychain {
    
    private var mnumonic: [String]
    public var rootKeyPair: KeyPair
    private var accountBaseKey: Bip32PrivateKey
    private var accountIndex: Int64 = 0
    
    public convenience init(strength: Int) throws {
        let mnumonic = try Bip39.Mnemonic(strength: strength)
        try self.init(accountIndex: 0, mnemonic: mnumonic.mnemonic())
        
    }
    
    public convenience init() throws {
        try self.init(strength: 256)
    }
    
    public convenience init(accountIndex: Int64, mnemonic: [String], password: Data? = Data()) throws {
        let entropy = try Bip39.Mnemonic(mnemonic: mnemonic).entropy
        try self.init(accountIndex: accountIndex, entropy: entropy, password: password)
        self.mnumonic = mnemonic
    }
    
    public init(accountIndex: Int64, entropy: [UInt8], password: Data? = Data()) throws {
        self.rootKeyPair = try KeyPair(entropy: Data(entropy))
        
        self.mnumonic = try Bip39.Mnemonic(entropy: entropy).mnemonic()
        
        self.accountIndex = accountIndex
        
        let baseKey = Bip32PrivateKey(ptr: self.rootKeyPair.privateKey)
//        print(" >> baseKey >> bech32", try baseKey.toString())
        
        self.accountBaseKey = try baseKey
            .derive(index: 1852, harden: true)                 // purpose'
            .derive(index: 1815, harden: true)                 // coin_type'
            .derive(index: self.accountIndex, harden: true)    // account'
    }
    
    public func getMnumonic() -> [String] {
        return self.mnumonic
    }
        
    public func getRootKey() -> Bip32PrivateKey {
        return self.accountBaseKey
    }
    
    public func getKey(index: Int64, role: Int64) throws -> Bip32PrivateKey {
        return try self.accountBaseKey
            .derive(index: role, harden: false) // role
            .derive(index: index, harden: false)
    }
    
    public func getPaymentKey(index: Int64) throws -> Bip32PrivateKey {
        return try getKey(index: index, role: 0)
    }
    
    public func getChangeKey(index: Int64) throws -> Bip32PrivateKey {
        return try getKey(index: index, role: 1)
    }
    
    public func getStakingKey(index: Int64) throws -> Bip32PrivateKey {
        return try getKey(index: index, role: 2)
    }
    
    public func getDRepKey(index: Int64) throws -> Bip32PrivateKey {
        return try getKey(index: index, role: 3)
    }
        
}

public class PrivateKey {
    private var ptr: OpaqueRustPointer<CSLKit.Types.CSL_PrivateKey>
    private var parent: Bip32PrivateKey?
    
    internal init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_PrivateKey>, parent: Bip32PrivateKey? = nil) {
        self.ptr = ptr
        self.parent = parent
    }
    
    public func signData(data: Data, address: Address) throws -> String {
        
        return try CSLKit.privateKeyCose1SignData(self_rptr: self.ptr, addr_ptr: address.ptr, bytes_data: data)

//        return try MsgSigningKit.cose1SignData(pk: self.ptr, data: data)
//        return Signature(ptr: try CSLKit.privateKeySign(self_rptr: self.ptr, msg_data: data), parent: self)
    }
    
}

public class Signature {
    private var parent: PrivateKey?
    private var ptr: OpaqueRustPointer<CSLKit.Types.CSL_Signature>
    
    internal init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_Signature>, parent: PrivateKey? = nil) {
        self.parent = parent
        self.ptr = ptr
    }
}




public class ProtocolParams {
    
    private var ptr: OpaqueRustPointer<CSLKit.Types.CSL_None> // PPValues
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_None>) {
        self.ptr = ptr
    }
    
//    init(fromDataProvider: DataProvider) {
//        fromDataProvider.getProtocolParams()
//    }
}

protocol DataProvider {
    func getProtocolParams() -> String
    func getUtxo() -> String
}

extension ProtocolParams {
    
    public static func build() {
        
    }
    
//    init(fromBlockfrostResult: String) {
//        // Call to BF
//        // Populate all the Params
//    }
}




