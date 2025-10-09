//
//  TransactionBuilder.swift
//  CardanoKit
//
//  Created by Gavin Harris on 17/9/2025.
//

import Testing
import XCTest
@testable import CardanoKit


@Test func minAdaOnUtxo() async throws {
    let words = "art forum devote street sure rather head chuckle guard poverty release quote oak craft enemy"
    let wallet = try CardanoWallet.fromMnemonic(accountIndex: 0, words: words)
    let receiveAddress = try wallet.getPaymentAddress()
    
    let mockAPI = try getMockAPI(address: try receiveAddress.asBech32())
    
    let provider = MaestroDataProvider(maestroApi: mockAPI)
    
    wallet.addDataProvider(dataProvider: provider)
    
    let walletUtxos = try await wallet.getUtxos()
    
    
    for utxo in walletUtxos {
        let minAda = try await utxo.output?.minAda(dataProvider: provider)
    
        print("\(utxo.input!.txHash!)#\(utxo.input!.index!)  = \(minAda!)")
    }
    
}



@Test func createTransactionBuilderConfig() async throws {
    
        
    let words = "art forum devote street sure rather head chuckle guard poverty release quote oak craft enemy"
    let wallet = try CardanoWallet.fromMnemonic(accountIndex: 0, words: words)
    let changeAddress = try wallet.getPaymentAddress()
    let receiveAddress = try wallet.getPaymentAddress(index: 2)
    let receiveAddress2 = try wallet.getPaymentAddress(index: 22)
    
    print("Change Address: \(changeAddress)")
    print("Receive Address: \(receiveAddress)")
    
    let mockAPI = try getMockAPI(address: try changeAddress.asBech32())
    
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
    
    #expect(try await wallet.submitTransaction(transaction: transaction) == txDetails.hash)
    
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

@Test func build_send_all_txn() async throws {
    
    let words = "art forum devote street sure rather head chuckle guard poverty release quote oak craft enemy"
    let wallet = try CardanoWallet.fromMnemonic(accountIndex: 0, words: words)
    let changeAddress = try wallet.getPaymentAddress()
    let receiveAddress = try wallet.getPaymentAddress(index: 2)
    
    let mockAPI = try getMockAPI(address: try changeAddress.asBech32())
    
    let provider = MaestroDataProvider(maestroApi: mockAPI)
    
    wallet.addDataProvider(dataProvider: provider)
    
    let walletUtxos = try await wallet.getUtxos()
    
    let txns = try await wallet.newSendAllTx(address_to: receiveAddress, utxos: walletUtxos)
    
    #expect(txns.length == 1)
    
    try txns.forEach { tx in
        print(try tx.toHex())
    }
}

@Test func validateNativeScript() throws {
    
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
    
    let hash = try mintScript.toHash().toHex()
    
    #expect("1f7a58a1aa1e6b047a42109ade331ce26c9c2cce027d043ff264fb1f" == hash)
    
    
    let multiSigScript = try NativeScript(json: """
        {
            "ScriptAll": {
                "native_scripts": [
                    {
                        "ScriptPubkey": {
                          "addr_keyhash": "a96da581c39549aeda81f539ac3940ac0cb53657e774ca7e68f15ed9"
                        }
                    },
                    {
                        "ScriptPubkey": {
                          "addr_keyhash": "ccfcb3fed004562be1354c837a4a4b9f4b1c2b6705229efeedd12d4d"
                        }
                    },
                    {
                        "ScriptPubkey": {
                          "addr_keyhash": "74fcd61aecebe36aa6b6cd4314027282fa4b41c3ce8af17d9b77d0d1"
                        }
                    }
                ]
            }
        }
        """)
    
    #expect(try multiSigScript.toHash().toHex() == "65c197d565e88a20885e535f93755682444d3c02fd44dd70883fe89e")
    
    
    /*
     
     */
    // 23c4a26e2a3db0f900a4c58ce94294276c8a71be235466c7e5ee3510
}

@Test func dbSyncNativeScriptFormat() throws {
    
    let ns = try NativeScript(cardanoScanJson:
    """
    {"type": "any", "scripts": [{"type": "all", "scripts": [{"type": "atLeast", "scripts": [{"type": "sig", "keyHash": "eaeb848139b224cd0c2eaba28ef17d788989d2ec4da3cda54281bbb8"}, {"type": "sig", "keyHash": "ea907a248ecb583061e02970e546772c12d05b12f12f8a4ac3e2ec76"}, {"type": "sig", "keyHash": "24c53409dce7186fa414d6bffb0d97002e7ceb1ead6f5ca7241488b7"}, {"type": "sig", "keyHash": "4c0b87c21190ad6f6144d0609761a8af515efd3fabcc8d929d63e9e3"}, {"type": "sig", "keyHash": "81c8c1aac5630911f570cb3c2222d16ee38d3501727507f67bb15dd3"}, {"type": "sig", "keyHash": "1423d22ea96d09b88162b1b7a9a88df1bfc2aec37cd805428d6a0d33"}], "required": 4}]}, {"type": "all", "scripts": [{"slot": 25732159, "type": "after"}, {"type": "atLeast", "scripts": [{"type": "sig", "keyHash": "eaeb848139b224cd0c2eaba28ef17d788989d2ec4da3cda54281bbb8"}, {"type": "sig", "keyHash": "ea907a248ecb583061e02970e546772c12d05b12f12f8a4ac3e2ec76"}, {"type": "sig", "keyHash": "24c53409dce7186fa414d6bffb0d97002e7ceb1ead6f5ca7241488b7"}, {"type": "sig", "keyHash": "4c0b87c21190ad6f6144d0609761a8af515efd3fabcc8d929d63e9e3"}, {"type": "sig", "keyHash": "81c8c1aac5630911f570cb3c2222d16ee38d3501727507f67bb15dd3"}, {"type": "sig", "keyHash": "1423d22ea96d09b88162b1b7a9a88df1bfc2aec37cd805428d6a0d33"}], "required": 2}]}, {"type": "all", "scripts": [{"slot": 25732159, "type": "after"}, {"type": "atLeast", "scripts": [{"type": "sig", "keyHash": "eaeb848139b224cd0c2eaba28ef17d788989d2ec4da3cda54281bbb8"}, {"type": "sig", "keyHash": "ea907a248ecb583061e02970e546772c12d05b12f12f8a4ac3e2ec76"}, {"type": "sig", "keyHash": "24c53409dce7186fa414d6bffb0d97002e7ceb1ead6f5ca7241488b7"}, {"type": "sig", "keyHash": "4c0b87c21190ad6f6144d0609761a8af515efd3fabcc8d929d63e9e3"}, {"type": "sig", "keyHash": "81c8c1aac5630911f570cb3c2222d16ee38d3501727507f67bb15dd3"}, {"type": "sig", "keyHash": "1423d22ea96d09b88162b1b7a9a88df1bfc2aec37cd805428d6a0d33"}], "required": 1}]}]}
    """)
        
    let json = try ns.toJson()
    
    print(json)
    
    let hash = try ns.toHash().toHex()
    
    #expect(hash == "23c4a26e2a3db0f900a4c58ce94294276c8a71be235466c7e5ee3510")
}

@Test func dbSyncNativeScriptFormat2() throws {
    let ns = try NativeScript(cardanoScanJson:
    """
    {"type": "any", "scripts": [{"type": "sig", "keyHash": "425432cbd6145e63f57c6bad51c84a21b6f502f8f4c7e88694c406ca"}, {"type": "sig", "keyHash": "9a2efb064c18b3a88e98e0e54582aedafe76a7c677165942b93864f6"}, {"type": "sig", "keyHash": "a691f91133037b4a7d29e29be4fce5f285edc8e09201d5531a581eef"}]}
    """)
    
    let hash = try ns.toHash().toHex()
    let nsCred = try ns.toCredential()
    let address = try Address(network: 1, paymentCred: nsCred, stakingCred: nsCred)
    
    #expect(hash == "8dd24cd36e712bd561b68481e6fa7d0b94eb76e9d0eeebee49bf2a28")
    let addrBech32 = try address.asBech32()
    
    #expect(addrBech32 == "addr1xxxaynxndecjh4tpk6zgreh6059ef6mka8gwa6lwfxlj52yd6fxdxmn3902krd5ys8n05lgtjn4hd6wsam47ujdl9g5q0ds9xc")
    
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
