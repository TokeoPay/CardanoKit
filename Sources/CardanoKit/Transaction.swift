//
//  Transaction.swift
//  CardanoKit
//
//  Created by Gavin Harris on 28/7/2025.
//

import Foundation
import CSLKit


public class FixedTransaction {
    internal var ptr: OpaqueRustPointer<CSLKit.Types.CSL_FixedTransaction>
    
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_FixedTransaction>) {
        self.ptr = ptr
    }
    
    public static func fromBytes(data: Data) throws -> FixedTransaction {
        return FixedTransaction(ptr: try CSLKit.fixedTransactionFromBytes(bytes_data: data))
    }
    
    public static func fromHex(hex: String) throws -> FixedTransaction {
        return FixedTransaction(ptr: try CSLKit.fixedTransactionFromHex(hex_str_str: hex))
    }
    
    public func toHex() throws -> String {
        return try CSLKit.fixedTransactionToHex(self_rptr: self.ptr)
    }
    
    public func hash() throws -> String {
        return try CSLKit.transactionHashToHex(self_rptr: CSLKit.fixedTransactionTransactionHash(self_rptr: self.ptr))
    }
    
    public func getRequiredSignerKeyHashes(utxos: TransactionUnspentOutputs) throws -> [Data] {
        return try CSLKit.fixedTransactionGetAllSigners(self_rptr: self.ptr, inputs_rptr: utxos.ptr)
    }
    
    public func getFee() throws -> Int64? {
        let feeBigNum = try CSLKit.fixedTransactionFee(self_rptr: self.ptr)
        return Int64(try CSLKit.bigNumToStr(self_rptr: feeBigNum))
    }
}


public class TransactionUnspentOutputs {
    fileprivate var ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionUnspentOutputs>
    
    public init() throws {
        self.ptr = try CSLKit.transactionUnspentOutputsNew()
    }
    
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionUnspentOutputs>) {
        self.ptr = ptr
    }
    
    public func addUtxo(utxo: TransactionUnspentOutput) throws {
        try CSLKit.transactionUnspentOutputsAdd(self_rptr: self.ptr, utxo_rptr: utxo.ptr)
    }
    
    
}

public class TransactionUnspentOutput {
    fileprivate var ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionUnspentOutput>
    
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionUnspentOutput>) {
        self.ptr = ptr
    }
    
    public static func fromBytes(data: Data) throws -> TransactionUnspentOutput {
        return try TransactionUnspentOutput(ptr: CSLKit.transactionUnspentOutputFromBytes(bytes_data: data))
    }
    public static func fromHex(hex: String) throws -> TransactionUnspentOutput {
        return try TransactionUnspentOutput(ptr: CSLKit.transactionUnspentOutputFromHex(hex_str_str: hex))
    }
    
}
