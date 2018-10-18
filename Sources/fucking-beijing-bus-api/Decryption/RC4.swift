//
//  RC4.swift
//  Alamofire
//
//  Created by Gao on 2018/10/18.
//

import Foundation
import CommonCrypto

public struct RC4 {
    
    let keyBytes: [UInt8]
    
    public init(key: [UInt8]) {
        keyBytes = key
    }
    public init(key: String) {
        keyBytes = Array(key.utf8)
    }
    
    
    public func encrypt(content: [UInt8]) -> [UInt8] {
        let data = content
        var output: [UTF8.CodeUnit] = Array(repeating: 0, count: data.count)
        CCCrypt(CCOperation(kCCEncrypt), CCAlgorithm(kCCAlgorithmRC4), 0,
                keyBytes, keyBytes.count,
                nil,
                data, data.count,
                &output, output.count,
                nil)
        return output
    }

    public func encrypt(content: String) -> [UInt8] {
        let data = Array(content.utf8)
        return self.encrypt(content: data)
    }
    
    public static func encrypt(content: String, key:String) -> [UInt8] {
        return RC4(key: key).encrypt(content: content)
    }
}
