
import Alamofire
import Mappable

struct BeijingBusAPI {
    
    func requestAPI(path: String,
                    parameters: [String: Any]? = nil,
                    completion: @escaping (DataResponse<Any>)->Void)
    {
        let baseURL = "http://transapp.btic.org.cn:8512/"
        let url = baseURL + path + "?city=%E5%8C%97%E4%BA%AC&datatype=json"
        let request = Alamofire.request(url,
                                        method: .post,
                                        parameters: parameters,
                                        encoding: URLEncoding(),
                                        headers: nil)
        request.responseJSON { (dataResponse) in
            print(dataResponse)
            completion(dataResponse)
        }
    }
    
    
    
    
    public typealias IDType = Int
    

    
    /// Get the status of specific stations with bus lines
    public func getStationStatus(_ stationWithLines: [(lineID:IDType, stationName:String, indexInBusLine:Int)], completion: @escaping ( Result<[BusInfoAtStation]>) -> Void)
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
    
    
    //    struct BusLine {
    //        let number: Int
    //        let ID: IDType
    //    }
    //
    //    struct Station {
    //        let indexInBusLine: Int
    //        let name: String
    //        let lineID: IDType
    //    }
    
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
