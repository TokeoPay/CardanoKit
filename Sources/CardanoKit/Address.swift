// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import CSLKit

public class Address {
    internal var ptr: OpaqueRustPointer<CSLKit.Types.CSL_Address>
    
    internal var paymentCredential: Credential? = nil
    internal var stakingCredential: Credential? = nil
    
    public init(bech32: String) throws {
        self.ptr = try CSLKit.addressFromBech32(bech_str_str: bech32)
    }
        
    public init(hex: String) throws {
        self.ptr = try CSLKit.addressFromHex(hex_str_str: hex)
    }
    
    public init(paymentCred: Credential, stakingCred: Credential?) throws {
        self.paymentCredential = paymentCred
        self.stakingCredential = stakingCred
        
        if let stakingCred = stakingCred {
            paymentCred.ptr.debug(prefix: " >> Using >> PaymentCred >")
            stakingCred.ptr.debug(prefix: " >> Using >> StakingCred >")
            let baseAddress = try CSLKit.baseAddressNew(network_long: 0, payment_rptr: paymentCred.ptr, stake_rptr: stakingCred.ptr)
            self.ptr = try CSLKit.baseAddressToAddress(self_rptr: baseAddress)
        } else {
            let ea = try CSLKit.enterpriseAddressNew(network_long: 0, payment_rptr: paymentCred.ptr)
            self.ptr = try CSLKit.enterpriseAddressToAddress(self_rptr: ea)
        }
    }
    
    public func getPaymentCred() throws -> Credential? {
        return Credential(ptr: try CSLKit.addressPaymentCred(self_rptr: self.ptr), keyHash: nil)
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
//        CSLKit.baseAddressNew(network_long: 0, payment_rptr: <#T##OpaqueRustPointer<CSLKit.Types.CSL_Credential>#>, stake_rptr: <#T##OpaqueRustPointer<CSLKit.Types.CSL_Credential>#>)
        return try CSLKit.addressToHex(self_rptr: self.ptr)
    }
}


public class Credential {
    fileprivate var ptr: OpaqueRustPointer<CSLKit.Types.CSL_Credential>
    
    private var keyHash: Ed25519KeyHash? = nil
    
    public static func fromKeyHash(keyHash: Ed25519KeyHash) throws -> Credential {
        let hashPtr = keyHash.ptr
        let cred = try CSLKit.credentialFromKeyhash(hash_rptr: hashPtr)
        cred.debug(prefix: " >> Created Cred")
        hashPtr.debug(prefix: " >> Created Cred >> From >>")
        return Credential(ptr: cred, keyHash: keyHash)
    }
    
    internal init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_Credential>, keyHash: Ed25519KeyHash?) {
        ptr.debug(prefix: " >> CSL_Credential")
        self.keyHash = keyHash
        self.ptr = ptr
    }
    
    public func matches(other: Credential) throws -> Bool {
        let credBytes = try CSLKit.credentialToBytes(self_rptr: self.ptr)
        let otherCredBytes = try CSLKit.credentialToBytes(self_rptr: other.ptr)
        
        print(" credBytes      >> ", credBytes.hexEncodedString())
        print(" otherCredBytes >> ", otherCredBytes.hexEncodedString())
        
        return credBytes == otherCredBytes
    }
}
