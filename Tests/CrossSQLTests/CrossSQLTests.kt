package CrossSQL

import org.junit.*
import org.junit.Assert.*
import org.junit.runner.RunWith

import kotlinx.coroutines.*
import kotlinx.coroutines.test.*

@RunWith(org.robolectric.RobolectricTestRunner::class)
@org.robolectric.annotation.Config(manifest=org.robolectric.annotation.Config.NONE)
internal class CrossSQLTests: XCTestCase {
    @Test fun testDatabase() {
        Connection.testDatabase()
    }

    // WIP: symbols are not linking with the cases yet
    //    public func testDatabase() throws {
    //        // FIXME: cannot determine type
    //        //let random: Random = Random.shared
    //        //let rnd: Double = (random as Random).randomDouble()
    //        let rnd = 1
    //
    //        let dbname = "/tmp/demosql_\(rnd).db"
    //
    //        print("connecting to: " + dbname)
    //        let conn: Connection = try Connection(dbname)
    //
    //
    //        try conn.execute(sql: "CREATE TABLE FOO(NAME VARCHAR, NUM INTEGER, DBL FLOAT)")
    //        for i in 1...10 {
    //            var values: Array<SQLValue> = Array<SQLValue>()
    //            values.insert(SQLValue.text(string: "NAME_" + i.description), at: 0)
    //            try conn.execute(sql: "INSERT INTO FOO VALUES(?, ?, ?)", params: values)
    //        }
    //
    //        let cursor: Cursor = try conn.query(sql: "SELECT * FROM FOO")
    //
    //        var row = 0
    //        let consoleWidth = 45
    //
    //        while try cursor.next() {
    //            if row == 0 {
    //                // header and border rows
    //                print(cursor.rowText(header: false, values: false, width: consoleWidth))
    //                print(cursor.rowText(header: true, values: false, width: consoleWidth))
    //                print(cursor.rowText(header: false, values: false, width: consoleWidth))
    //            }
    //
    //            print(cursor.rowText(header: false, values: true, width: consoleWidth))
    //
    //            row += 1
    //
    //            assert(cursor.getColumnName(column: 0) == "NAME")
    //            assert(cursor.getString(column: 0) == "NAME_\(row)")
    //
    //            assert(cursor.getColumnName(column: 1) == "NUM")
    //            assert(cursor.getInt64(column: 1) == /* gryphon value: row.toLong() */ Int64(row))
    //
    //            assert(cursor.getColumnName(column: 2) == "DBL")
    //            assert(cursor.getDouble(column: 2) == /* gryphon value: row.toDouble() */ Double(row))
    //        }
    //        print(cursor.rowText(header: false, values: false, width: consoleWidth))
    //
    //        try cursor.close()
    //        assert(cursor.closed == true)
    //
    //        try conn.execute(sql: "DROP TABLE FOO")
    //
    //        conn.close()
    //        assert(conn.closed == true)
    //
    //        let dataFile: Data = try readData(fromPath: dbname)
    //        assert(dataFile.count > 1024) // 8192 on Darwin, 12288 for Android
    //
    //        // 'removeItem(at:)' is deprecated: URL paths not yet implemented in Kotlin
    //        //try FileManager.default.removeItem(at: URL(fileURLWithPath: dbname, isDirectory: false))
    //
    //        try FileManager.default.removeItem(atPath: dbname)
    //    }
}



// Mimics the API of XCTest for a JUnit test
// Behavior difference: JUnit assert* thows an exception, but XCTAssert* just reports the failure and continues

internal interface XCTestCase { }

internal fun XCTestCase.XCTFail() = org.junit.Assert.fail()
internal fun XCTestCase.XCTFail(msg: String) = org.junit.Assert.fail(msg)

internal fun XCTestCase.XCTUnwrap(ob: Any?) = { org.junit.Assert.assertNotNull(ob); ob }
internal fun XCTestCase.XCTUnwrap(ob: Any?, msg: String) = { org.junit.Assert.assertNotNull(msg, ob); ob }

internal fun XCTestCase.XCTAssertTrue(a: Boolean) = org.junit.Assert.assertTrue(a as Boolean)
internal fun XCTestCase.XCTAssertTrue(a: Boolean, msg: String) = org.junit.Assert.assertTrue(msg, a)
internal fun XCTestCase.XCTAssertFalse(a: Boolean) = org.junit.Assert.assertFalse(a)
internal fun XCTestCase.XCTAssertFalse(a: Boolean, msg: String) = org.junit.Assert.assertFalse(msg, a)

internal fun XCTestCase.XCTAssertNil(a: Any?) = org.junit.Assert.assertNull(a)
internal fun XCTestCase.XCTAssertNil(a: Any?, msg: String) = org.junit.Assert.assertNull(msg, a)
internal fun XCTestCase.XCTAssertNotNil(a: Any?) = org.junit.Assert.assertNotNull(a)
internal fun XCTestCase.XCTAssertNotNil(a: Any?, msg: String) = org.junit.Assert.assertNotNull(msg, a)

internal fun XCTestCase.XCTAssertIdentical(a: Any?, b: Any?) = org.junit.Assert.assertSame(a, b)
internal fun XCTestCase.XCTAssertIdentical(a: Any?, b: Any?, msg: String) = org.junit.Assert.assertSame(msg, a, b)
internal fun XCTestCase.XCTAssertNotIdentical(a: Any?, b: Any?) = org.junit.Assert.assertNotSame(a, b)
internal fun XCTestCase.XCTAssertNotIdentical(a: Any?, b: Any?, msg: String) = org.junit.Assert.assertNotSame(msg, a, b)


internal fun XCTestCase.XCTAssertEqual(a: Any?, b: Any?) = org.junit.Assert.assertEquals(a, b)
internal fun XCTestCase.XCTAssertEqual(a: Any?, b: Any?, msg: String) = org.junit.Assert.assertEquals(msg, a, b)
internal fun XCTestCase.XCTAssertEqual(a: kotlin.Double, b: kotlin.Double) = org.junit.Assert.assertEquals(a, b)
internal fun XCTestCase.XCTAssertEqual(a: kotlin.Double, b: kotlin.Double, msg: String) = org.junit.Assert.assertEquals(msg, a, b)
internal fun XCTestCase.XCTAssertEqual(a: kotlin.Float, b: kotlin.Float) = org.junit.Assert.assertEquals(a, b)
internal fun XCTestCase.XCTAssertEqual(a: kotlin.Float, b: kotlin.Float, msg: String) = org.junit.Assert.assertEquals(msg, a, b)
internal fun XCTestCase.XCTAssertEqual(a: kotlin.Long, b: kotlin.Long) = org.junit.Assert.assertEquals(a, b)
internal fun XCTestCase.XCTAssertEqual(a: kotlin.Long, b: kotlin.Long, msg: String) = org.junit.Assert.assertEquals(msg, a, b)
internal fun XCTestCase.XCTAssertEqual(a: kotlin.Int, b: kotlin.Int) = org.junit.Assert.assertEquals(a, b)
internal fun XCTestCase.XCTAssertEqual(a: kotlin.Int, b: kotlin.Int, msg: String) = org.junit.Assert.assertEquals(msg, a, b)


internal fun XCTestCase.XCTAssertNotEqual(a: Any?, b: Any?) = org.junit.Assert.assertNotEquals(a, b)
internal fun XCTestCase.XCTAssertNotEqual(a: Any?, b: Any?, msg: String) = org.junit.Assert.assertNotEquals(msg, a, b)
internal fun XCTestCase.XCTAssertNotEqual(a: kotlin.Double, b: kotlin.Double) = org.junit.Assert.assertNotEquals(a, b)
internal fun XCTestCase.XCTAssertNotEqual(a: kotlin.Double, b: kotlin.Double, msg: String) = org.junit.Assert.assertNotEquals(msg, a, b)
internal fun XCTestCase.XCTAssertNotEqual(a: kotlin.Float, b: kotlin.Float) = org.junit.Assert.assertNotEquals(a, b)
internal fun XCTestCase.XCTAssertNotEqual(a: kotlin.Float, b: kotlin.Float, msg: String) = org.junit.Assert.assertNotEquals(msg, a, b)
internal fun XCTestCase.XCTAssertNotEqual(a: kotlin.Long, b: kotlin.Long) = org.junit.Assert.assertNotEquals(a, b)
internal fun XCTestCase.XCTAssertNotEqual(a: kotlin.Long, b: kotlin.Long, msg: String) = org.junit.Assert.assertNotEquals(msg, a, b)
internal fun XCTestCase.XCTAssertNotEqual(a: kotlin.Int, b: kotlin.Int) = org.junit.Assert.assertNotEquals(a, b)
internal fun XCTestCase.XCTAssertNotEqual(a: kotlin.Int, b: kotlin.Int, msg: String) = org.junit.Assert.assertNotEquals(msg, a, b)
