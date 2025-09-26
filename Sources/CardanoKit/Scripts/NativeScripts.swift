//
//  NativeScripts.swift
//  CardanoKit
//
//  Created by Gavin Harris on 22/9/2025.
//

import Foundation
import CSLKit

enum Script: Codable {
    case sig(String)
    case atLeast(required: Int, scripts: [Script])
    case all([Script])
    case any([Script])
    case after(UInt)
    case before(UInt)
    
    enum CodingKeys: String, CodingKey {
        case type
        case scripts
        case keyHash
        case required
        case slot
        case before
        
        case pubKeyHash, all, any, invalidBefore, invalidHereafter
    }
    
    // Custom decoding (handles recursive structure)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // --- FORMAT 1: has "type" ---
        if container.contains(.type) {
            let type = try container.decode(String.self, forKey: .type)
            
            switch type {
            case "sig":
                self = .sig(try container.decode(String.self, forKey: .keyHash))
                
            case "atLeast":
                let req = try container.decode(Int.self, forKey: .required)
                let scripts = try container.decode([Script].self, forKey: .scripts)
                self = .atLeast(required: req, scripts: scripts)
                
            case "all":
                let scripts = try container.decode([Script].self, forKey: .scripts)
                self = .all(scripts)
                
            case "any":
                let scripts = try container.decode([Script].self, forKey: .scripts)
                self = .any(scripts)
                
            case "after":
                self = .after(try container.decode(UInt.self, forKey: .slot))
                
            default:
                throw DecodingError.dataCorruptedError(
                    forKey: .type,
                    in: container,
                    debugDescription: "Unknown script type: \(type)"
                )
            }
            return
        }
        
        // --- FORMAT 2: key-based ---
        if let keyHash = try? container.decode(String.self, forKey: .pubKeyHash) {
            self = .sig(keyHash)
        } else if let scripts = try? container.decode([Script].self, forKey: .all) {
            self = .all(scripts)
        } else if let scripts = try? container.decode([Script].self, forKey: .any) {
            self = .any(scripts)
        } else if let before = try? container.decode(UInt.self, forKey: .invalidBefore) {
            self = .before(before)
        } else if let after = try? container.decode(UInt.self, forKey: .invalidHereafter) {
            self = .after(after)
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown script format"
            )
        }
    }
    
    // Won’t be used directly (we’ll provide custom encoder later)
    func encode(to encoder: Encoder) throws {
        fatalError("Encoding not implemented because conversion is custom.")
    }
}
extension Script {
    func toTargetFormat() -> Any {
        switch self {
        case .sig(let keyHash):
            return [
                "ScriptPubkey": [
                    "addr_keyhash": keyHash
                ]
            ]
        
        case .before(let slot):
            return [
                "TimelockExpiry": [
                    "slot": "\(slot)"
                ]
            ]
            
        case .after(let slot):
            return [
                "TimelockStart": [
                    "slot": "\(slot)"
                ]
            ]
            
        case .atLeast(let required, let scripts):
            return [
                "ScriptNOfK": [
                    "n": required,
                    "native_scripts": scripts.map { $0.toTargetFormat() }
                ]
            ]
            
        case .all(let scripts):
            return [
                "ScriptAll": [
                    "native_scripts": scripts.map { $0.toTargetFormat() }
                ]
            ]
            
        case .any(let scripts):
            return [
                "ScriptAny": [
                    "native_scripts": scripts.map { $0.toTargetFormat() }
                ]
            ]
        }
    }
}


public enum NativeScriptError: Error {
    case InvalidJson
}


public class NativeScript {
    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_NativeScript>
    
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_NativeScript>) {
        self.ptr = ptr
    }
    
    public convenience init(hex: String) throws {
        try self.init(ptr: CSLKit.nativeScriptFromHex(hex_str_str: hex))
    }
    
    public convenience init(cardanoScanJson: String) throws {
        
        let data = cardanoScanJson.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let script = try decoder.decode(Script.self, from: data)
        
        let transformed = script.toTargetFormat()
        let resultData = try JSONSerialization.data(withJSONObject: transformed, options: .prettyPrinted)
        guard let resultString = String(data: resultData, encoding: .utf8) else {
            throw NativeScriptError.InvalidJson
        }
                
        try self.init(json: resultString)
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
    
    public func toCredential() throws -> Credential {
        return try Credential(
            ptr: CSLKit.credentialFromScripthash(hash_rptr: self.toHash().ptr ),
            keyHash: nil
        )
    }
    
    public func toJson() throws -> String {
        return try CSLKit.nativeScriptToJson(self_rptr: self.ptr)
    }
    
    public func toHash() throws -> ScriptHash {
        return try ScriptHash(ptr: CSLKit.nativeScriptHash(self_ptr: self.ptr))
    }
}

public class ScriptHash {
    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_ScriptHash>
                                
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_ScriptHash>) {
        self.ptr = ptr
    }
    
    public func toHex() throws -> String {
        return try CSLKit.scriptHashToHex(self_rptr: self.ptr)
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
