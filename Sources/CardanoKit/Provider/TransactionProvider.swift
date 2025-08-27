//
//  TransactionProvider.swift
//  CardanoKit
//
//  Created by Gavin Harris on 5/8/2025.
//

protocol TransactionDataProvider {
    func getUtxos(for transactionInputs: TransactionInputs) throws -> TransactionUnspentOutputs
    
}
