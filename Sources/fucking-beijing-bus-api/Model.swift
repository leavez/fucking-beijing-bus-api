//
//  Model.swift
//  Alamofire
//
//  Created by Gao on 2018/10/18.
//

import Foundation
import Mappable



public struct BusStatusForStation {
    
    public let ID: String
    public let busNumber: String? // 大部分为数字。对于运通路线，前面包含"运通"二字
    public let timestamp: Double
    
    public let currentLocation: (longitude: Double, latitude: Double) // converted from currentLocationString
    public let gpsUpdatedTime: Double
    
    public let currentStation: (
        distanceRemain:Int,
        estimatedRunDuration: TimeInterval,
        estimatedArrivedTime: Double
    )
    
    public let nextStation: (
        name:String,
        index:Int,
        distanceRemain:Int,                 // 距离下一站的距离
        estimatedRunDuration: TimeInterval, // 距离下一站还有几秒
        estimatedArrivedTime: Double        // 预计到达下一站的时间
    )
    
    public let delay: String  // 红绿灯延误时间
    public let type: String
    public let rawJSON: [String: Any]
}


public struct BusMeta {
    let ID: String
    let busNumber: String // 大部分为数字。对于运通路线，前面包含"运通"二字
    let departureStationName: String
    let terminalStationName: String
    
    let classify: String // 线路分类，比较粗糙，没有什么实际意义
    let status: String // unknow
    let version: String // unknow
    
    public let rawJSON: [String: Any]
}



extension BusStatusForStation: Mappable {
    
    public init(map: Mapper) throws {
        busNumber = try? map.lid()
        ID = try map.id()
        timestamp = try map.ut()
        
        let de = Decryption(gt: try map.gt())
        let currentLocationString = (
            longitude: de.decode(string: try map.x()) ,
            latitude: de.decode(string: try map.y())
        )
        currentLocation = (
            longitude: Double(currentLocationString.longitude) ?? -1,
            latitude: Double(currentLocationString.latitude) ?? -1
        )
        gpsUpdatedTime = try map.gt()
        
        currentStation = (
            distanceRemain: Int(de.decode(string: try map.sd())) ?? -1,
            estimatedRunDuration: Double(de.decode(string:try map.srt())) ?? -1,
            estimatedArrivedTime: Double(de.decode(string: try map.st())) ?? -1
        )
        
        nextStation = (
            name: de.decode(string: try map.ns()),
            index: Int(de.decode(string: try map.nsn())) ?? -1,
            distanceRemain: try map.nsd(),
            estimatedRunDuration: try map.nsrt(),
            estimatedArrivedTime: try map.nst()
        )
        
        type = try map.t()
        delay = try map.lt()
        rawJSON = map.getRootValue() as? [String: Any] ?? [:]
    }
}


extension BusMeta: Mappable {
    
    public init(map: Mapper) throws {
        ID = try map.id()
        
        let name: String = try map.linename()
        if let match = busNameRegex.firstMatch(in: name, options: [], range: NSMakeRange(0, name.count)), match.numberOfRanges == 4 {
            let groups = (1...3).map { (i: Int) -> String in
                let range = match.range(at: i)
                return (name as NSString).substring(with: range)
            }
            busNumber = groups[0]
            departureStationName = groups[1]
            terminalStationName = groups[2]
        } else {
            busNumber = name
            departureStationName = ""
            terminalStationName = ""
        }
        
        classify = try map.classify()
        version = try map.version()
        status = try map.status()
        rawJSON = map.getRootValue() as? [String: Any] ?? [:]
    }
}
private let busNameRegex = try! NSRegularExpression(pattern: "^(.+)\\((.+)\\-(.+)\\)$", options: [])

