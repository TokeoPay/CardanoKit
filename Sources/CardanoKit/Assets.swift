//
//  Assets.swift
//  CardanoKit
//
//  Created by Gavin Harris on 21/7/2025.
//

import Foundation
import CSLKit

public class Policy {
    
    fileprivate var ptr: OpaqueRustPointer<CSLKit.Types.CSL_ScriptHash>
    
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_ScriptHash>) {
        self.ptr = ptr
    }
}

public class MultiAsset {
    fileprivate var ptr: OpaqueRustPointer<CSLKit.Types.CSL_MultiAsset>
    
    public init() throws {
        self.ptr = try CSLKit.multiAssetNew()
    }
    
    public func insert(policy: Policy, assets: Assets) throws {
        // This method mutates the internal Rust BTreeMap
        let _oldValue = try CSLKit.multiAssetInsert(self_rptr: self.ptr, policy: policy.ptr, asset_rptr: assets.ptr)
    }
    
    public func get(policy: Policy) throws -> Assets {
        let assets = try CSLKit.multiAssetGet(self_rptr: self.ptr, policy: policy.ptr)
        
        return Assets(ptr: assets)
    }
    
    public func length() throws -> Int64 {
        return try CSLKit.multiAssetLen(self_rptr: self.ptr)
    }
    
}

public class Assets {
    fileprivate var ptr: OpaqueRustPointer<CSLKit.Types.CSL_Assets>
    
    fileprivate init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_Assets>) {
        self.ptr = ptr
    }
    
    public init() throws {
        ptr = try CSLKit.assetsNew()
    }
    
    public func add(assetName: String, amount: Int64) throws {
        let assetName = try CSLKit.assetNameNew(name_data: Data(assetName.utf8))
        let amountBigNum = try CSLKit.bigNumFromStr(string_str: "\(amount)")
        let _oldValue = try CSLKit.assetsInsert(self_rptr: self.ptr, asset_rptr: assetName, value_int: amountBigNum)
    }
    
    public func get(assetName: String) throws -> Int64? {
        let assetName = try CSLKit.assetNameNew(name_data: Data(assetName.utf8))
        let amt = try CSLKit.assetsGet(self_rptr: self.ptr, asset_rptr: assetName)
        let amtStr = try CSLKit.bigNumToStr(self_rptr: amt)
        
        return Int64(amtStr)
    }
    
    public func length() throws -> Int64 {
        return try CSLKit.assetsLen(self_rptr: self.ptr)
    }
}
