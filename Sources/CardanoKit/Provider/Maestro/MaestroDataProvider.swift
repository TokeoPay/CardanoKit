//
//  MaestroDataProvider.swift
//  CardanoKit
//
//  Created by Gavin Harris on 16/9/2025.
//

import Foundation
import Alamofire

public enum MaestroNetwork {
    case mainnet
    case preview
    case preprod
    case custom(String)
    
    public var url: String {
        switch self {
        case .mainnet:
            return "https://mainnet.gomaestro-api.org"
        case .preview:
            return "https://mainnet.gomaestro-api.org/"
        case .preprod:
            return "https://mainnet.gomaestro-api.org/"
        case .custom(let url):
            return url
        }
    }
}

public typealias APIKeyProvider = @Sendable () async -> String

public class MaestroDataProvider: TransactionDataProvider {
    
    private var transactionBuilderConfig: TransactionBuilderConfig? = nil
    private var protocolParams: MaestroProtocolParameters? = nil
    
    public func coinsPerUtxoByte() async throws -> Int {
        
        let pp = try await getProtocolParams()
        
        return pp.minUtxoDepositCoefficient
    }
    
    func getProtocolParams() async throws -> MaestroProtocolParameters {
        
        if let pp = self.protocolParams {
            return pp
        }
        
        let ppResult = try await self.maestroApi.request(
            path: "/v1/protocol-parameters",
            responseType: MaestroResponseSingle<MaestroProtocolParameters>.self,
            errorType: MaestroAPIError.self
        )
        self.protocolParams = ppResult.data
        return ppResult.data
    }
    
    public func getTransactionBuilderConfig() async throws -> TransactionBuilderConfig {
        // Return cached config if already built
        if let cachedConfig = transactionBuilderConfig {
            return cachedConfig
        }
        
        let pp = try await getProtocolParams()
        self.protocolParams = pp
        
        // Build the config
        let txBC = try TransactionBuilderConfigBuilder()
        try txBC.setFeeAlgo(
            coefficient: "\(pp.minFeeCoefficient)",
            constant: "\(pp.minFeeConstant.ada.lovelace)"
        )
        try txBC.setPoolDeposit(poolDeposit: "\(pp.stakePoolDeposit.ada.lovelace)")
        try txBC.setKeyDeposit(keyDeposit: "\(pp.stakeCredentialDeposit.ada.lovelace)")
        try txBC.setCoinsPerUtxoByte(
            coinsPerUtxoByte: "\(pp.minUtxoDepositCoefficient)"
        )
        try txBC.setMaxTxSize(maxTxSize: Int64(pp.maxTransactionSize.bytes))
        try txBC.setMaxValueSize(maxValueSize: Int64(pp.maxValueSize.bytes))
        
        try txBC.setExUnitPrices(
            mem: pp.scriptExecutionPrices.memory,
            step: pp.scriptExecutionPrices.cpu
        )
                
        let builtConfig = try txBC.build()
        transactionBuilderConfig = builtConfig
        
        return builtConfig
    }
    
    
    public func getUtxosForMultipleAddresses(addresses: [String]) async throws -> TransactionUnspentOutputs {
        //   https://mainnet.gomaestro-api.org/v1/addresses/utxos
        let utxos = try await self.maestroApi.requestPost(
            path: "/v1/addresses/utxos?with_cbor=true",
            body: addresses,
            responseType: MaestroResponse<MaestroUTxO>.self,
            errorType: MaestroAPIError.self
        )
        
        let returnUtxos = try TransactionUnspentOutputs()
        try utxos.data.forEach { maestroUtxo in
            
            guard let txoutCbor = maestroUtxo.txoutCbor else {
                throw MaestroError.api("TxOut CBOR not provided")
            }
            
            let txo = try TransactionOutput(hex: txoutCbor)
            
            let txInput = try TransactionInput(txHash: maestroUtxo.txHash, index: Int64(maestroUtxo.index))
            
            try returnUtxos.addUtxo(utxo: try TransactionUnspentOutput(input: txInput, output: txo))
        }
        
        return returnUtxos
    }
    
    public func getUtxos(for transactionInputs: TransactionInputs) async throws -> TransactionUnspentOutputs {
        // https://mainnet.gomaestro-api.org/v1/transactions/outputs
        /*
             curl --request POST \
             --url https://mainnet.gomaestro-api.org/v1/transactions/outputs \
             --header 'Content-Type: application/json' \
             --header 'api-key: <api-key>' \
             --data '[
             "a90e31b3de59452659617c351e5f746b819cb8b026bf945dd41b4cc199bcc8c9#1",
             "31a84c3c6200bec2498b18c42f882fa690cd0d32a9c84a2019eb5cc42f5971d0#0"
             ]'
         */
        
        let txInputs = transactionInputs.map { txInput in
            guard let txHash = txInput.txHash else {
                return ""
            }
            guard let txIndex = txInput.index else {
                return ""
            }
            
            return "\(txHash)#\(txIndex)"
        }
        
        let utxos = try await self.maestroApi.requestPost(
            path: "/v1/transactions/outputs?with_cbor=true",
            body: txInputs,
            responseType: MaestroResponse<MaestroUTxO>.self,
            errorType: MaestroAPIError.self
        )

        let returnUtxos = try TransactionUnspentOutputs()
        try utxos.data.forEach { maestroUtxo in
            
            guard let txoutCbor = maestroUtxo.txoutCbor else {
                throw MaestroError.api("TxOut CBOR not provided")
            }
            
            let txo = try TransactionOutput(hex: txoutCbor)
            
            let txInput = try TransactionInput(txHash: maestroUtxo.txHash, index: Int64(maestroUtxo.index))
            
            try returnUtxos.addUtxo(utxo: try TransactionUnspentOutput(input: txInput, output: txo))
        }
        
        return returnUtxos
    }
    
    public func getStakeAccountAddresses(stake_account_address: String) async throws -> [Address] {
//        https://mainnet.gomaestro-api.org/v1/accounts/{stake_addr}/addresses
        
        let addresses = try await self.maestroApi.request(
            path: "/v1/accounts/\(stake_account_address)/addresses",
            responseType: MaestroResponseSingle<Array<String>>.self,
            errorType: MaestroAPIError.self
        )
        
        return try addresses.data.map { address in
            try Address(bech32: address)
        }
        
    }
    
    private let maestroApi: MaestroAPIProtocol
//    private var apiKeyProvider: APIKeyProvider
//    private var network: MaestroNetwork
    
    public init(maestroApi: MaestroAPIProtocol) {
        self.maestroApi = maestroApi
    }
    
    /**
     Main initaliser
     */
    public convenience init(network: MaestroNetwork, apiKeyProvider: @escaping APIKeyProvider) {
        self.init(maestroApi: MaestroAPI(config: MaestroConfig(apiKeyProvider: apiKeyProvider, baseURL: URL(string: network.url)! )))
    }
}





enum StringToFloatError: Error {
    case invalidFormat(String) // e.g. "abc"
    case invalidNumerator(String)
    case invalidDenominator(String)
    case divisionByZero
}
