//
//  TextTxDataProvider.swift
//  CardanoKit
//
//  Created by Gavin Harris on 17/9/2025.
//


import Testing
import XCTest
@testable import CardanoKit



public func getMockAPI(address: String) throws -> MockMaestroAPI {
    
    let utxoJson = """
            {"data":[{"tx_hash":"6bfbce281a3292ccd56fe37c1caf5c6f6ffd3be3b904297ecaf5bfa32532f116","index":2,"slot":160538338,"assets":[{"unit":"lovelace","amount":31543543},{"unit":"53c07e65e63a4b49ce3810cea982370d115f3b699018a9378838574a446f6e6174696f6e202331333038","amount":1},{"unit":"77999d5a1e09f9bdc16393cab713f26345dc0827a9e5134cf0f9da374d756c67614b6f6e67353834","amount":1},{"unit":"83cb87b69639e20d7c99755fcfc310fb47882c3591778a3c869ea34c417473756b6f34383138","amount":1},{"unit":"a7bf4ce10dca4f5f99b081c4ea84e0e3f919775b953324e09edea852536865446576696c7331333636","amount":1},{"unit":"a7bf4ce10dca4f5f99b081c4ea84e0e3f919775b953324e09edea852536865446576696c7332383437","amount":1},{"unit":"ab434d53b6bb2352714a8940d2a12db8e083c9bb7cd4dbff7080118f546f6b656f343735","amount":1},{"unit":"ba92e5f4665a026f7d5f2f223d398d2d8b649e147b5163b759bd61a054696765727a32383738","amount":1},{"unit":"bd369dc746e4a872a55fb9f0472d5fe30f3ba3fe0b72f280fe2455a5456c797369756d546974616e303031393438","amount":1},{"unit":"c72d0438330ed1346f4437fcc1c263ea38e933c1124c8d0f2abc63124b57494338383435","amount":1},{"unit":"fc11a9ef431f81b837736be5f53e4da29b9469c983d07f321262ce614652454e","amount":320000}],"address":"\(address)", "datum":null,"reference_script":null,"txout_cbor":"82583901b43b148f9c0ed673ee20019cb3623d5d2bed7e2da001ea3096e2d9bf9c4bcdd7ff3cb4e66593f9274583b066fafdb22453774411602f901b821a01e150f7a9581c53c07e65e63a4b49ce3810cea982370d115f3b699018a9378838574aa14e446f6e6174696f6e20233133303801581c77999d5a1e09f9bdc16393cab713f26345dc0827a9e5134cf0f9da37a14c4d756c67614b6f6e6735383401581c83cb87b69639e20d7c99755fcfc310fb47882c3591778a3c869ea34ca14a417473756b6f3438313801581ca7bf4ce10dca4f5f99b081c4ea84e0e3f919775b953324e09edea852a24d536865446576696c7331333636014d536865446576696c733238343701581cab434d53b6bb2352714a8940d2a12db8e083c9bb7cd4dbff7080118fa148546f6b656f34373501581cba92e5f4665a026f7d5f2f223d398d2d8b649e147b5163b759bd61a0a14a54696765727a3238373801581cbd369dc746e4a872a55fb9f0472d5fe30f3ba3fe0b72f280fe2455a5a152456c797369756d546974616e30303139343801581cc72d0438330ed1346f4437fcc1c263ea38e933c1124c8d0f2abc6312a1484b5749433838343501581cfc11a9ef431f81b837736be5f53e4da29b9469c983d07f321262ce61a1444652454e1a0004e200"},{"tx_hash":"e9cb99bec2c14f0c1c278cc3a184ece59549d2ec97a5099a3259a3e8ddb853a1","index":1,"slot":164101752,"assets":[{"unit":"lovelace","amount":1159390},{"unit":"bea9c296e7de1ad91f85f52350a904c2940770598004e4d62a07a57853544f4b45","amount":154700}],"address":"addr1qx6rk9y0ns8dvulwyqqeevmz84wjhmt79ksqr63sjm3dn0uuf0xa0leuknnxtyleyazc8vrxlt7myfznwazpzcp0jqdsxr05lj","datum":null,"reference_script":null,"txout_cbor":"82583901b43b148f9c0ed673ee20019cb3623d5d2bed7e2da001ea3096e2d9bf9c4bcdd7ff3cb4e66593f9274583b066fafdb22453774411602f901b821a0011b0dea1581cbea9c296e7de1ad91f85f52350a904c2940770598004e4d62a07a578a14553544f4b451a00025c4c"},{"tx_hash":"969a55094f47cf78c467e18856e63c40b793604453ff4806e8c44f341900d083","index":0,"slot":165126552,"assets":[{"unit":"lovelace","amount":119827081}],"address":"\(address)", "datum":null,"reference_script":null,"txout_cbor":"82583901b43b148f9c0ed673ee20019cb3623d5d2bed7e2da001ea3096e2d9bf9c4bcdd7ff3cb4e66593f9274583b066fafdb22453774411602f901b1a07246a89"},{"tx_hash":"969a55094f47cf78c467e18856e63c40b793604453ff4806e8c44f341900d083","index":1,"slot":165126552,"assets":[{"unit":"lovelace","amount":5142150},{"unit":"8f14c6ac45dd64212f767b37e030e322de401c699113c9abd49a162e41434c4159","amount":1}],"address":"\(address)","datum":null,"reference_script":null,"txout_cbor":"82583901b43b148f9c0ed673ee20019cb3623d5d2bed7e2da001ea3096e2d9bf9c4bcdd7ff3cb4e66593f9274583b066fafdb22453774411602f901b821a004e7686a1581c8f14c6ac45dd64212f767b37e030e322de401c699113c9abd49a162ea14541434c415901"}],"last_updated":{"timestamp":"2025-09-17 22:42:28","block_hash":"c691ee785c23130961996384fa23b27f02101bacf88c20a7405acefd7c77d6f5","block_slot":166582657},"next_cursor":null}
            """
    
    let addressUtxos = try JSONDecoder().decode(MaestroResponse<MaestroUTxO>.self, from: Data(utxoJson.utf8))
    
    let mockAPI = MockMaestroAPI()
    mockAPI.requestPostHandler = { path, body in
        
        switch path {
        case "/v1/txmanager":
            return try FixedTransaction(hex: body as! String).hash()
        case "/v1/addresses/utxos?with_cbor=true":
            
            let utxos =  addressUtxos.data.filter { (body as! [String]).contains($0.address) }
            
            return MaestroResponse(data: utxos, lastUpdated: addressUtxos.lastUpdated, nextCursor: addressUtxos.nextCursor)
            
        case "/v1/transactions/outputs?with_cbor=true":
            
            // Expect the body to be a String array
            guard let body = body as? [String] else {
                throw MaestroError.api("Bad body")
            }
            
            let data = addressUtxos.data.filter { utxo in
                body.contains("\(utxo.txHash)#\(utxo.index)")
            }
            
            return MaestroResponse(data: data, lastUpdated: addressUtxos.lastUpdated, nextCursor: addressUtxos.nextCursor)
            
        default:
            throw MaestroError.api("No mock provided path=\(path)")
        }
        
        
    }
    
    mockAPI.requestHandler = { path in
        switch path {
        case "/v1/protocol-parameters":
            let json = """
            {"data":{"min_fee_coefficient":44,"min_fee_constant":{"ada":{"lovelace":155381}},"min_fee_reference_scripts":{"base":15.0,"range":25600,"multiplier":1.2},"max_block_body_size":{"bytes":90112},"max_block_header_size":{"bytes":1100},"max_transaction_size":{"bytes":16384},"max_reference_scripts_size":{"bytes":204800},"stake_credential_deposit":{"ada":{"lovelace":2000000}},"stake_pool_deposit":{"ada":{"lovelace":500000000}},"stake_pool_retirement_epoch_bound":18,"desired_number_of_stake_pools":500,"stake_pool_pledge_influence":"3/10","monetary_expansion":"3/1000","treasury_expansion":"1/5","min_stake_pool_cost":{"ada":{"lovelace":170000000}},"min_utxo_deposit_constant":{"ada":{"lovelace":0}},"min_utxo_deposit_coefficient":4310,"plutus_cost_models":{"plutus_v1":[100788,420,1,1,1000,173,0,1,1000,59957,4,1,11183,32,201305,8356,4,16000,100,16000,100,16000,100,16000,100,16000,100,16000,100,100,100,16000,100,94375,32,132994,32,61462,4,72010,178,0,1,22151,32,91189,769,4,2,85848,228465,122,0,1,1,1000,42921,4,2,24548,29498,38,1,898148,27279,1,51775,558,1,39184,1000,60594,1,141895,32,83150,32,15299,32,76049,1,13169,4,22100,10,28999,74,1,28999,74,1,43285,552,1,44749,541,1,33852,32,68246,32,72362,32,7243,32,7391,32,11546,32,85848,228465,122,0,1,1,90434,519,0,1,74433,32,85848,228465,122,0,1,1,85848,228465,122,0,1,1,270652,22588,4,1457325,64566,4,20467,1,4,0,141992,32,100788,420,1,1,81663,32,59498,32,20142,32,24588,32,20744,32,25933,32,24623,32,53384111,14333,10],"plutus_v2":[100788,420,1,1,1000,173,0,1,1000,59957,4,1,11183,32,201305,8356,4,16000,100,16000,100,16000,100,16000,100,16000,100,16000,100,100,100,16000,100,94375,32,132994,32,61462,4,72010,178,0,1,22151,32,91189,769,4,2,85848,228465,122,0,1,1,1000,42921,4,2,24548,29498,38,1,898148,27279,1,51775,558,1,39184,1000,60594,1,141895,32,83150,32,15299,32,76049,1,13169,4,22100,10,28999,74,1,28999,74,1,43285,552,1,44749,541,1,33852,32,68246,32,72362,32,7243,32,7391,32,11546,32,85848,228465,122,0,1,1,90434,519,0,1,74433,32,85848,228465,122,0,1,1,85848,228465,122,0,1,1,955506,213312,0,2,270652,22588,4,1457325,64566,4,20467,1,4,0,141992,32,100788,420,1,1,81663,32,59498,32,20142,32,24588,32,20744,32,25933,32,24623,32,43053543,10,53384111,14333,10,43574283,26308,10],"plutus_v3":[100788,420,1,1,1000,173,0,1,1000,59957,4,1,11183,32,201305,8356,4,16000,100,16000,100,16000,100,16000,100,16000,100,16000,100,100,100,16000,100,94375,32,132994,32,61462,4,72010,178,0,1,22151,32,91189,769,4,2,85848,123203,7305,-900,1716,549,57,85848,0,1,1,1000,42921,4,2,24548,29498,38,1,898148,27279,1,51775,558,1,39184,1000,60594,1,141895,32,83150,32,15299,32,76049,1,13169,4,22100,10,28999,74,1,28999,74,1,43285,552,1,44749,541,1,33852,32,68246,32,72362,32,7243,32,7391,32,11546,32,85848,123203,7305,-900,1716,549,57,85848,0,1,90434,519,0,1,74433,32,85848,123203,7305,-900,1716,549,57,85848,0,1,1,85848,123203,7305,-900,1716,549,57,85848,0,1,955506,213312,0,2,270652,22588,4,1457325,64566,4,20467,1,4,0,141992,32,100788,420,1,1,81663,32,59498,32,20142,32,24588,32,20744,32,25933,32,24623,32,43053543,10,53384111,14333,10,43574283,26308,10,16000,100,16000,100,962335,18,2780678,6,442008,1,52538055,3756,18,267929,18,76433006,8868,18,52948122,18,1995836,36,3227919,12,901022,1,166917843,4307,36,284546,36,158221314,26549,36,74698472,36,333849714,1,254006273,72,2174038,72,2261318,64571,4,207616,8310,4,1293828,28716,63,0,1,1006041,43623,251,0,1,100181,726,719,0,1,100181,726,719,0,1,100181,726,719,0,1,107878,680,0,1,95336,1,281145,18848,0,1,180194,159,1,1,158519,8942,0,1,159378,8813,0,1,107490,3298,1,106057,655,1,1964219,24520,3]},"script_execution_prices":{"memory":"577/10000","cpu":"721/10000000"},"max_execution_units_per_transaction":{"memory":14000000,"cpu":10000000000},"max_execution_units_per_block":{"memory":62000000,"cpu":20000000000},"max_value_size":{"bytes":5000},"collateral_percentage":150,"max_collateral_inputs":3,"version":{"major":10,"minor":0},"stake_pool_voting_thresholds":{"no_confidence":"51/100","constitutional_committee":{"default":"51/100","state_of_no_confidence":"51/100"},"hard_fork_initiation":"51/100","protocol_parameters_update":{"security":"51/100"}},"delegate_representative_voting_thresholds":{"no_confidence":"67/100","constitutional_committee":{"default":"67/100","state_of_no_confidence":"3/5"},"constitution":"3/4","hard_fork_initiation":"3/5","protocol_parameters_update":{"network":"67/100","economic":"67/100","technical":"67/100","governance":"3/4"},"treasury_withdrawals":"67/100"},"constitutional_committee_min_size":7,"constitutional_committee_max_term_length":146,"governance_action_lifetime":6,"governance_action_deposit":{"ada":{"lovelace":100000000000}},"delegate_representative_deposit":{"ada":{"lovelace":500000000}},"delegate_representative_max_idle_time":20},"last_updated":{"timestamp":"2025-09-17 05:25:45","block_hash":"3628e02350989a5848808b07b0ac59263aab83c8e7e5db2409dd46b12a74d2d3","block_slot":166520454}}
            """
            
            return try JSONDecoder().decode(MaestroResponseSingle<MaestroProtocolParameters>.self, from: Data(json.utf8))
            
            
        default:
            throw MaestroError.api("No mock provided")
        }
    }
    
    return mockAPI
}


public class MockMaestroAPI: MaestroAPIProtocol {
    
    public var requestHandler: ((String) throws -> Any)?
    public var requestPostHandler: ((String, Any) throws -> Any)?
    
    
    public func request<T, E>(path: String, responseType: T.Type, errorType: E.Type) async throws -> T where T : Decodable, T : Sendable, E : Decodable, E : Sendable {
        guard let result = try requestHandler?(path) as? T else {
            throw MaestroError.api("No mock provided")
        }
        return result
    }
    
    public func requestPost<T, E, B>(path: String, body: B, responseType: T.Type, errorType: E.Type) async throws -> T where T : Decodable, T : Sendable, E : Decodable, E : Sendable, B : Encodable, B : Sendable {
        guard let result = try requestPostHandler?(
            path,
            body
        ) as? T else {
            throw MaestroError.api("No mock provided")
        }
        return result
    }
    
}






struct TextTxDataProvider: TransactionDataProvider {
    func coinsPerUtxoByte() async throws -> Int {
        return 1000000
    }
    
    public func submit(transaction: FixedTransaction) async throws -> String {
        return try transaction.hash()
    }
    
    func getStakeAccountAddresses(stake_account_address: String) async throws -> [Address] {
        let addresses = MaestroResponseSingle<Array<String>>(data: [
            "addr1aa"
        ], lastUpdated: BlockUpdate(timestamp: "", blockHash: "", blockSlot: 1), nextCursor: "")
        
        return try addresses.data.map { address in
            try Address(bech32: address)
        }
    }
    
    func getTransactionBuilderConfig() async throws -> CardanoKit.TransactionBuilderConfig {
        let json = """
            {"data":{"min_fee_coefficient":44,"min_fee_constant":{"ada":{"lovelace":155381}},"min_fee_reference_scripts":{"base":15.0,"range":25600,"multiplier":1.2},"max_block_body_size":{"bytes":90112},"max_block_header_size":{"bytes":1100},"max_transaction_size":{"bytes":16384},"max_reference_scripts_size":{"bytes":204800},"stake_credential_deposit":{"ada":{"lovelace":2000000}},"stake_pool_deposit":{"ada":{"lovelace":500000000}},"stake_pool_retirement_epoch_bound":18,"desired_number_of_stake_pools":500,"stake_pool_pledge_influence":"3/10","monetary_expansion":"3/1000","treasury_expansion":"1/5","min_stake_pool_cost":{"ada":{"lovelace":170000000}},"min_utxo_deposit_constant":{"ada":{"lovelace":0}},"min_utxo_deposit_coefficient":4310,"plutus_cost_models":{"plutus_v1":[100788,420,1,1,1000,173,0,1,1000,59957,4,1,11183,32,201305,8356,4,16000,100,16000,100,16000,100,16000,100,16000,100,16000,100,100,100,16000,100,94375,32,132994,32,61462,4,72010,178,0,1,22151,32,91189,769,4,2,85848,228465,122,0,1,1,1000,42921,4,2,24548,29498,38,1,898148,27279,1,51775,558,1,39184,1000,60594,1,141895,32,83150,32,15299,32,76049,1,13169,4,22100,10,28999,74,1,28999,74,1,43285,552,1,44749,541,1,33852,32,68246,32,72362,32,7243,32,7391,32,11546,32,85848,228465,122,0,1,1,90434,519,0,1,74433,32,85848,228465,122,0,1,1,85848,228465,122,0,1,1,270652,22588,4,1457325,64566,4,20467,1,4,0,141992,32,100788,420,1,1,81663,32,59498,32,20142,32,24588,32,20744,32,25933,32,24623,32,53384111,14333,10],"plutus_v2":[100788,420,1,1,1000,173,0,1,1000,59957,4,1,11183,32,201305,8356,4,16000,100,16000,100,16000,100,16000,100,16000,100,16000,100,100,100,16000,100,94375,32,132994,32,61462,4,72010,178,0,1,22151,32,91189,769,4,2,85848,228465,122,0,1,1,1000,42921,4,2,24548,29498,38,1,898148,27279,1,51775,558,1,39184,1000,60594,1,141895,32,83150,32,15299,32,76049,1,13169,4,22100,10,28999,74,1,28999,74,1,43285,552,1,44749,541,1,33852,32,68246,32,72362,32,7243,32,7391,32,11546,32,85848,228465,122,0,1,1,90434,519,0,1,74433,32,85848,228465,122,0,1,1,85848,228465,122,0,1,1,955506,213312,0,2,270652,22588,4,1457325,64566,4,20467,1,4,0,141992,32,100788,420,1,1,81663,32,59498,32,20142,32,24588,32,20744,32,25933,32,24623,32,43053543,10,53384111,14333,10,43574283,26308,10],"plutus_v3":[100788,420,1,1,1000,173,0,1,1000,59957,4,1,11183,32,201305,8356,4,16000,100,16000,100,16000,100,16000,100,16000,100,16000,100,100,100,16000,100,94375,32,132994,32,61462,4,72010,178,0,1,22151,32,91189,769,4,2,85848,123203,7305,-900,1716,549,57,85848,0,1,1,1000,42921,4,2,24548,29498,38,1,898148,27279,1,51775,558,1,39184,1000,60594,1,141895,32,83150,32,15299,32,76049,1,13169,4,22100,10,28999,74,1,28999,74,1,43285,552,1,44749,541,1,33852,32,68246,32,72362,32,7243,32,7391,32,11546,32,85848,123203,7305,-900,1716,549,57,85848,0,1,90434,519,0,1,74433,32,85848,123203,7305,-900,1716,549,57,85848,0,1,1,85848,123203,7305,-900,1716,549,57,85848,0,1,955506,213312,0,2,270652,22588,4,1457325,64566,4,20467,1,4,0,141992,32,100788,420,1,1,81663,32,59498,32,20142,32,24588,32,20744,32,25933,32,24623,32,43053543,10,53384111,14333,10,43574283,26308,10,16000,100,16000,100,962335,18,2780678,6,442008,1,52538055,3756,18,267929,18,76433006,8868,18,52948122,18,1995836,36,3227919,12,901022,1,166917843,4307,36,284546,36,158221314,26549,36,74698472,36,333849714,1,254006273,72,2174038,72,2261318,64571,4,207616,8310,4,1293828,28716,63,0,1,1006041,43623,251,0,1,100181,726,719,0,1,100181,726,719,0,1,100181,726,719,0,1,107878,680,0,1,95336,1,281145,18848,0,1,180194,159,1,1,158519,8942,0,1,159378,8813,0,1,107490,3298,1,106057,655,1,1964219,24520,3]},"script_execution_prices":{"memory":"577/10000","cpu":"721/10000000"},"max_execution_units_per_transaction":{"memory":14000000,"cpu":10000000000},"max_execution_units_per_block":{"memory":62000000,"cpu":20000000000},"max_value_size":{"bytes":5000},"collateral_percentage":150,"max_collateral_inputs":3,"version":{"major":10,"minor":0},"stake_pool_voting_thresholds":{"no_confidence":"51/100","constitutional_committee":{"default":"51/100","state_of_no_confidence":"51/100"},"hard_fork_initiation":"51/100","protocol_parameters_update":{"security":"51/100"}},"delegate_representative_voting_thresholds":{"no_confidence":"67/100","constitutional_committee":{"default":"67/100","state_of_no_confidence":"3/5"},"constitution":"3/4","hard_fork_initiation":"3/5","protocol_parameters_update":{"network":"67/100","economic":"67/100","technical":"67/100","governance":"3/4"},"treasury_withdrawals":"67/100"},"constitutional_committee_min_size":7,"constitutional_committee_max_term_length":146,"governance_action_lifetime":6,"governance_action_deposit":{"ada":{"lovelace":100000000000}},"delegate_representative_deposit":{"ada":{"lovelace":500000000}},"delegate_representative_max_idle_time":20},"last_updated":{"timestamp":"2025-09-17 05:25:45","block_hash":"3628e02350989a5848808b07b0ac59263aab83c8e7e5db2409dd46b12a74d2d3","block_slot":166520454}}
            """
        
        let ppResult = try JSONDecoder().decode(MaestroResponseSingle<MaestroProtocolParameters>.self, from: Data(json.utf8))
        let pp = ppResult.data
        
        // Build the config
        let txBC = try TransactionBuilderConfigBuilder()
        try txBC.setFeeAlgo(
            coefficient: "\(pp.minFeeCoefficient)",
            constant: "\(pp.minFeeConstant.ada.lovelace)"
        )
        try txBC.setPoolDeposit(poolDeposit: "\(pp.stakePoolDeposit.ada.lovelace)")
        try txBC.setKeyDeposit(keyDeposit: "\(pp.stakeCredentialDeposit.ada.lovelace)")
        try txBC.setCoinsPerUtxoByte(
            coinsPerUtxoByte: "\(pp.minUtxoDepositCoefficient)"
        )
        try txBC.setMaxTxSize(maxTxSize: Int64(pp.maxTransactionSize.bytes))
        try txBC.setMaxValueSize(maxValueSize: Int64(pp.maxValueSize.bytes))
        
        try txBC.setExUnitPrices(
            mem: pp.scriptExecutionPrices.memory,
            step: pp.scriptExecutionPrices.cpu
        )
        
        let builtConfig = try txBC.build()
        
        return builtConfig
    }
    
    func getUtxosForMultipleAddresses(addresses: [String]) async throws -> CardanoKit.TransactionUnspentOutputs {
        let utxos = try TransactionUnspentOutputs()
        
        return utxos
    }
    
    func getUtxos(for transactionInputs: CardanoKit.TransactionInputs) async throws -> CardanoKit.TransactionUnspentOutputs {
        let utxos = try TransactionUnspentOutputs()
        
        try transactionInputs.forEach { input in
            
            print(">>> UTXO \(input.txHash!.utf8)#\(input.index!)")
            let txo = try TransactionOutput(hex: "82583901829f189e40ce8ee7bfeb44cba97435fa07f16471dcfdb54dfb71e3208df11bbb405a7d1cab4f3041c9ba6efce2edff9b027b6ca4c73e97d3821a004c4b40a1581c2341201e2508eaebd9acaecbaa7630350cee6ebf437c52cc42bab23ea350477265656479476f626c696e733536340151477265656479476f626c696e73313336350151477265656479476f626c696e733333333701")
            print("TXO Lovelace: \(txo.amount!.lovelace!)")
            try utxos.addUtxo(utxo: TransactionUnspentOutput(input: input, output: txo))
        }
        
        return utxos
    }
}
