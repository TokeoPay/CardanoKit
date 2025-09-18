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

struct MaestroResponseSingle<T: Codable & Sendable>: Codable, Sendable {
    let data: T
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


struct MaestroProtocolParameters: Codable, Sendable {
    let minFeeCoefficient: Int
    let minFeeConstant: MaestroLovelaceAmount
    let minFeeReferenceScripts: MaestroReferenceScriptFee
    let maxBlockBodySize: MaestroBytesValue
    let maxBlockHeaderSize: MaestroBytesValue
    let maxTransactionSize: MaestroBytesValue
    let maxReferenceScriptsSize: MaestroBytesValue
    let stakeCredentialDeposit: MaestroLovelaceAmount
    let stakePoolDeposit: MaestroLovelaceAmount
    let stakePoolRetirementEpochBound: Int
    let desiredNumberOfStakePools: Int
    let stakePoolPledgeInfluence: String
    let monetaryExpansion: String
    let treasuryExpansion: String
    let minStakePoolCost: MaestroLovelaceAmount
    let minUtxoDepositConstant: MaestroLovelaceAmount
    let minUtxoDepositCoefficient: Int
    let plutusCostModels: MaestroPlutusCostModels
    let scriptExecutionPrices: MaestroScriptExecutionPrices
    let maxExecutionUnitsPerTransaction: MaestroExecutionUnits
    let maxExecutionUnitsPerBlock: MaestroExecutionUnits
    let maxValueSize: MaestroBytesValue
    let collateralPercentage: Int
    let maxCollateralInputs: Int
    let version: MaestroProtocolVersion
    let stakePoolVotingThresholds: MaestroStakePoolVotingThresholds
    let delegateRepresentativeVotingThresholds: MaestroDelegateRepresentativeVotingThresholds
    let constitutionalCommitteeMinSize: Int
    let constitutionalCommitteeMaxTermLength: Int
    let governanceActionLifetime: Int
    let governanceActionDeposit: MaestroLovelaceAmount
    let delegateRepresentativeDeposit: MaestroLovelaceAmount
    let delegateRepresentativeMaxIdleTime: Int
    
    enum CodingKeys: String, CodingKey {
        case minFeeCoefficient = "min_fee_coefficient"
        case minFeeConstant = "min_fee_constant"
        case minFeeReferenceScripts = "min_fee_reference_scripts"
        case maxBlockBodySize = "max_block_body_size"
        case maxBlockHeaderSize = "max_block_header_size"
        case maxTransactionSize = "max_transaction_size"
        case maxReferenceScriptsSize = "max_reference_scripts_size"
        case stakeCredentialDeposit = "stake_credential_deposit"
        case stakePoolDeposit = "stake_pool_deposit"
        case stakePoolRetirementEpochBound = "stake_pool_retirement_epoch_bound"
        case desiredNumberOfStakePools = "desired_number_of_stake_pools"
        case stakePoolPledgeInfluence = "stake_pool_pledge_influence"
        case monetaryExpansion = "monetary_expansion"
        case treasuryExpansion = "treasury_expansion"
        case minStakePoolCost = "min_stake_pool_cost"
        case minUtxoDepositConstant = "min_utxo_deposit_constant"
        case minUtxoDepositCoefficient = "min_utxo_deposit_coefficient"
        case plutusCostModels = "plutus_cost_models"
        case scriptExecutionPrices = "script_execution_prices"
        case maxExecutionUnitsPerTransaction = "max_execution_units_per_transaction"
        case maxExecutionUnitsPerBlock = "max_execution_units_per_block"
        case maxValueSize = "max_value_size"
        case collateralPercentage = "collateral_percentage"
        case maxCollateralInputs = "max_collateral_inputs"
        case version
        case stakePoolVotingThresholds = "stake_pool_voting_thresholds"
        case delegateRepresentativeVotingThresholds = "delegate_representative_voting_thresholds"
        case constitutionalCommitteeMinSize = "constitutional_committee_min_size"
        case constitutionalCommitteeMaxTermLength = "constitutional_committee_max_term_length"
        case governanceActionLifetime = "governance_action_lifetime"
        case governanceActionDeposit = "governance_action_deposit"
        case delegateRepresentativeDeposit = "delegate_representative_deposit"
        case delegateRepresentativeMaxIdleTime = "delegate_representative_max_idle_time"
    }
}

// MARK: - Supporting types

struct MaestroLovelaceAmount: Codable, Sendable {
    let ada: LovelaceWrapper
    struct LovelaceWrapper: Codable, Sendable {
        let lovelace: Int
    }
}

struct MaestroReferenceScriptFee: Codable, Sendable {
    let base: Int
    let range: Int
    let multiplier: Double
}

struct MaestroBytesValue: Codable, Sendable {
    let bytes: Int
}

struct MaestroPlutusCostModels: Codable, Sendable {
    let plutusV1: [Int]?
    let plutusV2: [Int]?
    let plutusV3: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case plutusV1 = "plutus_v1"
        case plutusV2 = "plutus_v2"
        case plutusV3 = "plutus_v3"
    }
}

struct MaestroScriptExecutionPrices: Codable, Sendable {
    let memory: String
    let cpu: String
}

struct MaestroExecutionUnits: Codable, Sendable {
    let memory: Int
    let cpu: Int
}

struct MaestroProtocolVersion: Codable, Sendable {
    let major: Int
    let minor: Int
}

// MARK: - Voting thresholds

struct MaestroStakePoolVotingThresholds: Codable, Sendable {
    let noConfidence: String
    let constitutionalCommittee: MaestroConstitutionalCommitteeThresholds
    let hardForkInitiation: String
    let protocolParametersUpdate: MaestroProtocolParametersUpdate
    
    enum CodingKeys: String, CodingKey {
        case noConfidence = "no_confidence"
        case constitutionalCommittee = "constitutional_committee"
        case hardForkInitiation = "hard_fork_initiation"
        case protocolParametersUpdate = "protocol_parameters_update"
    }
}

struct MaestroConstitutionalCommitteeThresholds: Codable, Sendable {
    let `default`: String
    let stateOfNoConfidence: String
    
    enum CodingKeys: String, CodingKey {
        case `default` = "default"
        case stateOfNoConfidence = "state_of_no_confidence"
    }
}

struct MaestroProtocolParametersUpdate: Codable, Sendable {
    let security: String?
    let network: String?
    let economic: String?
    let technical: String?
    let governance: String?
}

struct MaestroDelegateRepresentativeVotingThresholds: Codable, Sendable {
    let noConfidence: String
    let constitutionalCommittee: MaestroConstitutionalCommitteeThresholds
    let constitution: String
    let hardForkInitiation: String
    let protocolParametersUpdate: MaestroProtocolParametersUpdate
    let treasuryWithdrawals: String
    
    enum CodingKeys: String, CodingKey {
        case noConfidence = "no_confidence"
        case constitutionalCommittee = "constitutional_committee"
        case constitution
        case hardForkInitiation = "hard_fork_initiation"
        case protocolParametersUpdate = "protocol_parameters_update"
        case treasuryWithdrawals = "treasury_withdrawals"
    }
}

// MARK: - Block Update

struct MaestroBlockUpdate: Codable, Sendable {
    let timestamp: String
    let blockHash: String
    let blockSlot: Int
    
    enum CodingKeys: String, CodingKey {
        case timestamp
        case blockHash = "block_hash"
        case blockSlot = "block_slot"
    }
}
