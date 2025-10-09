//
//  CardanoWalletTesting.swift
//  CardanoKit
//
//  Created by Gavin Harris on 22/7/2025.
//

import Testing
import Bip39
import Foundation
@testable import CardanoKit

@Test func test_create_from_words_priv_key_bech32() async throws {
    let words = "art forum devote street sure rather head chuckle guard poverty release quote oak craft enemy"
    let wallet = try CardanoWallet.fromMnemonic(accountIndex: 0, words: words)
    
    print("\n\n\(try wallet.getRootPrivateKey().toString())")
    print("\n\n\(try wallet.getRootPrivateKey().toPublic().hash().toHex())" )
    
    //xprv19z0p4rhsg0cukx2hgt60ldnzttfuxu3muazgwkhlxw6knm7qg3y9s6mcjhl8z8vhk5kv5y0jekgu4hulszv56whjtrcs42qdztk2u6jr6vnjnzwk88u66v2fk3acjadagq76k3pz4nc5wsqlf8ewzv6vncudtth6
    //xprv18rnnvw3ejdqmfhmfgjc54w80dzejcxvsnrn45wg9ah6res74f994qqnvkl589jzredqqf0fx9armcxu7vwrduuyc7qns32rn9jesttk6mp6whgzaljd29m32yt9hqgrcrzm30nuvdt65r2p64grhmjkdvqmehfzm
    
    //09544bc8c3c494bbadbd4f44bc7f09ef7728cd517cdc1b40b9d282a3
    //46f3613f11e45d18c301b82c8c59256f3795bb1b848283d2a293725a
//    print(try wallet.getRootPrivateKey().toString())
    
}

@Test func test_create_new_wallet_24_words() async throws {
    let wallet = try CardanoWallet.generate(accountIndex: 0, wordCount: .SOLID)
    let words = wallet.getMnumonic()
    
    #expect(words.count == 24)
    print("\n\n\(words.count)")
}



extension Data {
    /// Converts a Data object to a hexadecimal encoded string.
    var hexEncodedString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    /// Initializes a Data object from a hexadecimal encoded string.
    ///
    /// - Parameter hexString: The hexadecimal string to convert.
    /// - Returns: A Data object, or nil if the string is not valid hexadecimal.
    init?(hexString: String) {
        let len = hexString.count
        guard len % 2 == 0 else { return nil } // Hex strings must have an even number of characters
        
        var data = Data(capacity: len / 2)
        var i = hexString.startIndex
        while i < hexString.endIndex {
            let j = hexString.index(i, offsetBy: 2)
            let bytes = hexString[i..<j]
            if let byte = UInt8(bytes, radix: 16) {
                data.append(byte)
            } else {
                return nil // Invalid hex character
            }
            i = j
        }
        self = data
    }
}



@Test func test_create_new_wallet_words() async throws {
    var wallet = try CardanoWallet.generate(accountIndex: 0, wordCount: .POOR)
    var words = wallet.getMnumonic()
    
    #expect(words.count == 12)
    
    wallet = try CardanoWallet.generate(accountIndex: 0, wordCount: .WEAK)
    words = wallet.getMnumonic()
    
    #expect(words.count == 15)
    
    wallet = try CardanoWallet.generate(accountIndex: 0, wordCount: .OKAY)
    words = wallet.getMnumonic()
    
    #expect(words.count == 18)
    
    wallet = try CardanoWallet.generate(accountIndex: 0, wordCount: .GOOD)
    words = wallet.getMnumonic()
    
    #expect(words.count == 21)
    
    wallet = try CardanoWallet.generate(accountIndex: 0, wordCount: .SOLID)
    words = wallet.getMnumonic()
    
    #expect(words.count == 24)
}

@Test func test_from_entropy_priv_key_bech32() async throws {
    let wallet = try CardanoWallet.fromEntropy(accountIndex: 0, entropy: [0xdf, 0x9e, 0xd2, 0x5e, 0xd1, 0x46, 0xbf, 0x43, 0x33, 0x6a, 0x5d, 0x7c, 0xf7, 0x39, 0x59, 0x94])
    
    let pk_bech32 = try wallet.getPaymentPrivateKey().toString()
    print("\n\n >> \(pk_bech32)")
    
    #expect(pk_bech32 == "xprv1hqf6v2lvhfn5mr3fe6g8ac6n8a3z6s0p24mg6kre8jadxulp530y07wjp2ml0zcz8gk0xc7zy96qp2xxtr0arjq9038k9dhkw3k3cswawhs4fkjp00kwc4wd6fynyaz5zw8ssggs9974apatyhs4ltg4puyevpgm", " >> Generated Private Keys do not match!! This is bad")
    
}
    

@Test func test_create_from_entropy_address_to_bech32() async throws {
    let wallet = try CardanoWallet.fromEntropy(accountIndex: 0, entropy: [0xdf, 0x9e, 0xd2, 0x5e, 0xd1, 0x46, 0xbf, 0x43, 0x33, 0x6a, 0x5d, 0x7c, 0xf7, 0x39, 0x59,
                                                                          0x94])
    #expect(try wallet.getPaymentAddress().asBech32() == "addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp")
}

@Test func test_create_from_words_address_to_bech32() async throws {
    let words = "art forum devote street sure rather head chuckle guard poverty release quote oak craft enemy"
    let wallet = try CardanoWallet.fromMnemonic(accountIndex: 0, words: words)
    #expect(try wallet.getPaymentAddress(index: 0).asBech32() == "addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w")
    
    
}

@Test func test_signing_some_data() async throws {
    let words = "art forum devote street sure rather head chuckle guard poverty release quote oak craft enemy"
    let wallet = try CardanoWallet.fromMnemonic(accountIndex: 0, words: words)
    
    let stringToSign = "Hello, Tokers"
    
    let signature = try wallet.signData(data: Data(stringToSign.utf8), withAddress: try wallet.getPaymentAddress(index: 15).asBech32())

    print(" >> Signed Result: ", signature!)
}


@Test func test_parsing_a_transaction() async throws {
    let txCbor = "84a300d90102818258207e98967ba336f16739f1465171a2089a16042bdff12dc9d2dfead6234c06aa09010182a3005839110f5ace66a2d997176735c1042d5cbdc69cfed2265fd856d83210d6bf1847f764f368dfa8ca5a4e96ab7fca3bdbc803050b6b9510796c6f0101821a0014524ea1581c375df3f2fb44d3c42b3381a09edd4ea2303a57ada32b5308c0774ee0a144544f4b4519025c028201d8185821d87981581c1847f764f368dfa8ca5a4e96ab7fca3bdbc803050b6b9510796c6f018258390157fa4b53d596c18c45c26aa743e770f0857cac082ed3658b9b25d8d91847f764f368dfa8ca5a4e96ab7fca3bdbc803050b6b9510796c6f01821a08ef0577a5581c2afb448ef716bfbed1dcb676102194c3009bee5399e93b90def9db6aa1454249534f4e05581c420000029ad9527271b1b1e3c27ee065c18df70a4a4cfc3093a41a44a14341584f1a3b4edfec581c5c1c91a65bedac56f245b8184b5820ced3d2f1540e521dc1060fa683a1454a454c4c591a02faf080581c8fe8039d057c71fdfb1095e260f153f18a5834d85d9c868ddf7307bca14a0014df10414e47454c531a000aafe1581cba92e5f4665a026f7d5f2f223d398d2d8b649e147b5163b759bd61a0a34a54696765727a31363634014a54696765727a32373739014a54696765727a3338363401021a0002c87da0f5f6"
    
    let txn = try FixedTransaction.fromHex(hex: txCbor)
    let hash = try txn.hash()
    #expect(hash == "5024b4d07c9a27257201b266a44ae1b28a842c9fbb43c9b4e0c2d016f2238c0e")
    print("Fee: \(try txn.getFee()!)")
}

@Test func test_parse_a_transaction_2() async throws {
    let txCbor = "84a500818258207233486deda2a6c5258a1c758e48a4e6adf5dd936e448c58819afb97f73e2c6500018383583931c727443d77df6cff95dca383994f4c3024d03ff56b02ecc22b0f3f652c967f4bd28944b06462e13c5e3f5d5fa6e03f8567569438cd833e6d821a001473faa1581c2341201e2508eaebd9acaecbaa7630350cee6ebf437c52cc42bab23ea151477265656479476f626c696e7331333635015820ce96091328eb06b95814505a4c936c848d2509362e3979ba39f85b364f5561e782583901829f189e40ce8ee7bfeb44cba97435fa07f16471dcfdb54dfb71e3208df11bbb405a7d1cab4f3041c9ba6efce2edff9b027b6ca4c73e97d3821a0013669aa1581c2341201e2508eaebd9acaecbaa7630350cee6ebf437c52cc42bab23ea250477265656479476f626c696e733536340151477265656479476f626c696e73333333370182583901829f189e40ce8ee7bfeb44cba97435fa07f16471dcfdb54dfb71e3208df11bbb405a7d1cab4f3041c9ba6efce2edff9b027b6ca4c73e97d31a002164a3021a00030c09031a093bd62b075820c5a85e24ee5da45cd06c118cd6be8ce5a33a505d9b3dc8f7b8fa27ce0c59be86a0f5a8181e61361832784064383739396639666438373939666438373939666438373939663538316337306464346166353762363964393634386239333636663330396634373037303335183378403035636163393764313032306537353530616433353866666438373939666438373939666438373939663538316336383134303631646234363339623634323918347840626439363666323764316261653761326637323362393162643063383234613330653633383766666666666666663161303030663432343066666438373939661835784064383739396664383739396635383163383239663138396534306365386565376266656234346362613937343335666130376631363437316463666462353464183678406662373165333230666664383739396664383739396664383739396635383163386466313162626234303561376431636162346633303431633962613665666318377840653265646666396230323762366361346337336539376433666666666666666631613030376131323030666666663538316338323966313839653430636538651838782d65376266656234346362613937343335666130376631363437316463666462353464666237316533323066662c"
    
    let txn = try FixedTransaction.fromHex(hex: txCbor)
    
    #expect(try txn.hash() == "359f5f7ea6224cb3928940ab96ee15df9a8f46ddca1bbb74f339fd5e3db914b5")
}

@Test func test_parse_a_transaction_3() async throws {
    let wallet = try CardanoWallet.fromEntropy(accountIndex: 0, entropy: [0xdf, 0x9e, 0xd2, 0x5e, 0xd1, 0x46, 0xbf, 0x43, 0x33, 0x6a, 0x5d, 0x7c, 0xf7, 0x39, 0x59,
                                                                          0x94])
    
    let txCbor = "84a500d901028182582017bcdc99e7f23e258f203a5763231b087ab65dc7954c0f831d0e6c9c51ac6a9e00018182583901b41d92fcf625e1fe7299485b9e8addaf85d71adb60d7e1eb8b07aa8c90de4eebcafc932020d48ae73de353cdacd96335e03f7e6e7ac2d5d41b00000006de350c67021a0002b61904d901028282008200581c90de4eebcafc932020d48ae73de353cdacd96335e03f7e6e7ac2d5d483028200581c90de4eebcafc932020d48ae73de353cdacd96335e03f7e6e7ac2d5d4581ceaa28db3bf0b7bb815b552fc9e0cecdda62933ce6c67067183c79acd075820f6b7955dd6f8a1e5d1a22079ec18237cd0669f1bdcbee3e7036413fe208d9008a10082825820c28ec62cc6d73eb185fa4518055300484b872335a68342b35f9a37ac0d7681f858406cc3cee983127ab98f2b7fbfddc144f2cf5e4ee37897f3265dc12bdb265c3f7baa6381ea50d23db6868675281036c2a46a729440efc81c817c3d6954f2ad6603825820c1d8c2b5527459919ca747cfec4cbb4240aafa772aa801ec17a9b5212ae5a5b85840c4bb3632d8891731d6d9a66b2804afb2196c36a6b52321b69f44646004d6da3a096d17fbc297c9ddb3571c06abb1655b686ee315d59d19c6e20d6f9132a9320ff5a11902a2a1636d73677819546f6b656f2064656c65676174696f6e20f09fa5b7f09f8fbb"
    
    let txn = try FixedTransaction.fromHex(hex: txCbor)
    
    #expect(try txn.hash() == "44aa05d4f45b7292a54a1159a99550aac984bb305c0d6d2cfa175169826299a5")
    
    let utxoCbor = "8282582017bcdc99e7f23e258f203a5763231b087ab65dc7954c0f831d0e6c9c51ac6a9e008258390087d750a165eaaafaecb4b2b72109c293a21843cafbdb0488ff6a6db432c728d3861e164cab28cb8f006448139c8f1740ffb8e7aa9e5232dc1b00000006de564700"
    
    let utxo = try TransactionUnspentOutput.fromHex(hex: utxoCbor)
    
    let utxos = try TransactionUnspentOutputs()
    try utxos.addUtxo(utxo: utxo)
    
    let requiredSigners = try txn.getRequiredSignerKeyHashes(utxos: utxos)
        
    requiredSigners.forEach {
        print($0.hexEncodedString(), "\n")
    }
    
    #expect(requiredSigners.count == 2)
    #expect( 
        requiredSigners.first(where: { $0.hexEncodedString() == "87d750a165eaaafaecb4b2b72109c293a21843cafbdb0488ff6a6db4"}) != nil
    )
    
    try wallet.signTransaction(transaction: txn, utxos: utxos)
    
    print(try txn.toHex())
    
}

@Test func test_signing_a_drep_and_stake_withdrawal_txn() async throws {
    let txCbor = "84a500d90102828258200d166a315da425016882f0e167ac6436333c05ecd4cc3f6d9049492b9878e4e8182e82582052781407e9e8e5a00a06aa1b8a096c8085d05b237a9f67d11d0c968e4040840801018282583901b43b148f9c0ed673ee20019cb3623d5d2bed7e2da001ea3096e2d9bf79467c69a9ac66280174d09d62575ba955748b21dec3b483a9469a651a07246a8982583901b43b148f9c0ed673ee20019cb3623d5d2bed7e2da001ea3096e2d9bf9c4bcdd7ff3cb4e66593f9274583b066fafdb22453774411602f901b821a004e7686a1581c8f14c6ac45dd64212f767b37e030e322de401c699113c9abd49a162ea14541434c415901021a0002ce5504d901028183098200581ccc339a35f9e0fe039cf510c761d4dd29040c48e9657fdac7e9c01d94810205a1581de1cc339a35f9e0fe039cf510c761d4dd29040c48e9657fdac7e9c01d941a0717f69ea0f5f6"
    
    
    let txn = try FixedTransaction.fromHex(hex: txCbor)
    
    let utxos = try TransactionUnspentOutputs()
    
    //
    
    try utxos.addUtxo(utxo:
          TransactionUnspentOutput(
            input: TransactionInput(txHash: "0d166a315da425016882f0e167ac6436333c05ecd4cc3f6d9049492b9878e4e8", index: 46),
            output: TransactionOutput(hex: "8258390079467c69a9ac66280174d09d62575ba955748b21dec3b483a9469a65cc339a35f9e0fe039cf510c761d4dd29040c48e9657fdac7e9c01d94821a00116d86a1581c8f14c6ac45dd64212f767b37e030e322de401c699113c9abd49a162ea14541434c415901"))
    )
    
    try utxos.addUtxo(utxo:
          TransactionUnspentOutput(
                            input: TransactionInput(txHash: "52781407e9e8e5a00a06aa1b8a096c8085d05b237a9f67d11d0c968e40408408", index: 0),
                            output: TransactionOutput(hex: "8258390079467c69a9ac66280174d09d62575ba955748b21dec3b483a9469a65cc339a35f9e0fe039cf510c761d4dd29040c48e9657fdac7e9c01d941b00000001cc2cb30b"))
    )
    
    
    
    let words = "art forum devote street sure rather head chuckle guard poverty release quote oak craft enemy"
    let wallet = try CardanoWallet.fromMnemonic(accountIndex: 0, words: words)
    
    let requiredSigners = try txn.getRequiredSignerKeyHashes(utxos: utxos)
    
    print("Required Signers: \(requiredSigners.map { $0.hexEncodedString() })")
    print("Tx Hash: \(try txn.hash())")
    
    print(try wallet.getStakingAddress().asBech32())
    print(try wallet.getStakingAddress().asHex())
    
    #expect( requiredSigners.map { $0.hexEncodedString() }.contains(where: { $0 == "79467c69a9ac66280174d09d62575ba955748b21dec3b483a9469a65"}) ) // ??
    #expect( requiredSigners.map { $0.hexEncodedString() }.contains(where: { $0 == "cc339a35f9e0fe039cf510c761d4dd29040c48e9657fdac7e9c01d94"}) ) // ??
    
    // 8200581c79467c69a9ac66280174d09d62575ba955748b21dec3b483a9469a65
    //         cc339a35f9e0fe039cf510c761d4dd29040c48e9657fdac7e9c01d94
    //         9c4bcdd7ff3cb4e66593f9274583b066fafdb22453774411602f901b
    
    #expect(requiredSigners.count == 2)
    
    #expect(try txn.hash() == "05708e6b0eac21fefa4b2708fd8342bea83bee5df4f515035007aa644e862fab")
    
    try wallet.signTransaction(transaction: txn, utxos: utxos)
    
    print(try txn.toHex())
    
}

@Test func test_parse_and_sign_a_transaction() async throws {
    let txCbor = "84a500818258207233486deda2a6c5258a1c758e48a4e6adf5dd936e448c58819afb97f73e2c6500018383583931c727443d77df6cff95dca383994f4c3024d03ff56b02ecc22b0f3f652c967f4bd28944b06462e13c5e3f5d5fa6e03f8567569438cd833e6d821a001473faa1581c2341201e2508eaebd9acaecbaa7630350cee6ebf437c52cc42bab23ea151477265656479476f626c696e7331333635015820ce96091328eb06b95814505a4c936c848d2509362e3979ba39f85b364f5561e782583901829f189e40ce8ee7bfeb44cba97435fa07f16471dcfdb54dfb71e3208df11bbb405a7d1cab4f3041c9ba6efce2edff9b027b6ca4c73e97d3821a0013669aa1581c2341201e2508eaebd9acaecbaa7630350cee6ebf437c52cc42bab23ea250477265656479476f626c696e733536340151477265656479476f626c696e73333333370182583901829f189e40ce8ee7bfeb44cba97435fa07f16471dcfdb54dfb71e3208df11bbb405a7d1cab4f3041c9ba6efce2edff9b027b6ca4c73e97d31a002164a3021a00030c09031a093bd62b075820c5a85e24ee5da45cd06c118cd6be8ce5a33a505d9b3dc8f7b8fa27ce0c59be86a0f5a8181e61361832784064383739396639666438373939666438373939666438373939663538316337306464346166353762363964393634386239333636663330396634373037303335183378403035636163393764313032306537353530616433353866666438373939666438373939666438373939663538316336383134303631646234363339623634323918347840626439363666323764316261653761326637323362393162643063383234613330653633383766666666666666663161303030663432343066666438373939661835784064383739396664383739396635383163383239663138396534306365386565376266656234346362613937343335666130376631363437316463666462353464183678406662373165333230666664383739396664383739396664383739396635383163386466313162626234303561376431636162346633303431633962613665666318377840653265646666396230323762366361346337336539376433666666666666666631613030376131323030666666663538316338323966313839653430636538651838782d65376266656234346362613937343335666130376631363437316463666462353464666237316533323066662c"
    
    
    let words = "art forum devote street sure rather head chuckle guard poverty release quote oak craft enemy"
    let wallet = try CardanoWallet.fromMnemonic(accountIndex: 0, words: words)
    
    let txn = try FixedTransaction.fromHex(hex: txCbor)
        
    #expect(try txn.hash() == "359f5f7ea6224cb3928940ab96ee15df9a8f46ddca1bbb74f339fd5e3db914b5")
        
    let fee = try txn.getFee()
    #expect(199689 == fee)
    
    let utxoCbor = "828258207233486deda2a6c5258a1c758e48a4e6adf5dd936e448c58819afb97f73e2c65008258390179467c69a9ac66280174d09d62575ba955748b21dec3b483a9469a658df11bbb405a7d1cab4f3041c9ba6efce2edff9b027b6ca4c73e97d3821a004c4b40a1581c2341201e2508eaebd9acaecbaa7630350cee6ebf437c52cc42bab23ea350477265656479476f626c696e733536340151477265656479476f626c696e73313336350151477265656479476f626c696e733333333701"
        
    let utxo = try TransactionUnspentOutput.fromHex(hex: utxoCbor)
    
    let utxos = try TransactionUnspentOutputs()
    try utxos.addUtxo(utxo: utxo)
    
    let requiredSigners = try txn.getRequiredSignerKeyHashes(utxos: utxos)
    
    requiredSigners.forEach {
        print($0.hexEncodedString(), "\n")
    }
    
    #expect(requiredSigners.count == 1)
    #expect(requiredSigners[0].hexEncodedString() == "79467c69a9ac66280174d09d62575ba955748b21dec3b483a9469a65")
    
    try wallet.signTransaction(transaction: txn, utxos: utxos)
    
    print("Signed TX", try txn.toHex())
    #expect(try txn.toHex() == "84a500818258207233486deda2a6c5258a1c758e48a4e6adf5dd936e448c58819afb97f73e2c6500018383583931c727443d77df6cff95dca383994f4c3024d03ff56b02ecc22b0f3f652c967f4bd28944b06462e13c5e3f5d5fa6e03f8567569438cd833e6d821a001473faa1581c2341201e2508eaebd9acaecbaa7630350cee6ebf437c52cc42bab23ea151477265656479476f626c696e7331333635015820ce96091328eb06b95814505a4c936c848d2509362e3979ba39f85b364f5561e782583901829f189e40ce8ee7bfeb44cba97435fa07f16471dcfdb54dfb71e3208df11bbb405a7d1cab4f3041c9ba6efce2edff9b027b6ca4c73e97d3821a0013669aa1581c2341201e2508eaebd9acaecbaa7630350cee6ebf437c52cc42bab23ea250477265656479476f626c696e733536340151477265656479476f626c696e73333333370182583901829f189e40ce8ee7bfeb44cba97435fa07f16471dcfdb54dfb71e3208df11bbb405a7d1cab4f3041c9ba6efce2edff9b027b6ca4c73e97d31a002164a3021a00030c09031a093bd62b075820c5a85e24ee5da45cd06c118cd6be8ce5a33a505d9b3dc8f7b8fa27ce0c59be86a10081825820489ef28ea97f719ee7768645fc74b811c271e5d7ef06c2310854db30158e945d58405803f32e3fbaba2ed8fe91397a47b1d61ee26c8b560487bd9cfd866fa5624589af840c6b3a75f83d1dc2c4038dde521f8d36210abf32d52a64be4fb2a60c680bf5a8181e61361832784064383739396639666438373939666438373939666438373939663538316337306464346166353762363964393634386239333636663330396634373037303335183378403035636163393764313032306537353530616433353866666438373939666438373939666438373939663538316336383134303631646234363339623634323918347840626439363666323764316261653761326637323362393162643063383234613330653633383766666666666666663161303030663432343066666438373939661835784064383739396664383739396635383163383239663138396534306365386565376266656234346362613937343335666130376631363437316463666462353464183678406662373165333230666664383739396664383739396664383739396635383163386466313162626234303561376431636162346633303431633962613665666318377840653265646666396230323762366361346337336539376433666666666666666631613030376131323030666666663538316338323966313839653430636538651838782d65376266656234346362613937343335666130376631363437316463666462353464666237316533323066662c")
    
    
}


@Test func test_getUtxos_when_there_are_no_utxos() async throws {
    let words = "art forum devote street sure rather head chuckle guard poverty release quote oak craft enemy"
    let wallet = try CardanoWallet.fromMnemonic(accountIndex: 0, words: words)
    
    let provider = try MaestroDataProvider(maestroApi: getMockAPI(address: "addr1qx2v83fl7g3vwrsg3zyyn24l33h46rzvcqleq8hul7pyq02d54gqj9vhlafuhzuduhq74ew4jc5xxtrfpuu397nxc4mq2jq8ga"))
    
    wallet.addDataProvider(dataProvider: provider)
    
    let utxos = try await wallet.getUtxos()
    
    print(utxos.length)
    #expect(utxos.length == 0)
    
}



@Test func test_get_private_address() async throws {
    let words = "art forum devote street sure rather head chuckle guard poverty release quote oak craft enemy"
    let wallet = try CardanoWallet.fromMnemonic(accountIndex: 0, words: words)
    
    let privateAddress = try wallet.getPaymentAddress(index: 34775)
    
    print(try privateAddress.asBech32())
    
    
    let start = CFAbsoluteTimeGetCurrent()
    
    let privatePaymentCred = try privateAddress.paymentCredential!.toHex()
    var found = false
    var index = Int64(-1)
    repeat {

        index = index + 1
        
        let pk = try  wallet.getPaymentPrivateKey(index: index).toPublic().credential().toHex()
        
        found = pk == privatePaymentCred
        
    } while !found
    
    let diff = CFAbsoluteTimeGetCurrent() - start
    
    print("Found at index \(index)")
    #expect(index == 34775)
    
    print("Execution time: \(diff) seconds")
}
