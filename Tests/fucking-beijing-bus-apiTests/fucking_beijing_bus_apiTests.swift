import XCTest
@testable import fucking_beijing_bus_api

func itWait(description: String = "",
          timeout:TimeInterval = 10,
          action:( _ done:@escaping ()->Void ) -> Void) {
    let expection = XCTestExpectation(description: description)
    let done = {
        expection.fulfill()
    }
    action(done)
    XCTWaiter().wait(for: [expection], timeout: timeout)
}


final class fucking_beijing_bus_apiTests: XCTestCase {
    
    func test_base_API_request() {

        itWait { done in
            BeijingBusAPI().requestAPI(path: "ssgj/bus2.php", completion: { response in
                XCTAssertNotNil(response.data ?? response.error)
                done()
            })
        }
        
    }
    
    func test_getLineInfoForStation() {
        itWait { (done) in
            BeijingBusAPI().getLineInfoForStation(
                [
                    (lineID: "160", stationName: "东内小街", indexInBusLine: 21),
                    (lineID: "404", stationName: "学知园", indexInBusLine: 24),  // 478
                    (lineID: "404", stationName: "北京航空航天大学", indexInBusLine: 28), // 478
                    (lineID: "1827", stationName: "学知桥北", indexInBusLine: 37)
                ], completion: { infos in
                    print(infos)
                    done()
            })
        }
    }
    
    func test_getAllBusInfo() {
        itWait { (done) in
            // 478 线路相对于"北京航空航天大学"
            BeijingBusAPI().getAllBusInfo(ofLine: "404", referenceStation: 28, completion: { (infos) in
                print(infos)
                done()
            })
        }
    }

}
