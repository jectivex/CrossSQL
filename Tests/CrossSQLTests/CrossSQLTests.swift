import XCTest
@testable import CrossSQL

final class CrossFoundationTests: XCTestCase {
    func testSwiftSQLConnection() throws {
        try Connection.demoDatabase()
    }

    func testSwiftSQLConnectionAsync() async throws {
        try await Connection.demoDatabaseAsync()
    }

}

#if canImport(Skiff)
import Skiff

extension CrossFoundationTests {
    func testKotlinSQLConnection() throws {
        try Skiff().transpileAndTest()
    }
}
#endif
