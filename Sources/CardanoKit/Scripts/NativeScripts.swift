//
//  NativeScripts.swift
//  CardanoKit
//
//  Created by Gavin Harris on 22/9/2025.
//

import Foundation
import CSLKit

public class NativeScript {
    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_NativeScript>
    
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_NativeScript>) {
        self.ptr = ptr
    }
    
    /**
     Example timelock
     
     ```JSON
     {
         "ScriptAll": {
             "native_scripts": [
                 {
                    "TimelockExpiry": {
                        "slot": "93121875"
                    }
                 },
                 {
                    "ScriptPubkey": {
                        "addr_keyhash": "24c75fefdf94496f8fd386648bc5edc20a7469282c5359c9745abaca"
                    }
                 }
             ]
         }
     }
     ```
     */
    init(json: String) throws {
        self.ptr = try CSLKit.nativeScriptFromJson(json_str: json)
    }
}

public class NativeScripts {
    
    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_NativeScripts>
    
//    init() throws {
//        self.ptr = try CSLKit.nativeScriptsNew()
//    }
    
    public init(json: String) throws {
        self.ptr = try CSLKit.nativeScriptsFromJson(json_str: json)
    }
}
