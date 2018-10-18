//
//  Decryption.swift
//  fucking-beijing-bus-api
//
//  Created by Gao on 2018/10/16.
//

import Foundation
import CommonCrypto

class Decryption {
    
    let rc4: RC4
    
    init(gt:String) {
        let key = ("aibang" + gt).MD5
        rc4 = RC4(key: key)
    }
    
    func decode(string: String) -> String? {
        guard let data = Data(base64Encoded: string) else {
            return nil
        }
        let inputBytes: [UInt8] = Array(data)
        let bytes = rc4.encrypt(content: inputBytes)
        return String(bytes: bytes, encoding: .utf8)
    }
}

