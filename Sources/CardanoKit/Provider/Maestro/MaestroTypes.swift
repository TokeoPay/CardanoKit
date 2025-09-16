//
//  MaestroTypes.swift
//  CardanoKit
//
//  Created by Gavin Harris on 16/9/2025.
//

import Foundation

// MARK: - Top Level

struct MaestroResponse<T: Codable & Sendable>: Codable, Sendable {
    let data: [T]
    let lastUpdated: BlockUpdate
    let nextCursor: String?
    
    enum CodingKeys: String, CodingKey {
        case data
        case lastUpdated = "last_updated"
        case nextCursor = "next_cursor"
    }
}

struct MaestroAPIError: Codable, Sendable {
    let error: String
    let message: String
}

// MARK: - Transaction Output

struct MaestroUTxO: Codable, Sendable {
    let txHash: String
    let index: Int
    let assets: [MaestroAsset]
    let address: String
    let datum: MaestroDatum?
    let referenceScript: String?
    let txoutCbor: String?
    
    enum CodingKeys: String, CodingKey {
        case txHash = "tx_hash"
        case index
        case assets
        case address
        case datum
        case referenceScript = "reference_script"
        case txoutCbor = "txout_cbor"
    }
}

// MARK: - Asset balance

struct MaestroAsset: Codable, Sendable {
    let unit: String
    let amount: Int
}

// MARK: - Datum

struct MaestroDatum: Codable, Sendable {
    let type: String
    let hash: String
    let bytes: String
    let json: MaestroPlutusData
}

// MARK: - Plutus JSON (recursive)

struct MaestroPlutusData: Codable, Sendable {
    let constructor: Int?
    let fields: [MaestroPlutusData]?
    let bytes: String?
    let int: Int?
}

// MARK: - Block Update

struct BlockUpdate: Codable, Sendable {
    let timestamp: String
    let blockHash: String
    let blockSlot: Int
    
    enum CodingKeys: String, CodingKey {
        case timestamp
        case blockHash = "block_hash"
        case blockSlot = "block_slot"
    }
}
