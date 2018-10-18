//
//  RC4Test.swift
//  fucking-beijing-bus-apiTests
//
//  Created by Gao on 2018/10/17.
//

import XCTest
@testable import fucking_beijing_bus_api


class RC4Test: XCTestCase {

    func test() {
        let rc4 = RC4(key:"123")
        let data = rc4.encrypt(content: "hello world")
        XCTAssertEqual(data, [59, 149, 211, 238, 138, 84, 115, 148, 87, 15, 103])
        let revertedData = rc4.encrypt(content: data)
        XCTAssertEqual(String(bytes: revertedData, encoding: .utf8) , "hello world")
    }


    func testPerformanceExample() {
        self.measure {
            let rc4 = RC4(key:"123")
            _ = rc4.encrypt(content: "hello world")
        }
    }

}



