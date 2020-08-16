import XCTest
@testable import fucking_beijing_bus_api



final class fucking_beijing_bus_api_sync_Tests: XCTestCase {
    
    
    func test_getAllLines() {
        do {
            let result = try BeijingBusAPI.Static.getAllLinesSync()
            itWait { (done) in
                BeijingBusAPI.Static.getAllLines(completion: { (infos) in
                    if let value = infos.value {
                        XCTAssertEqual(value, result)
                    } else {
                        XCTFail()
                    }
                    done()
                })
            }
            
        } catch let e {
            XCTFail("\(e)")
        }
    }
}
