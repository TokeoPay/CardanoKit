// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import CSLKit

public struct Address {
    private var ptr: OpaqueRustPointer<CSLKit.Types.CSL_Address>
    
    public init(bech32: String) throws {
        self.ptr = try CSLKit.addressFromBech32(bech_str_str: bech32)
    }
    
    public init(hex: String) throws {
        self.ptr = try CSLKit.addressFromHex(hex_str_str: hex)
    }
    
    public func getPaymentCred() throws -> OpaqueRustPointer<CSLKit.Types.CSL_PaymentCred> {
        return try CSLKit.addressPaymentCred(self_rptr: self.ptr)
    }
    
    public func asBech32() throws -> String {
        return try CSLKit.addressToBech32(self_rptr: self.ptr)
    }
    
    public func asHex() throws -> String {
        return try CSLKit.addressToHex(self_rptr: self.ptr)
    }
}
