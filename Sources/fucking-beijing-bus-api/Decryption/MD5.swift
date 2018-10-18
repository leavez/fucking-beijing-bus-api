//
//  MD5.swift
//  Alamofire
//
//  Created by Gao on 2018/10/18.
//

import Foundation
import CommonCrypto

extension String {
    
    public var MD5: String {
        return String.MD5(self)
    }
    
    private static func MD5(_ string: String) -> String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        
        let bytes = Array(string.utf8)
        CC_MD5(bytes, CC_LONG(bytes.count), &digest)
        
        return (0..<length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
}


extension Data {
    
    func hexString() -> String {
        let string = self.map{ String($0, radix:16) }.joined()
        return string
    }
    
}


