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
    
    
    func test_getAllLines() {
        itWait { (done) in
            BeijingBusAPI.Static.getAllLines(completion: { (infos) in
                if let value = infos.value {
                    XCTAssert(value.count > 2000)
                    let aLine = value[100]
                    XCTAssert(aLine.ID.count > 0)
                    XCTAssert(aLine.busNumber.count > 0)
                    XCTAssert(aLine.departureStationName.count > 0)
                    XCTAssert(aLine.terminalStationName.count > 0)
                } else {
                    XCTFail()
                }
                done()
            })
        }
    }
    
    func test_getLineInfoForStation() {
        itWait { (done) in
            BeijingBusAPI.RealTime.getLineStatusForStation(
                [
                    (lineID: "160", stationName: "东内小街", indexInBusLine: 21),
                    (lineID: "404", stationName: "学知园", indexInBusLine: 24),  // 478
                    (lineID: "404", stationName: "北京航空航天大学", indexInBusLine: 28), // 478
                    (lineID: "1827", stationName: "学知桥北", indexInBusLine: 37)
                ], completion: { infos in
                    if let value = infos.value {
                        if value.count > 0 {
                            let info = value[0]
                            XCTAssert(info.ID.count > 0)
                            XCTAssert(info.gpsUpdatedTime != -1)
                            XCTAssert(info.currentLocation != Coordinate(longitude: -1, latitude: -1))
                            XCTAssert(info.comingStation.name.count > 0)
                            XCTAssert(info.distanceRemain != -1)
                        } else {
                            print("现在是夜晚，没有车运行的，会返回空。否则有问题")
                        }
                    } else {
                        XCTFail()
                    }
                    done()
            })
        }
    }
    
    func test_getAllBusInfo() {
        itWait { (done) in
            // 478 线路相对于"北京航空航天大学"
            BeijingBusAPI.RealTime.getAllBusesStatus(ofLine: "404", referenceStation: 28, completion: { (infos) in
                if let value = infos.value {
                    if value.count > 0 {
                        let info = value[0]
                        XCTAssert(info.ID.count > 0)
                        XCTAssert(info.gpsUpdatedTime != -1)
                        XCTAssert(info.currentLocation != Coordinate(longitude: -1, latitude: -1))
                        XCTAssert(info.comingStation.name.count > 0)
                        XCTAssert(info.distanceRemain != -1)
                    } else {
                        print("现在是夜晚，没有车运行的，会返回空。否则有问题")
                    }
                } else {
                    XCTFail()
                }
                done()
            })
        }
    }

    func test_getLineDetail() {
        itWait { (done) in
            BeijingBusAPI.Static.getLineDetail(ofLine: "404", completion: { (result) in
                if let v = result.value as? LineDetail {
                    XCTAssert(v.ID.count > 0)
                    XCTAssert(v.busNumber.count > 0)
                    XCTAssert(v.departureStationName.count > 0)
                    XCTAssert(v.terminalStationName.count > 0)
                    XCTAssert(v.coords.count > 0)
                    XCTAssert(v.stations.count > 0)
                    let station = v.stations[0]
                    XCTAssert(station.index > 0)
                    XCTAssert(station.name.count > 0)
                    XCTAssert(station.location != Coordinate(longitude: -1, latitude: -1))
                } else {
                    XCTFail()
                }
                done()
            })
        }
    }
}
