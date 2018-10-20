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


public struct LineMeta {
    let ID: String
    let busNumber: String // 大部分为数字。对于运通路线，前面包含"运通"二字
    let departureStationName: String
    let terminalStationName: String
    
    let classify: String // 线路分类，比较粗糙，没有什么实际意义
    let status: String // unknow
    let version: String // unknow
    
    public let rawJSON: [String: Any]
}


public struct LineDetail {
    
    public struct Station {
        let name: String
        let index: Int
        let location: (longitude:Double, latitude:Double)
    }
    
    let ID: String
    let busNumber: String // 大部分为数字。对于运通路线，前面包含"运通"二字
    let departureStationName: String
    let terminalStationName: String
    let operationTime: String
    let stations: [Station]
    
    let coords:String // 一些列坐标，这里面的坐标和 stations 里的坐标略有不同，不知道为什么
}






extension BusStatusForStation: Mappable {
    
    /*
     逆向自 Android 客户端
     @SerializedName("lt")
     private String delay;
     private String extraInfo;
     @SerializedName("gt")
     private String gpsupdateTime;
     @SerializedName("y")
     private String lat;
     @SerializedName("x")
     private String lon;
     @SerializedName("id")
     private String mId;
     @SerializedName("lid")
     private String mLineId;
     @SerializedName("sn")
     private String mStationNum;
     @SerializedName("ns")
     private String nextStation;
     @SerializedName("nsd")
     private String nextStationDistince;
     private int nextStationNo;
     @SerializedName("nsn")
     private String nextStationNoStr;
     @SerializedName("nsrt")
     private String nextStationRunTimes;
     @SerializedName("nst")
     private String nextStationTime;
     @SerializedName("ut")
     private String serverTime;
     private int speedd;
     @SerializedName("sd")
     private String stationDistince;
     @SerializedName("srt")
     private String stationRunTimes;
     @SerializedName("st")
     private String stationTime;
     @SerializedName("t")
     private String type;
     */
    
    public init(map: Mapper) throws {
        busNumber = try? map.lid()
        ID = try map.id()
        timestamp = try map.ut()
        
        let de = Decryption(key: try map.gt())
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


extension LineMeta: Mappable {
    
    public init(map: Mapper) throws {
        ID = try map.id()
        
        let name: String = try map.linename()
        let parsed = paresefullName(name)
        busNumber = parsed.lineNumber
        departureStationName = parsed.departureStationName
        terminalStationName = parsed.terminalStationName
        
        classify = try map.classify()
        version = try map.version()
        status = try map.status()
        rawJSON = map.getRootValue() as? [String: Any] ?? [:]
    }
}

extension LineDetail: Mappable {
    public init(map: Mapper) throws {
        ID = try map.lineid()
        let de = Decryption(key: ID)
        
        busNumber = de.decode(string: try map.shotname())
        let parsed = paresefullName(de.decode(string: try map.linename()))
        departureStationName = parsed.departureStationName
        terminalStationName = parsed.terminalStationName
        operationTime = try map.time()
        
        
        stations = try map.getValue("stations.station", as: [[String: String]].self).map { dict in
            let name = de.decode(string: dict["name"] ?? "")
            let index = Int(de.decode(string:  dict["no"] ?? "")) ?? -1
            let lon = Double(de.decode(string:  dict["lon"] ?? "") ) ?? -1
            let lat = Double(de.decode(string:  dict["lat"] ?? "") ) ?? -1
            return Station(name: name, index: index, location: (lon, lat))
        }
        
        coords = de.decode(string: try map.coord())
    }
}


private let busNameRegex = try! NSRegularExpression(pattern: "^(.+)\\((.+)\\-(.+)\\)$", options: [])
private func paresefullName(_ name:String) -> (lineNumber:String, departureStationName:String, terminalStationName: String) {
    if let match = busNameRegex.firstMatch(in: name, options: [], range: NSMakeRange(0, name.count)), match.numberOfRanges == 4 {
        let groups = (1...3).map { (i: Int) -> String in
            let range = match.range(at: i)
            return (name as NSString).substring(with: range)
        }
        return (groups[0], groups[1], groups[2])
    } else {
        return (name, "", "")
    }
}


