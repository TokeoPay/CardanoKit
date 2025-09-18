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
}
