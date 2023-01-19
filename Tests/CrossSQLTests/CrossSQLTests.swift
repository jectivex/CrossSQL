import XCTest
import Skiff

final class CrossFoundationTests: XCTestCase {
    func testExample() throws {
        XCTAssertTrue(true)
    }

    func testTranspilation() throws {
        try Skiff().transpileAndTest()
    }
}
