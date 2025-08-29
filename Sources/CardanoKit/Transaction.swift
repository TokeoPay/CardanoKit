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
    
    init(hex: String) throws {
        self.ptr = try CSLKit.fixedTransactionFromHex(hex_str_str: hex)
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
    
    public func getBody() throws -> TransactionBody {
        let txBodyPtr = try CSLKit.fixedTransactionBody(self_rptr: self.ptr)
        
        return TransactionBody(ptr: txBodyPtr)
    }
}

public class FixedTransactionBody {
    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_FixedTransactionBody>
    
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_FixedTransactionBody>) {
        self.ptr = ptr
    }
    
    public func toRawBytes() throws -> Data {
//        self.ptr.debug(prefix: " >> FixedTransactionBody.toRawBytes()")
        return try CSLKit.fixedTransactionBodyOriginalBytes(self_rptr: self.ptr)
    }
}

public class TransactionBody {
    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionBody>
    
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionBody>) {
        self.ptr = ptr
    }
    
    public init(bytes: Data) throws {
        self.ptr = try CSLKit.transactionBodyFromBytes(bytes_data: bytes)
    }
    
    public func inputs() throws -> TransactionInputs {
        return TransactionInputs(ptr: try CSLKit.transactionBodyInputs(self_rptr: self.ptr))
    }
    
    public func outputs() throws -> TransactionOutputs {
        return try TransactionOutputs(ptr: CSLKit.transactionBodyOutputs(self_rptr: self.ptr))
    }
}

public class TransactionOutputs: Sequence {
    
    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionOutputs>
    var length: Int64
    
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionOutputs>) {
        self.ptr = ptr
        self.length = try! CSLKit.transactionOutputsLen(self_rptr: self.ptr)
    }
    
    public func makeIterator() -> Iterator {
        return Iterator(parent: self)
    }
    
    public struct Iterator: IteratorProtocol {
        public typealias Element = TransactionOutput
        private var currentIndex = 0
        private let parent: TransactionOutputs
        
        init(parent: TransactionOutputs) {
            self.parent = parent
        }
        
        public mutating func next() -> TransactionOutput? {
            guard currentIndex < parent.length else {
                return nil
            }
            let idx = currentIndex
            currentIndex += 1
            do {
                return TransactionOutput(ptr: try CSLKit.transactionOutputsGet(self_rptr: parent.ptr, index_long: Int64(idx)))
            } catch {
                // A real unexpected error: crash or log, but don’t silently
                // terminate the seq here unless that’s truly what you want.
                fatalError("Rust threw when fetching tx output[\(idx)]: \(error)")
            }
        }
    }
}

public class TransactionInputs: Sequence {
       
    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionInputs>
    var length: Int64
    
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionInputs>) {
        self.ptr = ptr
        self.length = try! CSLKit.transactionInputsLen(self_rptr: ptr)
    }
    
    public func makeIterator() -> Iterator {
        return Iterator(parent: self)
    }
    
    public struct Iterator: IteratorProtocol {
        public typealias Element = TransactionInput
        private var currentIndex = 0
        private let parent: TransactionInputs
               
        init(parent: TransactionInputs) {
            self.parent = parent
        }
        
        public mutating func next() -> TransactionInput? {
            print(">>>> TransactionInputs next() - Current \(currentIndex) Length: \(parent.length)")
            guard currentIndex < parent.length else {
                return nil
            }
            let idx = currentIndex
            currentIndex += 1
            do {
                return TransactionInput(ptr: try CSLKit.transactionInputsGet(self_rptr: parent.ptr, index_long: Int64(idx)))
            } catch {
                // A real unexpected error: crash or log, but don’t silently
                // terminate the seq here unless that’s truly what you want.
                fatalError("Rust threw when fetching tx input[\(idx)]: \(error)")
            }
        }
    }
}

public class TransactionInput {
    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionInput>
    private var txHashPtr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionHash>?
    
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionInput>) {
        self.ptr = ptr
    }
    
    public init(txHash: String, index: Int64) throws {
        txHashPtr = try CSLKit.transactionHashFromHex(hex_str: txHash)
        
        self.ptr = try CSLKit.transactionInputNew(
            transaction_id_rptr: txHashPtr!,
            index_long: index)
    }
    
    public var txHash: String? {
        do {
            return try CSLKit.transactionHashToHex(self_rptr: CSLKit.transactionInputTransactionId(self_rptr: self.ptr))
        } catch {
            return nil
        }
    }
    
    public var index: Int64? {
        do {
            return try CSLKit.transactionInputIndex(self_rptr: self.ptr)
        } catch {
            return nil
        }
    }
    
}



public class TransactionUnspentOutputs: Sequence {
    fileprivate var ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionUnspentOutputs>
    var length: Int64
    
    public init() throws {
        self.ptr = try CSLKit.transactionUnspentOutputsNew()
        length = 0
    }
    
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionUnspentOutputs>) {
        self.ptr = ptr
        self.length = try! CSLKit.transactionUnspentOutputsLen(self_rptr: ptr)
    }
    
    public func addUtxo(utxo: TransactionUnspentOutput) throws {
        try CSLKit.transactionUnspentOutputsAdd(self_rptr: self.ptr, utxo_rptr: utxo.ptr)
        length += 1
    }
    
    public func makeIterator() -> Iterator {
        return Iterator(parent: self)
    }
    
    public struct Iterator: IteratorProtocol {
        public typealias Element = TransactionUnspentOutput
        private var currentIndex = 0
        private let parent: TransactionUnspentOutputs
        
        init(parent: TransactionUnspentOutputs) {
            self.parent = parent
        }
        
        public mutating func next() -> TransactionUnspentOutput? {
            guard currentIndex < parent.length else {
                return nil
            }
            let idx = currentIndex
            currentIndex += 1
            do {
                return TransactionUnspentOutput(ptr: try CSLKit.transactionUnspentOutputsGet(self_rptr: parent.ptr, index_long: Int64(idx)))
            } catch {
                // A real unexpected error: crash or log, but don’t silently
                // terminate the seq here unless that’s truly what you want.
                fatalError("Rust threw when fetching UTxO[\(idx)]: \(error)")
            }
        }
    }
}

public class TransactionUnspentOutput {
    fileprivate var ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionUnspentOutput>
    
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionUnspentOutput>) {
        self.ptr = ptr
    }
    
    public init(input: TransactionInput, output: TransactionOutput) throws {
        self.ptr = try CSLKit.transactionUnspentOutputNew(input_rptr: input.ptr, output_rptr: output.ptr)
    }
    
    public static func fromBytes(data: Data) throws -> TransactionUnspentOutput {
        return try TransactionUnspentOutput(ptr: CSLKit.transactionUnspentOutputFromBytes(bytes_data: data))
    }
    public static func fromHex(hex: String) throws -> TransactionUnspentOutput {
        return try TransactionUnspentOutput(ptr: CSLKit.transactionUnspentOutputFromHex(hex_str_str: hex))
    }
    
    public var input: TransactionInput? {
        do {
            return try TransactionInput(ptr: CSLKit.transactionUnspentOutputGetInput(self_rptr: self.ptr))
        } catch {
            return nil
        }
    }
    
    public var output: TransactionOutput? {
        do {
            return try TransactionOutput(ptr: CSLKit.transactionUnspentOutputGetOutput(self_rptr: self.ptr))
        } catch {
            return nil
        }
    }
    
}

//public class TransactionOutputBuilder {
//    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionOutputBuilder>
//    
//    init() throws {
//        self.ptr = try CSLKit.transactionOutputBuilderNew()
//    }
//        
////    public func next() throws -> TransactionOutputAmountBuilder {
////        
////    }
////    public func build() throws -> TransactionOutput {
////        let txOutPtr = try CSLKit.tranOutBui
////    }
//}
//
//public class TransactionOutputAmountBuilder {
//    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionOutputAmountBuilder>
//    
//    
//    
//}


public class TransactionOutput {
    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionOutput>
    
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionOutput>) {
        self.ptr = ptr
    }
    
    init(hex: String) throws {
        self.ptr = try CSLKit.transactionOutputFromHex(hex_str_str: hex)
    }
        
    public var address: Address? {
        do {
            let addrPtr = try CSLKit.transactionOutputAddress(self_rptr: self.ptr)
            return Address(ptr: addrPtr)
        } catch {
            return nil
        }
    }
    
    public var amount: Amount? {
        do {
            return Amount(ptr: try CSLKit.transactionOutputAmount(self_rptr: self.ptr))
        } catch {
            return nil
        }
    }
}

public class Amount {
    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_Value>
    
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_Value>) {
        self.ptr = ptr
    }
    
    public var lovelace: Int64? {
        do {
            let coin = try CSLKit.valueCoin(self_rptr: self.ptr)
            return Int64(try CSLKit.bigNumToStr(self_rptr: coin), radix: 10)
        } catch {
            return nil
        }
    }
    
    public var multiAsset: MultiAsset? {
        do {
            return try MultiAsset(ptr: try CSLKit.valueMultiasset(self_rptr: self.ptr))
        } catch {
            return nil
        }
    }
    
    public func toValue() throws -> Value? {
        guard let lovelace = self.lovelace else {
            return nil
        }
        
        let valuePtr = try CSLKit.valueNew(coin_rptr: CSLKit.bigNumFromStr(string_str: "\(lovelace)"))
        
        if let assets = self.multiAsset {
            try CSLKit.valueSetMultiasset(self_rptr: valuePtr, multiasset_rptr: assets.ptr)
        }
        
        return try Value(ptr: valuePtr)
    }
}


