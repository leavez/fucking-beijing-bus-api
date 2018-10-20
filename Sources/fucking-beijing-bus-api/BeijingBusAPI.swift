
import Foundation
import Alamofire
import Mappable

struct BeijingBusAPI {
    
    func requestAPI(path: String,
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
                                        method: .post,
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
        
        // https://github.com/wong2/beijing_bus/issues/8
        let headers = [
            "TIME": "1539706356",
            "ABTOKEN": "31d7dae1d869a172f3b66fa14fe274d1",
            "CID":"18d31a75a568b1e9fab8e410d398f981",
            "PLATFORM": "ios",
            "PID": "5",
            "VID": "\(arc4random_uniform(10)+1)",
            "IMEI": "\(arc4random_uniform(10000)+1)",
            "CTYPE": "json"
        ]
        
        requestAPI(path: "ssgj/v1.0.0/checkUpdate?version=1", additionalHeaders:headers) { (response) in
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
        
        requestAPI(path: "ssgj/bus2.php", parameters:  ["query": items]) { (response) in
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


/*
 def get_line_update_state():
 logging.info('Getting all lines')
 params = {'m': 'checkUpdate', 'version': '1'}
 return request_api(API_ENDPOINT, params)
 
 
 def get_bus_offline_data(line_id):
 logging.info('Fetching line: %s' % line_id)
 params = {'m': 'update', 'id': line_id}
 return request_api(API_ENDPOINT, params)
 
 
 def get_realtime_data(line_id, station_num):
 params = {
 'city': '北京',
 'id': line_id,
 'no': station_num,
 'type': 2,
 'encrpt': 1,
 'versionid': 2
 }
 return request_api(REALTIME_ENDPOINT, params)
 */
