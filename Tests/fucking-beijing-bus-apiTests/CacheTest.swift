//
//  CacheTest.swift
//  fucking-beijing-bus-apiTests
//
//  Created by Gao on 2018/10/20.
//

import XCTest
import fucking_beijing_bus_api

class CacheTest: XCTestCase {
    let testKey = "1"
    let testKey2 = "2222"
    
    override func setUp() {
        super.setUp()
        [testKey, testKey2].forEach {
            UserDefaults.standard.removeObject(forKey: $0)
        }
    }
    
    override func tearDown() {
        [testKey, testKey2].forEach {
            UserDefaults.standard.removeObject(forKey: $0)
        }
        super.tearDown()
    }


    func test_set_get_cache() {
        let value = ["123"]
        let value2 = ["a":3]
        BeijingBusAPI.Static.Cache.cache(value, for: testKey)
        BeijingBusAPI.Static.Cache.cache(value2, for: testKey2)
        XCTAssertEqual(BeijingBusAPI.Static.Cache.cachedObject(for: testKey), value)
        XCTAssertEqual(BeijingBusAPI.Static.Cache.cachedObject(for: testKey2), value2)
        BeijingBusAPI.Static.Cache.cache(nil as String?, for: testKey)
        XCTAssertEqual(BeijingBusAPI.Static.Cache.cachedObject(for: testKey), nil as String?)
    }

    func test_getAllLinesSmartly() {
        // remove from cached
        let key = BeijingBusAPI.Static.Cache.Key.allLines
        BeijingBusAPI.Static.Cache.cache(nil as String?, for: key)
        
        // get from network
        var result: [LineMeta]? = nil
        itWait { (done) in
            BeijingBusAPI.Static.Cache.getAllLinesSmartly { (r) in
                result = r.value
                done()
            }
        }
        
        // get from cache
        var result2: [LineMeta]? = nil
        BeijingBusAPI.Static.Cache.getAllLinesSmartly { (r) in
            result2 = r.value
        }
        // no wait
        XCTAssertEqual(result, result2)
    }
    
    
    func test_getLineDetailSmartly() {
        // remove from cached
        let key = BeijingBusAPI.Static.Cache.Key.allLines
        BeijingBusAPI.Static.Cache.cache(nil as String?, for: key)
        
        // get from network
        let ID = "404"
        var result: LineDetail?? = nil
        itWait { (done) in
            BeijingBusAPI.Static.Cache.getLineDetailSmartly(ofLine: ID) { (r) in
                result = r.value
                done()
            }
        }
        
        // get from cache
        var result2: LineDetail?? = nil
        BeijingBusAPI.Static.Cache.getLineDetailSmartly(ofLine: ID)  { (r) in
            result2 = r.value
        }
        // no wait
        XCTAssertEqual(result, result2)
    }

}
