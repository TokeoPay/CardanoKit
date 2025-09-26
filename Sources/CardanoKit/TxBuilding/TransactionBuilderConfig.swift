//
//  TransactionBuilderConfig.swift
//  CardanoKit
//
//  Created by Gavin Harris on 21/7/2025.
//

import Foundation
import CSLKit

public class CostModels {
    private var ptr: OpaqueRustPointer<CSLKit.Types.CSL_CostModel>
    
    init() throws {
        self.ptr = try CSLKit.costModelNew()
    }
    
    public func set(operation: Int64, cost: Int) throws {
        try CSLKit.costModelSet(self_rptr: self.ptr, operation: operation, cost_rptr: CSLKit.intFromStr(string_str: "\(cost)"))
    }
}

public class TransactionBuilderConfigBuilder {
    private var ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionBuilderConfigBuilder>
    
    public init() throws {
        let configBuilder = try CSLKit.transactionBuilderConfigBuilderNew()
        self.ptr = configBuilder
    }
    
    public func setFeeAlgo(coefficient: String, constant: String) throws {
        let coefficientBigNum = try CSLKit.bigNumFromStr(string_str: coefficient)
        let constantBigNum = try CSLKit.bigNumFromStr(string_str: constant)
        let linearFee = try CSLKit.linearFeeNew(coefficient_rptr: coefficientBigNum, constant_rptr: constantBigNum)
        
        self.ptr = try CSLKit.transactionBuilderConfigBuilderFeeAlgo(self_rptr: self.ptr, fee_algo_rptr: linearFee)
    }
    
    public func setCoinsPerUtxoByte(coinsPerUtxoByte: String) throws {
        self.ptr = try CSLKit.transactionBuilderConfigBuilderCoinsPerUtxoByte(
            self_rptr: self.ptr,
            coins_per_utxo_byte_rptr: CSLKit.bigNumFromStr(string_str: coinsPerUtxoByte)
        )
    }
    
    
    private func gcd(_ a: Int, _ b: Int) -> Int {
        var a = a
        var b = b
        while b != 0 {
            let temp = b
            b = a % b
            a = temp
        }
        return a
    }
    
    private func floatToFraction(
        _ value: Float,
        maxDenominator: Int = 100000,
        tolerance: Float = 0.00001
    ) -> (numerator: Int, denominator: Int)? {
        if value == 0 {
            return (0, 1)
        }
        
        let sign = value < 0 ? -1 : 1
        let absValue = abs(value)
        
        let wholeNumberPart = Int(floor(absValue))
        let fractionalPart = absValue - Float(wholeNumberPart)
        
        if fractionalPart < tolerance { // If it's essentially a whole number
            return (sign * wholeNumberPart, 1)
        }
        
        var bestNumerator = 0
        var bestDenominator = 1
        var bestError: Float = .infinity
        
        for denominator in 1...maxDenominator {
            let numerator = Int(round(fractionalPart * Float(denominator)))
            let currentError = abs(fractionalPart - (Float(numerator) / Float(denominator)))
            
            if currentError < bestError {
                bestError = currentError
                bestNumerator = numerator
                bestDenominator = denominator
                if currentError < tolerance {
                    break // Found a sufficiently accurate fraction
                }
            }
        }
        
        // Simplify the fraction
        let commonDivisor = gcd(bestNumerator, bestDenominator)
        let simplifiedNumerator = bestNumerator / commonDivisor
        let simplifiedDenominator = bestDenominator / commonDivisor
        
        // Combine with the whole number part
        let finalNumerator = sign * (wholeNumberPart * simplifiedDenominator + simplifiedNumerator)
        
        return (finalNumerator, simplifiedDenominator)
    }
    
    
    public func setExUnitPrices(mem: String, step: String) throws {
        
        let memParts = mem.split(separator: "/")
        guard memParts.count == 2 else {
            throw StringToFloatError.invalidFormat(mem)
        }
        let stepParts = step.split(separator: "/")
        guard stepParts.count == 2 else {
            throw StringToFloatError.invalidFormat(step)
        }
                
        let exUnits = try CSLKit.exUnitPricesNew(
            mem_price_rptr: CSLKit.unitIntervalNew(
                numerator_rptr: CSLKit.bigNumFromStr(string_str: memParts[0].lowercased() ),
                denominator_rptr: CSLKit.bigNumFromStr(string_str: memParts[1].lowercased() )
            ), step_price_rptr: CSLKit.unitIntervalNew(
                numerator_rptr: CSLKit.bigNumFromStr(string_str: stepParts[0].lowercased()),
                denominator_rptr: CSLKit.bigNumFromStr(string_str: stepParts[1].lowercased())
            )
        )
        
        
        self.ptr = try CSLKit.transactionBuilderConfigBuilderExUnitPrices(
            self_rptr: self.ptr,
            ex_unit_prices_rptr: exUnits
        )
    }
    
    public func setExUnitPrices(mem: Float, steps: Float) throws {
        let memFrac = floatToFraction(mem)
        let stepFrac = floatToFraction(steps)
        
        let exUnits = try CSLKit.exUnitPricesNew(
            mem_price_rptr: CSLKit.unitIntervalNew(
                numerator_rptr: CSLKit.bigNumFromStr(string_str: "\(String(describing: memFrac?.numerator))"),
                denominator_rptr: CSLKit.bigNumFromStr(string_str: "\(String(describing: memFrac?.denominator))")
            ), step_price_rptr: CSLKit.unitIntervalNew(
                numerator_rptr: CSLKit.bigNumFromStr(string_str: "\(String(describing: stepFrac?.numerator))"),
                denominator_rptr: CSLKit.bigNumFromStr(string_str: "\(String(describing: stepFrac?.denominator))")
            )
        )
        
        self.ptr = try CSLKit.transactionBuilderConfigBuilderExUnitPrices(
            self_rptr: self.ptr,
            ex_unit_prices_rptr: exUnits
        )
    }
    
    public func setPoolDeposit(poolDeposit: String) throws {
        self.ptr = try CSLKit.transactionBuilderConfigBuilderPoolDeposit(
            self_rptr: self.ptr,
            pool_deposit_rptr: CSLKit.bigNumFromStr(string_str: poolDeposit)
        )
    }
    
    public func setKeyDeposit(keyDeposit: String) throws {
        self.ptr = try CSLKit.transactionBuilderConfigBuilderKeyDeposit(self_rptr: self.ptr, key_deposit_rptr: CSLKit.bigNumFromStr(string_str: keyDeposit))
    }
    
    public func setMaxValueSize(maxValueSize: Int64) throws {
        self.ptr = try CSLKit.transactionBuilderConfigBuilderMaxValueSize(self_rptr: self.ptr, max_value_size_long: maxValueSize)
    }
    
    public func setMaxTxSize(maxTxSize: Int64) throws {
        self.ptr = try CSLKit.transactionBuilderConfigBuilderMaxTxSize(self_rptr: self.ptr, max_tx_size_long: maxTxSize)
    }
    
    public func setRefScriptCoinsPerByte(refScriptCoinsPerByte: Float) throws {
        let coinsPerByteFrac = floatToFraction(refScriptCoinsPerByte)
        
        self.ptr = try CSLKit.transactionBuilderConfigBuilderRefScriptCoinsPerByte(
            self_rptr: self.ptr,
            ref_script_coins_per_byte_rptr: CSLKit.unitIntervalNew(
                numerator_rptr: CSLKit.bigNumFromStr(string_str: "\(String(describing: coinsPerByteFrac?.numerator))"),
                denominator_rptr: CSLKit.bigNumFromStr(string_str: "\(String(describing: coinsPerByteFrac?.denominator))")
            )
        )
    }
    public func setPreferPureChange(preferPureChange: Bool) throws {
        self.ptr = try CSLKit.transactionBuilderConfigBuilderPreferPureChange(self_rptr: self.ptr, prefer_pure_change: preferPureChange)
    }
    
    public func setDeduplicateExplicitRefInputsWithRegularInputs(deduplicate: Bool) throws {
        self.ptr = try CSLKit.transactionBuilderConfigBuilderDeduplicateExplicitRefInputsWithRegularInputs(self_rptr: self.ptr, deduplicate_explicit_ref_inputs_with_regular_inputs: deduplicate)
    }
    public func setDoNotBurnExtraChange(doNotBurn: Bool) throws {
        self.ptr = try CSLKit.transactionBuilderConfigBuilderDoNotBurnExtraChange(self_rptr: self.ptr, do_not_burn_extra_change: doNotBurn)
    }
    
    public func build() throws -> TransactionBuilderConfig {
        return TransactionBuilderConfig(ptr: try CSLKit.transactionBuilderConfigBuilderBuild(self_rptr: self.ptr))
    }
}

public class TransactionBuilderConfig {
    var ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionBuilderConfig>
    
    internal init(ptr: OpaqueRustPointer<CSLKit.Types.CSL_TransactionBuilderConfig>) {
        self.ptr = ptr
    }
    
}
