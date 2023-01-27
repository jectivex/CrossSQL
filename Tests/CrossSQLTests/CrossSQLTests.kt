package CrossSQL

import org.junit.*
import org.junit.Assert.*
import org.junit.runner.RunWith

import kotlinx.coroutines.*
import kotlinx.coroutines.test.*

@RunWith(org.robolectric.RobolectricTestRunner::class)
@org.robolectric.annotation.Config(manifest=org.robolectric.annotation.Config.NONE)
internal class CrossSQLTests {    //fun XCTUnwrap(a: Any?) = assertNotNull(a)

    fun XCTAssertTrue(a: Boolean) = assertTrue(a)
    fun XCTAssertTrue(a: Boolean, msg: String) = assertTrue(msg, a)
    fun XCTAssertFalse(a: Boolean) = assertFalse(a)
    fun XCTAssertFalse(a: Boolean, msg: String) = assertFalse(msg, a)
    fun XCTAssertNil(a: Any?) = assertNull(a)
    fun XCTAssertNil(a: Any?, msg: String) = assertNull(msg, a)
    fun XCTAssertNotNil(a: Any?) = assertNotNull(a)
    fun XCTAssertNotNil(a: Any?, msg: String) = assertNotNull(msg, a)

    fun XCTAssertEqual(a: Any?, b: Any?) = assertEquals(a, b)
    fun XCTAssertEqual(a: Any?, b: Any?, msg: String) = assertEquals(msg, a, b)
    fun XCTAssertNotEqual(a: Any?, b: Any?) = assertNotEquals(a, b)
    fun XCTAssertNotEqual(a: Any?, b: Any?, msg: String) = assertNotEquals(msg, a, b)
    fun XCTAssertIdentical(a: Any?, b: Any?) = assertSame(a, b)
    fun XCTAssertIdentical(a: Any?, b: Any?, msg: String) = assertSame(msg, a, b)
    fun XCTAssertNotIdentical(a: Any?, b: Any?) = assertNotSame(a, b)
    fun XCTAssertNotIdentical(a: Any?, b: Any?, msg: String) = assertNotSame(msg, a, b)


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
