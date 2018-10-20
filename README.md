# fucking-beijing-bus-api

[![Swift](https://img.shields.io/badge/swift-4.2-orange.svg?style=flat)](#) [![Swift Package Manager](https://rawgit.com/jlyonsmith/artwork/master/SwiftPackageManager/swiftpackagemanager-compatible.svg)](https://swift.org/package-manager/)

北京实时公交 API。可以获得车站公交的到站情况，以及公交车的实时定位。

数据来源：[北京实时公交 App](http://jtw.beijing.gov.cn/ztlm/bjssgj/) 的接口，信息相对地图 app 更准确。

## Installation

require swift 4.2+

Swift Package Manager 
```
.package(url: "https://github.com/leavez/fucking-beijing-bus-api.git", from: "1.0.0")
```

## Features

```Swift

public struct BeijingBusAPI {

    /// static data
    public struct Static {

        /// 获取所有线路
        ///
        /// 该接口把所有公交路线都返回回来，大概 2000 多条（同一条线路的两个方向视为两条），接口数据大概 40+k
        /// 主要用来获取 lineID。一般不会变，建议缓存
        public static func getAllLines(completion: @escaping ((Result<[LineMeta]>) -> Void))

        /// 获取线路的详细信息（如所包含的车站）
        ///
        /// - Parameters:
        ///   - lineID: 所要查询的线路 ID，getAllLines 中返回的 ID。不是公交车上面写的线路号码。
        public static func getLineDetail(ofLine lineID: String, completion: @escaping (Result<LineDetail?>) -> Void)

        public struct Cache {

            /// 如果有缓存数据，先读缓存，否则再去请求网络。
            /// 如果想清空请求数据，可以使用 cache 函数设 Key.allLines 为 nil
            public static func getAllLinesSmartly(completion: @escaping ((Result<[LineMeta]>) -> Void))

            /// 如果有缓存数据，先读缓存，否则再去请求网络。
            /// 如果想清空请求数据，可以使用 cache 函数设 Key.lineDetails 为 nil
            public static func getLineDetailSmartly(ofLine lineID: String, completion: @escaping (Result<LineDetail?>) -> Void)
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
        public static func getLineStatusForStation(_ stationWithLines: [(lineID: String, stationName: String, indexInBusLine: Int)], completion: @escaping (Result<[BusStatusForStation]>) -> Void)

        /// 获取公交线路的所有车的状态（实时位置等）
        ///
        /// 返回结果为数组，数组中所有信息都是相对输入参数中的车站。
        ///
        /// - Parameters:
        ///   - lineID: 所要查询的线路 ID。同个线路两个方向的车，ID 是不一样的
        ///   - indexInBusLine: 参考车站在线路中的序数
        public static func getAllBusesStatus(ofLine lineID: String, referenceStation indexInBusLine: Int, completion: @escaping (Result<[BusStatusForStation]>) -> Void)
    }
}

```

## Acknowledgment

通过抓包/逆向和参考以下资料实现：

    - https://github.com/wong2/beijing_bus
    - https://blog.ddiu.site/bjbus-api-3/
    - https://github.com/wong2/beijing_bus/wiki/Decompile

MIT
