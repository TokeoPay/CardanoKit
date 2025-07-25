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



@Test func go_from_words_to_entropy_and_back() async throws {
    let dict: Any = ["test", 1231, "next", "other"]
    
    
    
}

@Test func test_create_new_wallet_words() async throws {
    var wallet = try CardanoWallet.generate(accountIndex: 0, wordCount: .PISS_WEAK)
    var words = wallet.getMnumonic()
    
    #expect(words.count == 12)
    
    wallet = try CardanoWallet.generate(accountIndex: 0, wordCount: .LITTLE_BETTER)
    words = wallet.getMnumonic()
    
    #expect(words.count == 15)
    
    wallet = try CardanoWallet.generate(accountIndex: 0, wordCount: .NEARLY_THERE)
    words = wallet.getMnumonic()
    
    #expect(words.count == 18)
    
    wallet = try CardanoWallet.generate(accountIndex: 0, wordCount: .SHOULD_BE_GOOD)
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
    
    print(" >> Signed Result: ", signature)
}
