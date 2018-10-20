
import Foundation
import Alamofire
import Mappable

public struct BeijingBusAPI {
    
    func requestAPI(path: String,
                    method: HTTPMethod = .get,
                    parameters: [String: Any]? = nil,
                    additionalHeaders: [String: String]? = nil,
                    completion: @escaping (DataResponse<Any>)->Void)
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
        let request = Alamofire.request(url,
                                        method: method,
                                        parameters: parameters,
                                        encoding: URLEncoding(),
                                        headers:additionalHeaders)
        request.responseJSON { (dataResponse) in
             print(dataResponse)
            completion(dataResponse)
        }
    }
    
    
    
    
    
    /// 该接口把所有公交路线都返回回来，大概 2000 多条（同一条线路的两个方向视为两条），接口数据大概 40+k
    public func getAllLines(completion: @escaping ((Result<[BusMeta]>) -> Void)) {
        
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
            let parsed = response.result.map({ dict -> [BusMeta] in
                guard let root = (dict as? [String: Any])?["lines"],
                    let data = (root as? [String:Any])?["line"] as? [[String: Any]]
                    else {
                        return []
                }
                return data.compactMap {
                    try? BusMeta(JSONObject: $0)
                }
            })
            completion(parsed)
        }
    }
    

    
    /// 获取公交线路对于指定车站最近一辆车的状态（批量接口）
    ///
    /// 使用 lineID 表示公交线路，（stationName, indexInBusLine） 表示一个公交站，其中 indexInBusLine
    /// 表示该站在线路中是第几个站（始发站为 1）。
    ///
    public func getLineStatusForStation(_ stationWithLines: [(lineID:String, stationName:String, indexInBusLine:Int)], completion: @escaping ( Result<[BusStatusForStation]>) -> Void)
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
    
    /// 获取公交线路的所有车的状态
    ///
    /// 返回结果为数组，数组中所有信息都是相对输入参数中的车站。
    /// lineID, 同个线路两个方向的车，ID 是不一样的
    ///
    public func getAllBusesStatus(ofLine lineID:String, referenceStation indexInBusLine:Int, completion: @escaping ( Result<[BusStatusForStation]>) -> Void)
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
    
    
}


