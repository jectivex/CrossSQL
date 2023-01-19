import XCTest
import Skiff
@testable import CrossSQL

final class CrossFoundationTests: XCTestCase {
    func testDemoDatabase() throws {
        try Connection.demoDatabase()
    }

    func testTranspilation() throws {
        try Skiff().transpileAndTest()
    }
}
