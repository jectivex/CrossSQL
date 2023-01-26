import XCTest
@testable import CrossSQL

final class CrossSQLTests: XCTestCase {
    func testSwiftSQLConnection() throws {
        try Connection.testDatabase()
    }

    func testSwiftSQLConnectionAsync() async throws {
        try await Connection.testDatabaseAsync()
    }

}

#if canImport(Skiff)
import Skiff

extension CrossSQLTests {
    func testKotlinSQLConnection() throws {
        try Skiff().transpileAndTest()
    }
}
#endif
