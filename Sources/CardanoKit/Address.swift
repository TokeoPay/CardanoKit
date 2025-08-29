// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import CSLKit

public class StakeAddress {
    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_RewardAddress>
    
    init(network: Int64, stake_cred: Credential) throws {
        self.ptr = try CSLKit.stakeAddressNew(network: network, stake_cred_rptr: stake_cred.ptr)
    }
    
    
    public func asBech32() throws -> String {
        return try Address(ptr: CSLKit.stakeAddressToAddress(self_rptr: self.ptr)).asBech32()
    }
    
    public func asHex() throws -> String {
        return try Address(ptr: CSLKit.stakeAddressToAddress(self_rptr: self.ptr)).asHex()
    }
}

public class Address {
    internal var ptr: OpaqueRustPointer<CSLKit.Types.CSL_Address>
    
    internal var paymentCredential: Credential? = nil
    internal var stakingCredential: Credential? = nil
    
    public init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_Address>) {
        self.ptr = ptr
    }
    
    public init(bech32: String) throws {
        self.ptr = try CSLKit.addressFromBech32(bech_str_str: bech32)
    }
        
    public init(hex: String) throws {
        self.ptr = try CSLKit.addressFromHex(hex_str_str: hex)
    }
    
    public init(network: Int64 = 0, paymentCred: Credential, stakingCred: Credential?) throws {
        self.paymentCredential = paymentCred
        self.stakingCredential = stakingCred
        
        if let stakingCred = stakingCred {
//            paymentCred.ptr.debug(prefix: " >> Using >> PaymentCred >")
//            stakingCred.ptr.debug(prefix: " >> Using >> StakingCred >")
            let baseAddress = try CSLKit.baseAddressNew(network_long: network, payment_rptr: paymentCred.ptr, stake_rptr: stakingCred.ptr)
            self.ptr = try CSLKit.baseAddressToAddress(self_rptr: baseAddress)
        } else {
            let ea = try CSLKit.enterpriseAddressNew(network_long: network, payment_rptr: paymentCred.ptr)
            self.ptr = try CSLKit.enterpriseAddressToAddress(self_rptr: ea)
        }
    }
    
    public func getPaymentCred() throws -> Credential? {
        return Credential(ptr: try CSLKit.addressPaymentCred(self_rptr: self.ptr), keyHash: nil)
    }
    
    public func getStakingAddress() throws -> Address? {
        let rewardAddressPtr = try CSLKit.addressExtractRewardAddress(self_rptr: self.ptr)
        
        return try Address(ptr: CSLKit.rewardAddressToAddress(self_rptr: rewardAddressPtr))
    }
    
    public func toBytes() throws -> Data {
        do {
            return try CSLKit.addressToBytes(self_rptr: self.ptr)
        } catch let e {
            print("ERROR", e)
            throw e
        }
    }
    
    public func asBech32() throws -> String {
        return try CSLKit.addressToBech32(self_rptr: self.ptr)
    }
    
    public func asHex() throws -> String {
        return try CSLKit.addressToHex(self_rptr: self.ptr)
    }
}


public class Credential {
    fileprivate var ptr: OpaqueRustPointer<CSLKit.Types.CSL_Credential>
    
    private var keyHash: Ed25519KeyHash? = nil
    
    public static func fromKeyHash(keyHash: Ed25519KeyHash) throws -> Credential {
        let hashPtr = keyHash.ptr
        let cred = try CSLKit.credentialFromKeyhash(hash_rptr: hashPtr)
//        cred.debug(prefix: " >> Created Cred")
//        hashPtr.debug(prefix: " >> Created Cred >> From >>")
        return Credential(ptr: cred, keyHash: keyHash)
    }
    
    internal init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_Credential>, keyHash: Ed25519KeyHash?) {
//        ptr.debug(prefix: " >> CSL_Credential")
        self.keyHash = keyHash
        self.ptr = ptr
    }
    
    public func toHex() throws -> String {
        return try CSLKit.credentialToHex(self_rptr: self.ptr)
    }
    
    public func matches(other: Credential) throws -> Bool {
        let credBytes = try CSLKit.credentialToBytes(self_rptr: self.ptr)
        let otherCredBytes = try CSLKit.credentialToBytes(self_rptr: other.ptr)
        
        print(" credBytes      >> ", credBytes.hexEncodedString())
        print(" otherCredBytes >> ", otherCredBytes.hexEncodedString())
        
        return credBytes == otherCredBytes
    }
}
