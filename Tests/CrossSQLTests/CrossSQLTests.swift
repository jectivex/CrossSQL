import XCTest
import Skiff
@testable import CrossSQL

final class CrossFoundationTests: XCTestCase {
    func testSwiftSQLConnection() throws {
        try Connection.demoDatabase()
    }

    func testKotlinSQLConnection() throws {
        try Skiff().transpileAndTest()
    }
}
