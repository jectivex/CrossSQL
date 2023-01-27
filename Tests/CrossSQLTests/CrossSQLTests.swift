import XCTest
@testable import CrossSQL
import CrossFoundation

final class CrossSQLTests: XCTestCase {
    public func testDatabase() throws {
        try Connection.testDatabase()
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
////        assert(try! conn.query(sql: "SELECT 1.0").nextRow(close: true)?.first?.floatValue == 1.0)
////        assert(try! conn.query(sql: "SELECT 'ABC'").nextRow(close: true)?.first?.textValue == "ABC")
////        assert(try! conn.query(sql: "SELECT lower('ABC')").nextRow(close: true)?.first?.textValue == "abc")
////        assert(try! conn.query(sql: "SELECT 3.0/2.0, 4.0*2.5").nextRow(close: true)?.last?.floatValue == 10.0)
//
////        assert(try! conn.query(sql: "SELECT ?", params: [.text(string: "ABC")]).nextRow(close: true)?.first?.textValue == "ABC")
////        assert(try! conn.query(sql: "SELECT upper(?), lower(?)", params: [.text(string: "ABC"), .text(string: "XYZ")]).nextRow(close: true)?.last?.textValue == "xyz")
////
////        // gryphon ignore
////        assert(try! conn.query(sql: "SELECT ?", params: [.float(double: 1.5)]).nextRow(close: true)?.last?.floatValue == 1.5) // compiles but AssertionError in Kotlin
////
////        // gryphon ignore
////        assert(try! conn.query(sql: "SELECT 1").nextRow(close: true)?.first?.integerValue == 1) // Kotlin error: “Operator '==' cannot be applied to 'Long?' and 'Int'”
////
//        try conn.execute(sql: "CREATE TABLE FOO(NAME VARCHAR, NUM INTEGER, DBL FLOAT)")
//        for i in 1...10 {
//            var values: Array<SQLValue> = Array<SQLValue>()
//            values.insert(SQLValue.text(string: "NAME_" + i.description), at: 0)
////            values = [
////                SQLValue.text(string: "NAME_" + i.description),
////                SQLValue.integer(int: /* gryphon value: i.toLong() */ Int64(i)),
////                SQLValue.float(double: Double(i)),
////            ] as Array<SQLValue>
//            try conn.execute(sql: "INSERT INTO FOO VALUES(?, ?, ?)", params: values)
//        }
//
//        let cursor: Cursor = try conn.query(sql: "SELECT * FROM FOO")
////        let colcount: Int32 = cursor.columnCount
////        print("columns: \(colcount)")
////        assert(colcount == 3)
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
////            assert(cursor.getColumnType(column: 0) == ColumnType.text)
//            assert(cursor.getString(column: 0) == "NAME_\(row)")
//
//            assert(cursor.getColumnName(column: 1) == "NUM")
////            assert(cursor.getColumnType(column: 1) == ColumnType.integer)
//            assert(cursor.getInt64(column: 1) == /* gryphon value: row.toLong() */ Int64(row))
//
//            assert(cursor.getColumnName(column: 2) == "DBL")
////            assert(cursor.getColumnType(column: 2) == ColumnType.float)
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
