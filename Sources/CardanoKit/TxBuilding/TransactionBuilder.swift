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
    
    public func setInputs(inputs: TxInputsBuilder) throws {
        _ = try CSLKit.transactionBuilderSetInputs(self_rptr: self.ptr, inputs_rptr: inputs.ptr)
    }
    
    public func setCollateral(inputs: TxInputsBuilder) throws {
        _ = try CSLKit.transactionBuilderSetCollateral(self_rptr: self.ptr, collateral_rptr: inputs.ptr)
    }
    
    public func setCollateralReturn() throws {
//        try CSLKit.transactionBuilderSetCollateralReturn(self_rptr: self.ptr, collateral_return_rptr: <#T##OpaqueRustPointer<CSLKit.Types.CSL_TransactionOutput>#>)
    }
}

/*
 
 transactionBuilderSetInputs
 transactionBuilderSetCollateral
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
