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
    
    let mockAPI = try getMockAPI(address: try receiveAddress.asBech32())
    
    let provider = MaestroDataProvider(maestroApi: mockAPI)
    
    wallet.addDataProvider(dataProvider: provider)
    
    let walletUtxos = try await wallet.getUtxos()
    print("Walelt UTxOs: \(try walletUtxos.toJson())")
    
    let output = try TransactionOutput(
        address: receiveAddress.asBech32(),
        lovelace: 5_000_000,
        assets: [
            "83cb87b69639e20d7c99755fcfc310fb47882c3591778a3c869ea34c417473756b6f34383138": 1,
            "fc11a9ef431f81b837736be5f53e4da29b9469c983d07f321262ce614652454e": 20000
        ]
    )
    
    let output2 = try TransactionOutput(address: receiveAddress2.asBech32(), lovelace: 2_000_000, assets: ["53c07e65e63a4b49ce3810cea982370d115f3b699018a9378838574a446f6e6174696f6e202331333038": 1])
    
    print(try output.toJson())
    
    let start = CFAbsoluteTimeGetCurrent()
    
    let certs = try CertificatesBuilder()
        .addStakeDelegation(stake_address: wallet.getStakingAddress(), pool_key_hash: Ed25519KeyHash(hex: "3b3327c0a885ba7c1ebeec8b44158aab79c32148d45b4c701344cd97"))
        .addVoteDelegation(stake_address: wallet.getStakingAddress(), drep: .DelegateToBech32("drep1ytcw6qzpqqclx2yd0zy64ztvlkkhnf6yrzza8whgnq4vz5gh89626") )
    
    let mintScript = try NativeScript(json: """
        {
            "ScriptAll": {
                "native_scripts": [
                    {
                        "TimelockExpiry": {
                          "slot": "93121875"
                        }
                    },
                    {
                        "ScriptPubkey": {
                          "addr_keyhash": "24c75fefdf94496f8fd386648bc5edc20a7469282c5359c9745abaca"
                        }
                    }
                ]
            }
        }
        """)
    
    let mintAssetName = try AssetName(name: Data("CSLKit".utf8))
    
    let transaction = try await wallet.newTx()
        .addOutput(output: output)
        .addOutput(output: output2)
        .addCertificates(cert_builder: certs)
        .addMint(native_script: mintScript, asset_name: mintAssetName, amount: 1)
        .addInputsFrom(inputs: walletUtxos, strategy: .RandomImproveMultiAsset)
        .setChangeAddress(address: changeAddress)
        .build()
    
    let diff = CFAbsoluteTimeGetCurrent() - start
    print("Execution time: \(diff) seconds")
    
    let txDetails = try await TxDetailsFactory(provider: provider)
        .makeDetails(transaction: transaction)
    
    print(txDetails.inputSummary)
    
    print(try transaction.toHex())
    
    
    
    let outputStays = try TransactionOutput(
        address: changeAddress.asBech32(),
        lovelace: 5_000_000,
        assets: [:]
    )
    
    
    let send_all_txn = try await wallet.newTx()
        .addOutput(output: outputStays)
        .addInputsFrom(inputs: walletUtxos)
        .setChangeAddress(address: receiveAddress2)
        .build()
    
    print(try send_all_txn.toHex())
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
