//
//  TransactionBuilder.swift
//  CardanoKit
//
//  Created by Gavin Harris on 17/9/2025.
//

import Testing
import XCTest
@testable import CardanoKit

@Test func createTransactionBuilderConfig() async throws {
    
        
    let words = "art forum devote street sure rather head chuckle guard poverty release quote oak craft enemy"
    let wallet = try CardanoWallet.fromMnemonic(accountIndex: 0, words: words)
    let changeAddress = try wallet.getPaymentAddress()
    let receiveAddress = try wallet.getPaymentAddress(index: 2)
    let receiveAddress2 = try wallet.getPaymentAddress(index: 22)
    
    print("Change Address: \(changeAddress)")
    print("Receive Address: \(receiveAddress)")
    
    let mockAPI = getMockAPI(address: try receiveAddress.asBech32())
    
    let provider = MaestroDataProvider(maestroApi: mockAPI)
    
    wallet.addDataProvider(dataProvider: provider)
    
    let walletUtxos = try await wallet.getUtxos()
    let output = try TransactionOutput(
        address: receiveAddress.asBech32(),
        lovelace: 5_000_000,
        assets: ["83cb87b69639e20d7c99755fcfc310fb47882c3591778a3c869ea34c417473756b6f34383138": 1]
    )
    
    let output2 = try TransactionOutput(address: receiveAddress2.asBech32(), lovelace: 2_000_000, assets: ["a7bf4ce10dca4f5f99b081c4ea84e0e3f919775b953324e09edea852536865446576696c7331333636": 1])
    
    print(try output.toJson())
    
    let start = CFAbsoluteTimeGetCurrent()
    let transaction = try await wallet.newTx()
        .addInputsFrom(inputs: walletUtxos)
        .addOutput(output: output)
        .addOutput(output: output2)
        .setChangeAddress(address: changeAddress)
        .build()
    
    let diff = CFAbsoluteTimeGetCurrent() - start
    
    
    print("Execution time: \(diff) seconds")
    
    print(try transaction.toHex())
}

@Test func createMultiAssetFromMap() throws {
    
    let hexStr = "aaaa"
    
    let d = Data(hex: hexStr)!
    print([UInt8](d))
    let an = try AssetName(name: d)
    print(try an.toJson())
    
    let initData = [
        "1f7a58a1aa1e6b047a42109ade331ce26c9c2cce027d043ff264fb1f": Int64(1),
        "1f7a58a1aa1e6b047a42109ade331ce26c9c2cce027d043ff264fb1faaaa": Int64(3)
    ]
    
    let multiAsset = try MultiAsset(from: initData)
    
    print(try multiAsset.toJson())
    
}


@Test func validateTheSplitUnitFunction() {
    var res = splitUnit("1f7a58a1aa1e6b047a42109ade331ce26c9c2cce027d043ff264fb1f")
    
    #expect(res.policy == "1f7a58a1aa1e6b047a42109ade331ce26c9c2cce027d043ff264fb1f")
    #expect(res.assetName == "")
    
    
    res = splitUnit("1f7a58a1aa1e6b047a42109ade331ce26c9c2cce027d043ff264fb1faaaa")
    
    #expect(res.policy == "1f7a58a1aa1e6b047a42109ade331ce26c9c2cce027d043ff264fb1f")
    #expect(res.assetName == "aaaa")
}

@Test func validateNormalizeFunc() {
    let initData = [
        "1f7a58a1aa1e6b047a42109ade331ce26c9c2cce027d043ff264fb1f": Int64(1),
        "1f7a58a1aa1e6b047a42109ade331ce26c9c2cce027d043ff264fb1faaaa": Int64(3)
    ]
    
    print(normalize(initData))
}
