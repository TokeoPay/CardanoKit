import Testing
import XCTest
@testable import CardanoKit

@Test func example() async throws {
    
    let address = try Address(bech32: "addr1qydqycuh5r253yp70572k2u80yy7hajyy5r9vd6nl9kcxndftu32t8ma5rrlus948vc8wcm0wj5nq6yz5p532lth67xq4hd8ee")
    
    let hex = try address.asHex()
    
    print("Address in Hex: \(hex)")
    
    XCTAssertEqual("011a026397a0d548903e7d3cab2b877909ebf6442506563753f96d834da95f22a59f7da0c7fe40b53b3077636f74a9306882a069157d77d78c", hex)
    XCTAssertEqual("addr1qydqycuh5r253yp70572k2u80yy7hajyy5r9vd6nl9kcxndftu32t8ma5rrlus948vc8wcm0wj5nq6yz5p532lth67xq4hd8ee", try address.asBech32())

}
