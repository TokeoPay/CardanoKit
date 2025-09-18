//
//  TransactionBuilder.swift
//  CardanoKit
//
//  Created by Gavin Harris on 19/6/2025.
//
import Foundation
import CSLKit

public class TransactionBuilder {
    private var ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionBuilder>
    
    public init(config: OpaqueRustPointer<CSLKit.Types.CSL_TransactionBuilderConfig>) throws {
        self.ptr = try CSLKit.transactionBuilderNew(cfg_rptr: config)
    }
    
    public func setInputs(inputs: TxInputsBuilder) throws -> TransactionBuilder {
        _ = try CSLKit.transactionBuilderSetInputs(self_rptr: self.ptr, inputs_rptr: inputs.ptr)
        return self
    }
    
    public func addInputsFrom(inputs: TransactionUnspentOutputs, strategy: CSLKit.CoinSelectionStrategy = CSLKit.CoinSelectionStrategy.RandomImproveMultiAsset) throws -> TransactionBuilder {
        _ = try CSLKit.transactionBuilderAddInputsFrom(self_rptr: self.ptr, inputs_rptr: inputs.ptr, strategy: strategy)
        return self
    }
    
//    public func addOutput(toAddress: String, lovelace: Int64, assets: [String: Int64]) throws -> TransactionBuilder {
//        
//        let address = Address(bech32: toAddress)
//        
//        let outputBuilder = try CSLKit.transactionOutputBuilderNew()
//        try CSLKit.transactionOutputBuilderWithAddress(self_rptr: outputBuilder, address_rptr: address.ptr)
//        var outputAmountBuilder = try CSLKit.transactionOutputBuilderNext(self_rptr: outputBuilder)
//        
//        outputAmountBuilder = try CSLKit.transactionOutputAmountBuilderWithCoin(self_rptr: outputAmountBuilder, coin_rptr: CSLKit.bigNumFromStr(string_str: "\(lovelace)"))
//        
//        Value(lovelace: lovelace, assets: <#T##MultiAsset#>)
//        
//        assets.forEach { (unit, amount) in
//            outputAmountBuilder = try CSLKit.transactionOutputAmountBuilderWithCoinAndAsset(self_rptr: <#T##OpaqueRustPointer<CSLKit.Types.CSL_TransactionOutputAmountBuilder>#>, coin_rptr: <#T##OpaqueRustPointer<CSLKit.Types.CSL_BigNum>#>, multiasset_rptr: <#T##OpaqueRustPointer<CSLKit.Types.CSL_MultiAsset>#>)
//        }
//        
//        
//    }
    
    public func addOutput(output: TransactionOutput) throws -> TransactionBuilder {
        _ = try CSLKit.transactionBuilderAddOutput(self_rptr: self.ptr, output_rptr: output.ptr)
        return self
    }
    
    public func setChangeAddress(address: Address) throws -> TransactionBuilder {
        _ = try CSLKit.transactionBuilderAddChangeIfNeeded(self_rptr: self.ptr, address_rptr: address.ptr)
        return self
    }
    
    public func setCollateral(inputs: TxInputsBuilder) throws -> TransactionBuilder {
        _ = try CSLKit.transactionBuilderSetCollateral(self_rptr: self.ptr, collateral_rptr: inputs.ptr)
        return self
    }
    
    public func setCollateralReturn(txOut: TransactionOutput) throws -> TransactionBuilder {
        _ = try CSLKit.transactionBuilderSetCollateralReturn(self_rptr: self.ptr, collateral_return_rptr:  txOut.ptr)
        return self
    }
    
    public func setMinFee(fee: Int64) throws -> TransactionBuilder {
        _ = try CSLKit.transactionBuilderSetMinFee(self_rptr: self.ptr, fee_rptr: CSLKit.bigNumFromStr(string_str: "\(fee)"))
        return self
    }
    
    public func setValidityPeriod(period: Int64) throws -> TransactionBuilder {
        _ = try CSLKit.transactionBuilderSetValidityStartIntervalBignum(self_rptr: self.ptr, validity_start_interval_rptr: CSLKit.bigNumFromStr(string_str: "\(period)"))
        return self
    }
    
    public func setTtl(ttl: Int64) throws -> TransactionBuilder {
        _ = try CSLKit.transactionBuilderSetTtlBignum(self_rptr: self.ptr, ttl_rptr: CSLKit.bigNumFromStr(string_str: "\(ttl)"))
        
        return self
    }
    
    public func build() throws -> FixedTransaction {
        let transactionPtr = try CSLKit.transactionBuilderBuildTx(self_rptr: self.ptr)
        
        let txHex = try CSLKit.transactionToHex(self_rptr: transactionPtr)
        
        return try FixedTransaction(hex: txHex)
    }
    
    public func buildUnsafe() throws -> FixedTransaction {
        let transactionPtr = try CSLKit.transactionBuilderBuildTxUnsafe(self_rptr: self.ptr)
        
        let txHex = try CSLKit.transactionToHex(self_rptr: transactionPtr)
        
        return try FixedTransaction(hex: txHex)
    }
}



/*
 
 // transactionBuilderSetInputs
 // transactionBuilderSetCollateral
 transactionBuilderSetCollateralReturn
 transactionBuilderSetCollateralReturnAndTotal
 transactionBuilderSetTotalCollateral
 transactionBuilderSetTotalCollateralAndReturn
 transactionBuilderSetFee
 transactionBuilderSetMinFee
 transactionBuilderSetTtl
 transactionBuilderSetTtlBignum
 transactionBuilderSetValidityStartInterval
 transactionBuilderSetValidityStartIntervalBignum
 transactionBuilderSetCerts
 transactionBuilderSetCertsBuilder
 transactionBuilderSetWithdrawals
 transactionBuilderSetWithdrawalsBuilder
 transactionBuilderSetVotingBuilder
 transactionBuilderSetVotingProposalBuilder
 transactionBuilderSetAuxiliaryData
 transactionBuilderSetMetadata
 transactionBuilderSetMintBuilder
 transactionBuilderSetMint
 transactionBuilderSetMintAsset
 transactionBuilderSetDonation
 transactionBuilderSetCurrentTreasuryValue
 transactionBuilderSetScriptDataHash
 
 transactionBuilderAddInputsFrom
 transactionBuilderAddReferenceInput
 transactionBuilderAddScriptReferenceInput
 transactionBuilderAddKeyInput
 transactionBuilderAddNativeScriptInput
 transactionBuilderAddPlutusScriptInput
 transactionBuilderAddBootstrapInput
 transactionBuilderAddRegularInput
 transactionBuilderAddInputsFromAndChangeWithCollateralReturn
 transactionBuilderAddOutput
 transactionBuilderAddMetadatum
 transactionBuilderAddJsonMetadatum
 transactionBuilderAddJsonMetadatumWithSchema
 transactionBuilderAddMintAsset
 transactionBuilderAddMintAssetAndOutput
 transactionBuilderAddMintAssetAndOutputMinRequiredCoin
 transactionBuilderAddExtraWitnessDatum
 transactionBuilderAddRequiredSigner
 */

public class TxInputsBuilder {
    
    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_TxInputsBuilder>
    
    public init() throws {
        self.ptr = try CSLKit.txInputsBuilderNew()
    }
    
    public func addUtxo(utxo: TransactionUnspentOutput) throws {
        try CSLKit.txInputsBuilderAddRegularUtxo(self_rptr: self.ptr, utxo_rptr: utxo.ptr)
    }
        
    public func getTotalValue() throws -> OpaqueRustPointer<CSLKit.Types.CSL_Value> {
        return try CSLKit.txInputsBuilderTotalValue(self_rptr: self.ptr)
    }
    
}

public class TxOutput {
    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionOutput>
    
    public init() throws {
        self.ptr = try CSLKit.transactionOutputsNew()
        
        
    }
}

public class TxOutputBuilder {
    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionOutputBuilder>
    
    init() throws {
        self.ptr = try CSLKit.transactionOutputBuilderNew()
    }
    
    public func withAddress(address: Address) throws {
        self.ptr = try CSLKit.transactionOutputBuilderWithAddress(self_rptr: self.ptr, address_rptr: address.ptr)
    }
    
    public func withInlineDatum() throws {
//        self.ptr = try CSLKit.transactionOutputBuilderWithPlutusData(self_rptr: self.ptr, data_rptr: <#T##OpaqueRustPointer<CSLKit.Types.CSL_PlutusData>#>)
    }
    
    public func withDatumHash() throws {
//        self.ptr = try CSLKit.transactionOutputBuilderWithDataHash(self_rptr: self.ptr, data_hash_rptr: <#T##OpaqueRustPointer<CSLKit.Types.CSL_DataHash>#>)
    }
    
    public func withRefScript() throws {
//        self.ptr = try CSLKit.transactionOutputBuilderWithScriptRef(self_rptr: self.ptr, script_ref_rptr: <#T##OpaqueRustPointer<CSLKit.Types.CSL_ScriptRef>#>)
    }
    
    public func withAmount() throws -> TxOutputAmountBuilder {
        let amountPtr = try CSLKit.transactionOutputBuilderNext(self_rptr: self.ptr)
        
        return TxOutputAmountBuilder.init(amountPtr: amountPtr)
    }
}

public class TxOutputAmountBuilder {
    var amountPtr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionOutputAmountBuilder>
    
    fileprivate init(amountPtr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionOutputAmountBuilder>) {
        self.amountPtr = amountPtr
    }
    
    public func withLovelace(lovelace: UInt64) throws {
        self.amountPtr = try CSLKit.transactionOutputAmountBuilderWithCoin(
            self_rptr: self.amountPtr,
            coin_rptr: CSLKit.bigNumFromStr(string_str: "\(lovelace)")
        )
    }
    
    public func withCoinAndAsset(lovelace: UInt64) throws {

    }
    
    
}
