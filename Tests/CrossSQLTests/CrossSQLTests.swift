import XCTest
@testable import CrossSQL
import CrossFoundation
#if GRYPHON
// gryphon insert: import CrossFoundation.*
#endif

final class CrossSQLTests: XCTestCase {
    public func testDatabase() throws {
        try Connection.testDatabase()
    }

    public func testConnection() throws {
        let url: URL = URL.init(fileURLWithPath: "/tmp/testConnection.db", isDirectory: false)
        let conn: Connection = try Connection.open(url: url)
        XCTAssertEqual(1.0, try conn.query(sql: "SELECT 1.0").singleValue()?.floatValue)
        XCTAssertEqual(3.5, try conn.query(sql: "SELECT 1.0 + 2.5").singleValue()?.floatValue)
        conn.close()
    }

}

#if !GRYPHON
#if canImport(Skiff)
import Skiff

extension CrossSQLTests {
    /// Transpiles to Kotlin as a side-effect of the test run; this will eventually be a package plug-in, but for now we run it as a side-effect of `swift test`.
    func testKotlinSQLConnection() throws {
        try Skiff().transpileAndTest()
    }
}
#endif
#endif
