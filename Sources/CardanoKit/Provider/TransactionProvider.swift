//
//  TransactionProvider.swift
//  CardanoKit
//
//  Created by Gavin Harris on 5/8/2025.
//

public protocol TransactionDataProvider {
    func getTransactionBuilderConfig() async throws -> TransactionBuilderConfig
    func getUtxos(for transactionInputs: TransactionInputs) async throws -> TransactionUnspentOutputs
    func getUtxosForMultipleAddresses(addresses: [String]) async throws -> TransactionUnspentOutputs
    func getStakeAccountAddresses(stake_account_address: String) async throws -> [Address]
    func coinsPerUtxoByte() async throws -> Int
    func submit(transaction: FixedTransaction) async throws -> String
    
    /**
     TODO:
     Submit Endpoint
     Active Address? Address Transaction Count?
     Evaluate Transaction (Plutus)
     
     */
}
