
import Alamofire
import Mappable

struct BeijingBusAPI {
    
    func requestAPI(path: String,
                    parameters: [String: Any]? = [:],
                    completion: @escaping (DataResponse<Any>)->Void)
    {
        let baseURL = "http://transapp.btic.org.cn:8512/"
        var url = baseURL + path
        let additionalQuery = "city=%E5%8C%97%E4%BA%AC&datatype=json"
        if url.contains("?") {
            url += ("?" + additionalQuery)
        } else {
            url += ("&" + additionalQuery)
        }
        let request = Alamofire.request(url,
                                        method: .post,
                                        parameters: parameters,
                                        encoding: URLEncoding(),
                                        headers: nil)
        request.responseJSON { (dataResponse) in
            // print(dataResponse)
            completion(dataResponse)
        }
    }
    
    
    
    
    
    
    public func getAll() {
        
    }
    

    
    /// 获取公交线路对于指定车站最近一辆车的状态（批量接口）
    ///
    /// 使用 lineID 表示公交线路，（stationName, indexInBusLine） 表示一个公交站，其中 indexInBusLine
    /// 表示该站在线路中是第几个站（始发站为 1）。
    ///
    public func getLineInfoForStation(_ stationWithLines: [(lineID:String, stationName:String, indexInBusLine:Int)], completion: @escaping ( Result<[BusInfoAtStation]>) -> Void)
    {
        let items = stationWithLines.map {
            String(format:"%d@@@%d@@@%@", $0.lineID, $0.indexInBusLine, $0.stationName)
        } .joined(separator: "|||")
        
        requestAPI(path: "ssgj/bus2.php", parameters:  ["query": items]) { (response) in
            switch response.result {
            case .success(let dict):
                guard let root = (dict as? [String: Any])?["root"],
                    let data = (root as? [String: Any])?["data"],
                    let bus = (data as? [String:Any])?["bus"] as? [[String: Any]]
                    else {
                        completion(.success([]))
                        return
                }
                
                let infos = bus.compactMap {
                    try? BusInfoAtStation(JSONObject: $0)
                }
                completion(.success(infos))
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }
    
    /// 获取公交线路的所有车的状态
    ///
    /// 返回结果为数组，数组中所有信息都是相对输入参数中的车站。
    ///
    public func getAllBusInfo(ofLine lineID:String, referenceStation indexInBusLine:Int, completion: @escaping ( Result<[BusInfoAtStation]>) -> Void)
    {
        var path = "ssgj/bus.php"
        path += "?id=\(lineID)&no=\(indexInBusLine)"
        // we mannuly set encrypt=1, or it will return in another unknow encryption method
        path += "&encrypt=1"
        
        requestAPI(path:path) { (response) in
            switch response.result {
            case .success(let dict):
                guard let root = (dict as? [String: Any])?["root"],
                    let data = (root as? [String: Any])?["data"],
                    let bus = (data as? [String:Any])?["bus"] as? [[String: Any]]
                    else {
                        completion(.success([]))
                        return
                }
                
                let infos = bus.compactMap {
                    try? BusInfoAtStation(JSONObject: $0)
                }
                completion(.success(infos))
            case .failure(let e):
                completion(.failure(e))
            }
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
