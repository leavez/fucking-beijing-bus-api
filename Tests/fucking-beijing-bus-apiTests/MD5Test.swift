//
//  MD5Test.swift
//  fucking-beijing-bus-apiTests
//
//  Created by Gao on 2018/10/18.
//

import XCTest

class MD5Test: XCTestCase {

    func test() {
        XCTAssertEqual("123".md5, "202cb962ac59075b964b07152d234b70")
        XCTAssertEqual("诺贝尔物理学奖是诺贝尔奖的六个奖项之一".md5, "bd8e21735e3a66f5c1283134d61bacd2")
    }

}
