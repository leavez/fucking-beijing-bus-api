import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(fucking_beijing_bus_apiTests.allTests),
    ]
}
#endif