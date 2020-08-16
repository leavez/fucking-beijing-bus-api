//
//  File.swift
//  
//
//  Created by leave on 2020/8/16.
//

import Foundation

func toSync<ReturnType>(_ f: @escaping (@escaping (ReturnType)->Void)->Void) -> ReturnType {
    return toSyncInner { (callback) in
        f(callback)
    }
}

func toSync<A, ReturnType>(_ a:A, _ f: @escaping (A,  @escaping (ReturnType)->Void)->Void) -> ReturnType {
    return toSyncInner { (callback) in
        f(a, callback)
    }
}

func toSync<A,B, ReturnType>(_ a:A, _ b:B, _ f: @escaping (A, B,  @escaping (ReturnType)->Void)->Void) -> ReturnType {
    return toSyncInner { (callback) in
        f(a,b, callback)
    }
}

func toSync<A,B,C, ReturnType>(_ a:A, _ b:B, _ c:C, _ f: @escaping (A, B, C,  @escaping (ReturnType)->Void)->Void) -> ReturnType {
    return toSyncInner { (callback) in
        f(a,b,c, callback)
    }
}

private func toSyncInner<ReturnType>(f: @escaping (@escaping (ReturnType)->Void)->Void) -> ReturnType {
    let s = DispatchSemaphore(value: 0)
    var result: ReturnType?
    f({ r in
        result = r
        s.signal()
    })
    s.wait()
    return result!
}


func unwrapResult<T, E>(_ r: Result<T, E>) throws -> T {
    switch r {
    case .success(let t):
        return t
    case .failure(let e):
        throw e
    }
}
