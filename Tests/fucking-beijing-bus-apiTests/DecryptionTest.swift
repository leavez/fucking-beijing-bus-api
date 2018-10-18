//
//  DecryptionTest.swift
//  fucking-beijing-bus-apiTests
//
//  Created by Gao on 2018/10/18.
//

import XCTest
@testable import fucking_beijing_bus_api

class DecryptionTest: XCTestCase {

    func test() {
        let de = Decryption(gt:"1539706330")
        let decoded = de.decode(string: "xcOMSmgGf9X7FWh3vLZ8")
        print(decoded)
        XCTAssertEqual(decoded, "东单路口北")
    }

}
