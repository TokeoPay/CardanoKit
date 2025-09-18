//
//  TxDetails.swift
//  CardanoKit
//
//  Created by Gavin Harris on 4/8/2025.
//
import Foundation
import CSLKit

public class Asset: Hashable {
    public static func == (lhs: Asset, rhs: Asset) -> Bool {
        lhs.fingerprint == rhs.fingerprint
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(fingerprint)
    }
    
    var policy: String
    var name: String?
    var fingerprint: String
    
    public init(policy: String, name: String? = nil, fingerprint: String) {
        self.policy = policy
        self.name = name
        self.fingerprint = fingerprint
    }
}

public class Value: CustomDebugStringConvertible {
    public var ptr: OpaqueRustPointer<CSLKit.Types.CSL_Value>
    var lovelace: Int64
    var assets: MultiAsset
    
    init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_Value>) throws {
        self.ptr = ptr
        
        self.lovelace = Int64(try CSLKit.bigNumToStr(self_rptr: try CSLKit.valueCoin(self_rptr: self.ptr)), radix: 10) ?? 0
        
        self.assets = try MultiAsset(ptr: try CSLKit.valueMultiasset(self_rptr: self.ptr))
    }
    
    init(lovelace: Int64, assets: MultiAsset) throws {
        self.lovelace = lovelace
        self.assets = assets
        self.ptr = try CSLKit.valueZero()
        
        _ = try CSLKit.valueSetCoin(self_rptr: self.ptr, coin_rptr: CSLKit.bigNumFromStr(string_str: "\(self.lovelace)"))
        _ = try CSLKit.valueSetMultiasset(self_rptr: self.ptr, multiasset_rptr: assets.ptr)
        
    }
    
    public func checkedAdd(other: Value) throws -> Value {
        return try Value(ptr: CSLKit.valueCheckedAdd(self_rptr: self.ptr, rhs_value_rptr: other.ptr))
    }
    
//    public func checkedAdd(other: Value) {
//        self.lovelace += other.lovelace
//        
//        let allAssets = [
//            ...other.assets,
//            ...self.assets
//        ]
//        
//        
//    }
    
    public var debugDescription: String {
        return "Value(lovelace: \(lovelace), assets: \(assets))"
    }
}

public class TxSummary: CustomDebugStringConvertible {
    var address: String
    var value: Value
    
    init(address: String, value: Value) {
        self.address = address
        self.value = value
    }
    
    public var debugDescription: String {
        return "TxSummary(address: \(address), Value: \(value))"
    }
}


public class TxDetailsFactory {
    
    let provider: TransactionDataProvider
    init(provider: TransactionDataProvider) {
        self.provider = provider
    }
    
    public func makeDetails(transaction: FixedTransaction) async throws -> TxDetails {
        let hash = try transaction.hash()
        let fee = try transaction.getFee()!

        let txBody = try transaction.getBody()

        let outputs = try txBody.outputs()

        let txInputs = try await provider.getUtxos(for: txBody.inputs())
        
        // Inputs from each Credential
        
        var inputSummary: [String: TxSummary] = [:]
        
        try txInputs.forEach { txi in
            guard let txOut = txi.output else {
                return
            }
            
            guard let value = try txOut.amount?.toValue() else {
                return
            }
            
            guard let address = txOut.address else {
                return
            }
            
            let paymentAddress = try address.asBech32()
            let stakingAddress = try address.getStakingAddress()
            
            if let stakingAddress = stakingAddress {
                let stakingAddress = try stakingAddress.asBech32()
                
                if let amount = inputSummary[stakingAddress] {
                    inputSummary[stakingAddress] = (
                        TxSummary(
                            address: stakingAddress,
                            value: try value.checkedAdd(other: amount.value)
                        )
                    )
                } else {
                    inputSummary[stakingAddress] = (
                        TxSummary(
                            address: stakingAddress,
                            value: value
                        )
                    )
                }
                
                
                
            }
            
            inputSummary[paymentAddress] = (
                TxSummary(
                    address: paymentAddress,
                    value: value
                )
            )
        }
        
        var outputSummary: [TxSummary] = []
        
        try outputs.forEach { txOut in
            guard let value = try txOut.amount?.toValue() else {
                return
            }
            
            guard let address = txOut.address else {
                return
            }
            
            let paymentAddress = try address.asBech32()
            let stakingAddress = try address.getStakingAddress()
                        
            if let stakingAddress = stakingAddress {
                outputSummary.append(
                    TxSummary(
                        address: try stakingAddress.asBech32(),
                        value: value
                    )
                )
            }
            
            outputSummary.append(
                TxSummary(
                    address: paymentAddress,
                    value: value
                )
            )
        }
        
        let signers = try transaction.getRequiredSignerKeyHashes(utxos: txInputs)
        
        return TxDetails(
            hash: hash,
            fee: fee,
            inputs: txInputs,
            collateral: nil,
            collateralOutput: nil,
            signers: signers,
            outputs: outputs,
            outputSummary: outputSummary,
            inputSummary: inputSummary.values.map { $0 } ,
            mints: nil
        )
    }
}


public class TxDetails {
    let hash: String
    let fee: Int64
    let inputs: TransactionUnspentOutputs
    let collateral: TransactionUnspentOutputs?
    let collateralOutput: TransactionOutput?
    let signers: [Data]
    let outputs: TransactionOutputs
    let outputSummary: [TxSummary]
    let inputSummary: [TxSummary]
    let mints: [Asset]?
    
    public init(
        hash: String,
        fee: Int64,
        inputs: TransactionUnspentOutputs,
        collateral: TransactionUnspentOutputs?,
        collateralOutput: TransactionOutput?,
        signers: [Data],
        outputs: TransactionOutputs,
        outputSummary: [TxSummary],
        inputSummary: [TxSummary],
        mints: [Asset]?
    ) {
        self.hash = hash
        self.fee = fee
        self.inputs = inputs
        self.collateral = collateral
        self.collateralOutput = collateralOutput
        self.signers = signers
        self.outputs = outputs
        self.outputSummary = outputSummary
        self.inputSummary = inputSummary
        self.mints = mints
    }
}

//public class TxDetails {
//    var fee: Int64
//    var hash: String
//    var inputs: TransactionUnspentOutputs
//    var collateral: TransactionUnspentOutputs?
//    var collateralOutput: TransactionOutput?
//    var signers: [Data]
//    var outputs: TransactionOutputs
//    var outputSummary: [TxSummary]
//    var inputSummary: [TxSummary]
//    var mints: [Asset]
//    
//    public init(transaction: FixedTransaction) throws {
//        self.hash = try transaction.hash()
//        self.fee = try transaction.getFee()!
//        
//        let fixedTxBody = try transaction.getBody()
//        
//        let txBody = try TransactionBody(bytes: fixedTxBody.toRawBytes())
//        outputs = try txBody.outputs()
//        
//        let txInputs = try txBody.inputs()
//        
//        
//        
//        
//        
//    }
//}
