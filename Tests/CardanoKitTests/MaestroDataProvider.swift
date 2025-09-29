//
//  MaestroDataProvider.swift
//  CardanoKit
//
//  Created by Gavin Harris on 29/9/2025.
//

import Testing
import Bip39
import Foundation
@testable import CardanoKit



@Test func test_getUtxos_from_maestro() async throws {
    guard let apiKey = ProcessInfo.processInfo.environment["MAESTRO_API_KEY"] else {
        Issue.record("""
API_KEY not set — skipping integration test. Run this set from the Command line with:

```
> MAESTRO_API_KEY=maestro_api_key swift test --filter test_getUtxos_from_maestro
```
 
""")
        return
    }
    
    let words = "art forum devote street sure rather head chuckle guard poverty release quote oak craft enemy"
    let wallet = try CardanoWallet.fromMnemonic(accountIndex: 0, words: words)
    
    let provider = MaestroDataProvider(network: .mainnet, apiKeyProvider: { apiKey })
    
    wallet.addDataProvider(dataProvider: provider)
    
    let utxos = try await wallet.getUtxos()
    
    print(utxos.length)
    #expect(utxos.length == 0)
    
}
