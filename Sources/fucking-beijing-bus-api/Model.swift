//
//  Model.swift
//  Alamofire
//
//  Created by Gao on 2018/10/18.
//

import Foundation
import Mappable



public struct BusInfoAtStation: Mappable {
    
    public let ID: String
    public let displayNumber: Int?
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
        estimatedArrivedTime: Double  // 预计到达下一站的时间
    )
    
    public let delay: String                       // 红绿灯延误时间
    public let type: String
    public let rawJSON: [String: Any]
    
    public init(map: Mapper) throws {
        displayNumber = try? map.lid()
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

