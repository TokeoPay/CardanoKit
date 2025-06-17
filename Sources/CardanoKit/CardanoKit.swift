// The Swift Programming Language
// https://docs.swift.org/swift-book
import CSLKit
import Foundation

public struct Address {
    private var ptr: OpaqueRustPointer<CSLKit.CSL_Address>
    
    init(bech32: String) throws {
        self.ptr = try CSLKit.addressFromBech32(bech_str_str: bech32)
    }
    
    public func asBech32() throws -> String {
        return try CSLKit.addressToBech32(self_rptr: self.ptr)
    }
    
    public func asHex() throws -> String {
        return try CSLKit.addressToHex(self_rptr: self.ptr)
    }
}
