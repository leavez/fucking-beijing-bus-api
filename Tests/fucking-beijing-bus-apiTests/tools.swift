//
//  File.swift
//  
//
//  Created by leave on 2020/8/16.
//

import Foundation

extension Result {
    var value: Success? {
        switch self {
        case .success(let s):
            return s
        default:
            return nil
        }
    }
}
