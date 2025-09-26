//
//  Assets.swift
//  CardanoKit
//
//  Created by Gavin Harris on 21/7/2025.
//

import Foundation
import CSLKit

extension String {
    /// Convert a hex string into `Data`
    /// Returns `nil` if the string is not valid hex
    func hexToData() -> Data? {
        var data = Data(capacity: count / 2)
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            guard let match = match else { return }
            let byteString = (self as NSString).substring(with: match.range)
            guard let num = UInt8(byteString, radix: 16) else { return }
            data.append(num)
        }
        return data.isEmpty ? nil : data
    }
}

public class Policy {
    
    fileprivate var ptr: OpaqueRustPointer<CSLKit.Types.CSL_PolicyID>
    
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_PolicyID>) {
        self.ptr = ptr
    }
    
    init(hex: String) throws {
        self.ptr = try CSLKit.policyIDFromHex(hex_str_str: hex)
    }
    
    public func toHex() throws -> String {
        return try CSLKit.policyIDToHex(self_rptr: self.ptr)
    }
}

public class MultiAsset: CustomDebugStringConvertible {
    public var debugDescription: String {
        do {
            return try self.toJson()
        } catch (let error) {
            return error.localizedDescription
        }
    }
    
    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_MultiAsset>
    
    public init(from: [String: Int64]) throws {
        
        self.ptr = try CSLKit.multiAssetNew()
        
        try normalize(from).forEach { (p, a) in
            let policy = try Policy(hex: p)
            
            let assets = try Assets()
            try a.forEach { (assetName, amount) in
                _ = try assets.add(assetNameHex: assetName, amount: amount)
                
//                if (assetName == "") {
//                    _ = try assets.add(assetName: assetName, amount: amount)
//                } else {
//                    _ = try assets.add(assetNameHex: assetName, amount: amount)
//                }
            }
            
            _ = try CSLKit.multiAssetInsert(self_rptr: self.ptr, policy: policy.ptr, asset_rptr: assets.ptr)
        }
                
    }
    
    public init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_MultiAsset>?) throws {
        if let ptr {
            self.ptr = ptr
        } else {
            self.ptr = try CSLKit.multiAssetNew()
        }
    }
    
    public init() throws {
        self.ptr = try CSLKit.multiAssetNew()
    }
    
    public func insert(policy: Policy, assets: Assets) throws {
        // This method mutates the internal Rust BTreeMap
        _ = try CSLKit.multiAssetInsert(self_rptr: self.ptr, policy: policy.ptr, asset_rptr: assets.ptr)
    }
    
    public func get(policy: Policy) throws -> Assets {
        let assets = try CSLKit.multiAssetGet(self_rptr: self.ptr, policy: policy.ptr)
        if let assets {
            return Assets(ptr: assets)
        } else {
            return try Assets()
        }
    }
    
    public func length() throws -> Int64 {
        return try CSLKit.multiAssetLen(self_rptr: self.ptr)
    }
    
    public func toJson() throws -> String {
        return try CSLKit.multiAssetToJson(self_rptr: self.ptr)
    }
    
    public func toValue(lovelace: Int64) throws -> Value {
        
        let valuePtr = try CSLKit.valueNewFromAssets(multiasset_rptr: self.ptr)
        _ = try CSLKit.valueSetCoin(self_rptr: valuePtr, coin_rptr: CSLKit.bigNumFromStr(string_str: "\(lovelace)"))
        
        return try Value(ptr: valuePtr)
        
    }
}

public enum AssetNameError: Error {
    case NameNotHex
}

public class Assets {
    fileprivate var ptr: OpaqueRustPointer<CSLKit.Types.CSL_Assets>
    
    fileprivate init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_Assets>) {
        self.ptr = ptr
    }
    
    public init() throws {
        ptr = try CSLKit.assetsNew()
    }
    
    public func add(assetNameHex: String, amount: Int64) throws {
        
        guard let assetNameData = Data(hex: assetNameHex) else {
            throw AssetNameError.NameNotHex
        }
        
        let assetName = try CSLKit.assetNameNew(name_data: assetNameData)
        
        _ = try CSLKit.assetNameToHex(self_rptr: assetName)
        
        let amountBigNum = try CSLKit.bigNumFromStr(string_str: "\(amount)")
        _ = try CSLKit.assetsInsert(self_rptr: self.ptr, asset_rptr: assetName, value_int: amountBigNum)
    }
    
    public func add(assetName: String, amount: Int64) throws {
        let assetName = try CSLKit.assetNameNew(name_data: Data(assetName.utf8))
        let amountBigNum = try CSLKit.bigNumFromStr(string_str: "\(amount)")
        _ = try CSLKit.assetsInsert(self_rptr: self.ptr, asset_rptr: assetName, value_int: amountBigNum)
    }
    
    public func get(assetName: String) throws -> Int64? {
        let assetName = try CSLKit.assetNameNew(name_data: Data(assetName.utf8))
        let amt = try CSLKit.assetsGet(self_rptr: self.ptr, asset_rptr: assetName)
        let amtStr = try CSLKit.bigNumToStr(self_rptr: amt)
        
        return Int64(amtStr)
    }
    
    public func toMap() async throws -> [Asset: Int64] {
        var dict: [Asset: Int64] = [:]
        for try await (asset, amount) in assets() {
            dict[asset, default: 0] += amount
        }
        return dict
    }
    
    public func length() throws -> Int64 {
        return try CSLKit.assetsLen(self_rptr: self.ptr)
    }
    //TODO: This should be on MultiAssets and not Assets
    public func assets() -> AsyncThrowingStream<(Asset, Int64), Error> {
        AsyncThrowingStream { continuation in
            do {
                let assetNames = try AssetNames(ptr: CSLKit.assetsGetAssetNames(self_rptr: self.ptr))
                try assetNames.forEach { assetName in
                    let amountPtr = try CSLKit.assetsGet(self_rptr: self.ptr, asset_rptr: assetName.ptr)
                    
                    guard assetName.name.count >= 56 else { return }
                    let policyHex = String(assetName.name.prefix(56))
                    let nameHex = String(assetName.name.dropFirst(56))
                    
                    let p = try PolicyId(policyId: policyHex)
                    
                    let fingerprint = try CSLKit.assetFingerprint(assetName_ptr: assetName.ptr, policy_ptr: p.ptr)
                    
                    if let amount = try Int64(CSLKit.bigNumToHex(self_rptr: amountPtr), radix: 16) {
                        continuation.yield((Asset(policy: policyHex, name: nameHex, fingerprint: fingerprint), amount))
                    } else {
                        continuation.yield((Asset(policy: policyHex, name: nameHex, fingerprint: fingerprint), 0))
                    }
                }
                
                continuation.finish()
            } catch (let error) {
                continuation.finish(throwing: error)
            }
        }
    }
    
}

public class PolicyId {
    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_PolicyID>
    
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_PolicyID>) {
        self.ptr = ptr
    }
    
    init(policyId: String) throws {
        self.ptr = try CSLKit.policyIDFromHex(hex_str_str: policyId)
    }
}

public class AssetName {
    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_AssetName>
    var name: String
    
    public init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_AssetName>) throws {
        self.ptr = ptr
        self.name = try CSLKit.assetNameToHex(self_rptr: self.ptr)
    }
    
    public convenience init(name: Data) throws {
        try self.init(ptr: try CSLKit.assetNameNew(name_data: name))
    }
    
    public func toJson() throws -> String {
        return try CSLKit.assetNameToJson(self_rptr: self.ptr)
    }
}

public class AssetNames: Sequence {
    
    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_AssetNames>
    var length: Int64 = 0
    
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_AssetNames>) throws {
        self.ptr = ptr
        let len = try CSLKit.assetNamesLen(self_rptr: self.ptr)
        self.length = len
    }
    
    public func makeIterator() -> Iterator {
        return Iterator(parent: self)
    }
    
    public struct Iterator: IteratorProtocol {
        public typealias Element = AssetName
        private var currentIndex: Int64 = 0
        private let parent: AssetNames
        
        init(parent: AssetNames) {
            self.parent = parent
        }
        
        public mutating func next() -> AssetName? {
            guard currentIndex < parent.length else {
                return nil
            }
            let idx = currentIndex
            currentIndex += 1
            do {
                return try AssetName(ptr: try CSLKit.assetNamesGet(self_rptr: parent.ptr, index: idx))
            } catch {
                // A real unexpected error: crash or log, but don’t silently
                // terminate the seq here unless that’s truly what you want.
                fatalError("Rust threw when fetching AssetName[\(idx)]: \(error)")
            }
        }
    }
}
