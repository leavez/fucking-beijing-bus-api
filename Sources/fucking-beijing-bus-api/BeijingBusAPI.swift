
import Foundation
import Alamofire
import Mappable

public struct BeijingBusAPI {
    
    /// static data
    public struct Static {
        
        /// 获取所有线路
        ///
        /// 该接口把所有公交路线都返回回来，大概 2000 多条（同一条线路的两个方向视为两条），接口数据大概 40+k
        /// 主要用来获取 lineID。一般不会变，建议缓存
        public static func getAllLines(completion: @escaping ((Result<[LineMeta], AFError>) -> Void)) {
            
            // 加密的方式在 android 逆向的 headerSetHelper.class 有实现，但没有调通
            // ABTOKEN 是 token，由 PLATFORM CID TIME 算出来。
            // 试过 2018 年 2 月抓的一个包的 token，在 10 月仍然可用，故直接写死了。
            let headers = [
                "PID": "5",
                "PLATFORM": "ios",
                "CID":"18d31a75a568b1e9fab8e410d398f981",
                "TIME": "1539706356",
                "ABTOKEN": "31d7dae1d869a172f3b66fa14fe274d1",
                
                "VID": "6",
                "IMEI": "\(arc4random_uniform(10000)+1)",
                "CTYPE": "json",
                ]
            
            requestAPI(path: "ssgj/v1.0.0/checkUpdate?version=1",
                       additionalHeaders:headers) { (response) in
                        let parsed = response.result.map({ dict -> [LineMeta] in
                            guard let root = (dict as? [String: Any])?["lines"],
                                let data = (root as? [String:Any])?["line"] as? [[String: Any]]
                                else {
                                    return []
                            }
                            return data.compactMap {
                                try? LineMeta(JSONObject: $0)
                            }
                        })
                        completion(parsed)
            }
        }
        
        public static func getAllLinesSync() -> Result<[LineMeta], AFError> {
            return toSync(Static.getAllLines(completion:))
        }

        

        
        /// 获取线路的详细信息（如所包含的车站）
        ///
        /// - Parameters:
        ///   - lineID: 所要查询的线路 ID，getAllLines 中返回的 ID。不是公交车上面写的线路号码。
        public static func getLineDetail(ofLine lineID:String, completion: @escaping ( Result<LineDetail?, AFError>) -> Void) {
            var path = "ssgj/v1.0.0/update"
            path += "?id=\(lineID)"
            
            let headers = [
                "PID": "5",
                "PLATFORM": "ios",
                "CID":"18d31a75a568b1e9fab8e410d398f981",
                "TIME": "1540031093",
                "ABTOKEN": "55750cf92a54b09bd52e23105f7f60aa",
                
                "VID": "6",
                "IMEI": "\(arc4random_uniform(10000)+1)",
                "CTYPE": "json",
                ]
            
            requestAPI(path:path, additionalHeaders: headers) { (response) in
                let parsed = response.result.map({ dict -> LineDetail? in
                    guard let busline = (dict as? [String: Any])?["busline"] as? [[String: Any]]
                        else {
                            return nil
                    }
                    return busline.first.map { dict -> LineDetail? in
                        return try? LineDetail(JSONObject: dict)
                        } as? LineDetail
                })
                completion(parsed)
            }
        }
        
        public static func getLineDetailSync(ofLine lineID:String) -> Result<LineDetail?, AFError> {
            return toSync(lineID, Static.getLineDetail(ofLine:completion:))
        }
    }
    
    
    

    /// real time data
    public struct RealTime {
        
        /// 批量获取公交线路对于指定车站最近一辆车的状态
        ///
        /// 其中虽然（stationName, indexInBusLine）都可以表示一个具体车站，但两者都要求传入。
        ///
        /// - Parameters:
        ///   - stationWithLines: 需要获取的线路和对应的车站
        ///      - lineID: 所要查询的线路 ID，getAllLines 中返回的 ID。不是公交车上面写的线路号码。
        ///      - stationName: 车站的中文名
        ///      - indexInBusLine: indexInBusLine

        public static func getLineStatusForStation(_ stationWithLines: [(lineID:String, stationName:String, indexInBusLine:Int)], completion: @escaping ( Result<[BusStatusForStation], AFError>) -> Void)
        {
            let items = stationWithLines.map {
                String(format:"%@@@@%d@@@%@", $0.lineID, $0.indexInBusLine, $0.stationName)
                } .joined(separator: "|||")
            
            requestAPI(path: "ssgj/bus2.php",
                       method: .post,
                       parameters:  ["query": items]) { (response) in
                        let parsed = response.result.map({ dict -> [BusStatusForStation] in
                            guard let root = (dict as? [String: Any])?["root"],
                                let data = (root as? [String: Any])?["data"],
                                let bus = (data as? [String:Any])?["bus"] as? [[String: Any]]
                                else {
                                    return []
                            }
                            return bus.compactMap {
                                try? BusStatusForStation(JSONObject: $0)
                            }
                        })
                        completion(parsed)
            }
        }
        
        public static func getLineStatusForStationSync(_ stationWithLines: [(lineID:String, stationName:String, indexInBusLine:Int)]) -> Result<[BusStatusForStation], AFError> {
            return toSync(stationWithLines, RealTime.getLineStatusForStation(_:completion:))
        }
        
        /// 获取公交线路的所有车的状态（实时位置等）
        ///
        /// 返回结果为数组，数组中所有信息都是相对输入参数中的车站。
        ///
        /// - Parameters:
        ///   - lineID: 所要查询的线路 ID。同个线路两个方向的车，ID 是不一样的
        ///   - indexInBusLine: 参考车站在线路中的序数
        public static func getAllBusesStatus(ofLine lineID:String, referenceStation indexInBusLine:Int, completion: @escaping ( Result<[BusStatusForStation], AFError>) -> Void)
        {
            var path = "ssgj/bus.php"
            path += "?id=\(lineID)&no=\(indexInBusLine)"
            // we mannuly set encrypt=1, or it will return in another unknow encryption method
            path += "&encrypt=1"
            
            requestAPI(path:path) { (response) in
                let parsed = response.result.map({ dict -> [BusStatusForStation] in
                    guard let root = (dict as? [String: Any])?["root"],
                        let data = (root as? [String: Any])?["data"],
                        let bus = (data as? [String:Any])?["bus"] as? [[String: Any]]
                        else {
                            return []
                    }
                    return bus.compactMap {
                        try? BusStatusForStation(JSONObject: $0)
                    }
                })
                completion(parsed)
            }
        }
        
        public static func getAllBusesStatusSync(ofLine lineID:String, referenceStation indexInBusLine:Int) -> Result<[BusStatusForStation], AFError> {
            return toSync(lineID,indexInBusLine, RealTime.getAllBusesStatus(ofLine:referenceStation:completion:))
        }
        
    }
    
    
    
    
    
    // MARK:- Inner

    private static func requestAPI(path: String,
                                   method: HTTPMethod = .get,
                                   parameters: [String: Any]? = nil,
                                   additionalHeaders: [String: String]? = nil,
                                   completion: @escaping (AFDataResponse<Any>)->Void)
    {
        // compose the url
        let baseURL = "http://transapp.btic.org.cn:8512/"
        var url = baseURL + path
        let beijing = "北京".addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)!
        let additionalQuery = "city=\(beijing)&datatype=json"
        if url.contains("?") {
            url += ("&" + additionalQuery)
        } else {
            url += ("?" + additionalQuery)
        }
        
        // request
        let request = AF.request(url,
                                 method: method,
                                 parameters: parameters,
                                 encoding: URLEncoding(),
                                 headers: additionalHeaders.map{HTTPHeaders($0)})
        request.responseJSON { (dataResponse) in
            completion(dataResponse)
        }
    }
    
    
}


