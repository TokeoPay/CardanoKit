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
            
            return "\(txHash)#\(String(describing: index))"
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
    
    private let maestroApi: MaestroAPI
//    private var apiKeyProvider: APIKeyProvider
//    private var network: MaestroNetwork
    
    init(network: MaestroNetwork, apiKeyProvider: @escaping APIKeyProvider) {
        self.maestroApi = MaestroAPI(config: MaestroConfig(apiKeyProvider: apiKeyProvider, baseURL: URL(string: network.url)! ))
    }
}




