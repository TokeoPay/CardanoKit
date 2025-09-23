//
//  TransactionBuilder.swift
//  CardanoKit
//
//  Created by Gavin Harris on 19/6/2025.
//
import Foundation
import CSLKit

public enum NoInputsYet {}
public enum HasInputs {}

public class TransactionBuilder<State> {
    private var ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionBuilder>
    
    public init(config: OpaqueRustPointer<CSLKit.Types.CSL_TransactionBuilderConfig>) throws {
        self.ptr = try CSLKit.transactionBuilderNew(cfg_rptr: config)
    }
    
    internal init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionBuilder>) {
        self.ptr = ptr
    }
    
    public func setInputs(inputs: TxInputsBuilder) throws -> TransactionBuilder {
        _ = try CSLKit.transactionBuilderSetInputs(self_rptr: self.ptr, inputs_rptr: inputs.ptr)
        return self
    }
    
    public func addMint(native_script: NativeScript, asset_name: AssetName, amount: Int64) throws -> TransactionBuilder {
        
        _ = try CSLKit.transactionBuilderAddMintAsset(
                self_rptr: self.ptr,
                policy_script_rptr: native_script.ptr,
                asset_name_rptr: asset_name.ptr,
                amount_rptr: CSLKit.intFromStr(string_str: "\(amount)")
        )
        
        return self
    }
    
    /**
   The addInputsFrom method should be called after all Outputs, Certificates etc have been added.
 
    From the CSL Library:
    This automatically selects and adds inputs from {inputs} consisting of just enough to cover the outputs that have already been added. This should be called after adding all certs/ outputs/ etc and will be an error otherwise. Uses CIP2: https:// github. com/ cardano-foundation/ CIPs/ blob/ master/ CIP-0002/ CIP-0002.md
    Adding a change output must be called after via TransactionBuilder::add_change_if_needed() This function, diverging from CIP2, takes into account fees and will attempt to add additional inputs to cover the minimum fees. This does not, however, set the txbuilder's fee.
     */
    public func addInputsFrom(inputs: TransactionUnspentOutputs, strategy: CSLKit.CoinSelectionStrategy = CSLKit.CoinSelectionStrategy.RandomImproveMultiAsset) throws -> TransactionBuilder<HasInputs> {
        
        _ = try CSLKit.transactionBuilderAddInputsFrom(self_rptr: self.ptr, inputs_rptr: inputs.ptr, strategy: strategy)
        return TransactionBuilder<HasInputs>(ptr: self.ptr)
    }
        
    public func addOutput(output: TransactionOutput) throws -> TransactionBuilder<State> where State == NoInputsYet {
        _ = try CSLKit.transactionBuilderAddOutput(self_rptr: self.ptr, output_rptr: output.ptr)
        return self
    }
    
    public func addCertificates(cert_builder: CertificatesBuilder) throws -> TransactionBuilder<State> where State == NoInputsYet {
        _ = try CSLKit.transactionBuilderSetCertsBuilder(self_rptr: self.ptr, certs_rptr: cert_builder.ptr)
        return self
    }
    
    public func setChangeAddress(address: Address) throws -> TransactionBuilder<HasInputs> {
        _ = try CSLKit.transactionBuilderAddChangeIfNeeded(self_rptr: self.ptr, address_rptr: address.ptr)
        return TransactionBuilder<HasInputs>(ptr: self.ptr)
    }
    
    public func setCollateral(inputs: TxInputsBuilder) throws -> TransactionBuilder<State> where State == NoInputsYet {
        _ = try CSLKit.transactionBuilderSetCollateral(self_rptr: self.ptr, collateral_rptr: inputs.ptr)
        return self
    }
    
    public func setCollateralReturn(txOut: TransactionOutput) throws -> TransactionBuilder<State> where State == NoInputsYet {
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
    
    public func build() throws -> FixedTransaction where State == HasInputs {
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


public class CertificatesBuilder {
    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_CertificatesBuilder>
    
    init() throws {
        ptr = try CSLKit.certificatesBuilderNew()
    }
    
    public func addStakeDelegation(stake_address: StakeAddress, pool_key_hash: Ed25519KeyHash) throws -> CertificatesBuilder {
        
        try addCert(
            cert:
                CSLKit.certificateNewStakeDelegation(
                    stake_delegation_rptr: CSLKit.stakeDelegationNew(stake_credential_rptr: stake_address.credential().ptr, pool_keyhash_rptr: pool_key_hash.ptr)
            ))
        return self
    }
    
    public func addStakeRegistration(stake_address: StakeAddress) throws -> CertificatesBuilder {
        try addCert(
            cert: CSLKit.certificateNewRegCert(
                stake_registration_rptr: CSLKit.stakeRegistrationNew(stake_credential_rptr: stake_address.credential().ptr)
            )
        )
        return self
    }
    
    public func addStakeDeregistration(stake_address: StakeAddress) throws -> CertificatesBuilder {
        try addCert(
            cert: CSLKit.certificateNewStakeDeregistration(
                stake_deregistration_rptr: CSLKit.stakeDeregistrationNew(stake_credential_rptr: stake_address.credential().ptr)
            )
        )
        return self
    }
    
    public enum DRep {
        case AlwaysAbstain
        case AlwaysNoConfidence
        case DelegateToBech32(String)
    }
    
    public func addVoteDelegation(stake_address: StakeAddress, drep: DRep) throws -> CertificatesBuilder {
        
        let theDRep = switch drep {
        case .AlwaysAbstain:
            try CSLKit.dRepNewAlwaysAbstain()
        case .AlwaysNoConfidence:
            try CSLKit.dRepNewAlwaysNoConfidence()
        case .DelegateToBech32(let bech32):
            try CSLKit.dRepFromBech32(bech32_str_str: bech32)
        }
        
        try addCert(
            cert: CSLKit.certificateNewVoteDelegation(
                vote_delegation_rptr: CSLKit.voteDelegationNew(stake_credential_rptr: stake_address.credential().ptr, drep_rptr: theDRep)
            )
        )
        
        return self
    }
    
    func addCert(cert: OpaqueRustPointer<CSLKit.Types.CSL_Certificate>) throws {
        _ = try CSLKit.certificatesBuilderAddCertificate(self_rptr: self.ptr, cert_rptr: cert)
    }
}

public class TxInputsBuilder {
    
    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_TxInputsBuilder>
    
    public init() throws {
        self.ptr = try CSLKit.txInputsBuilderNew()
    }
    
    public func addUtxo(utxo: TransactionUnspentOutput) throws {
        _ = try CSLKit.txInputsBuilderAddRegularUtxo(self_rptr: self.ptr, utxo_rptr: utxo.ptr)
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
