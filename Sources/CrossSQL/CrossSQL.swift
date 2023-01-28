import CrossFoundation

#if GRYPHON
// gryphon insert: import android.database.*
// gryphon insert: import android.database.sqlite.*
// gryphon insert: import CrossFoundation.*
#else
#if os(Linux)
import CSQLite
#else
import SQLite3
#endif
#endif

/// A connection to SQLite.
public final class Connection {
    #if SKIP
    public let db: android.database.sqlite.SQLiteDatabase
    #else
    public typealias Handle = OpaquePointer
    fileprivate var _handle: Handle?
    public var handle: Handle { _handle! }
    #endif

    /// Whether the connection to the database is closed or not
    public private(set) var closed = false

    public init(_ filename: String, readonly: Bool = false) throws {
        #if SKIP
        self.db = SQLiteDatabase.openOrCreateDatabase(filename, null, null)
        #else
        let flags = readonly ? SQLITE_OPEN_READONLY : (SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE)
        try check(resultOf: sqlite3_open_v2(filename, &_handle, flags | SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_URI, nil))
        #endif
    }

    // FIXME: no deinit support in Kotlin (“Unknown declaration (failed to translate SwiftSyntax node).”)
    #if SKIP

    #else
    deinit {
        close()
    }
    #endif

    /// Closes the connection to the database
    func close() {
        if !closed {
            #if SKIP
            self.db.close()
            #else
            sqlite3_close(handle)
            #endif
            closed = true
        }
    }

    /// Executes a single SQL statement.
    public func execute(sql: String, params: [SQLValue] = []) throws {
        #if SKIP
        let bindArgs = params.map { $0.toBindArg() }
        db.execSQL(sql, bindArgs.toTypedArray())
        #else
        if params.isEmpty {
            // no-param single-shot exec convenience
            try check(resultOf: sqlite3_exec(handle, sql, nil, nil, nil))
        } else {
            _ = try Cursor(self, sql, params: params).nextRow(close: true)
        }
        #endif
    }

    #if SKIP

    #else
    @discardableResult fileprivate func check(resultOf resultCode: Int32) throws -> Int32 {
        let successCodes: Set = [SQLITE_OK, SQLITE_ROW, SQLITE_DONE]
        if !successCodes.contains(resultCode) {
            let message = String(cString: sqlite3_errmsg(self.handle))
            struct SQLError : Error {
                let message: String
            }
            throw SQLError(message: message)
        }

        return resultCode
    }
    #endif

    /// Executes the given query with the specified parameters.
    public func query(sql: String, params: [SQLValue] = []) throws -> Cursor {
        try Cursor(self, sql, params: params)
    }


    // some random static function is needed to get Gryphon to generate a Companion object to extend (below)
    private static func noop() throws {
    }

    #if SKIP

    #else
    /// Binds the given parameter at the given index.
    /// - Parameters:
    ///   - handle: the statement handle to bind to
    ///   - parameter: the parameter value to bind
    ///   - index: the index of the matching '?' parameter, which starts at 1
    fileprivate func bind(handle: Cursor.Handle?, parameter: SQLValue, index: Int32) throws {
        switch parameter {
        case .null:
            try self.check(resultOf: sqlite3_bind_null(handle, index))
        case let .text(string: string):
            try self.check(resultOf: sqlite3_bind_text(handle, index, string, -1, SQLITE_TRANSIENT))
        case let .integer(int: num):
            try self.check(resultOf: sqlite3_bind_int64(handle, index, num))
        case let .float(double: dbl):
            try self.check(resultOf: sqlite3_bind_double(handle, index, dbl))
        case let .blob(data: bytes) where bytes.isEmpty:
            try self.check(resultOf: sqlite3_bind_zeroblob(handle, index, 0))
        case let .blob(data: bytes):
            try bytes.withUnsafeBytes { ptr in
                try self.check(resultOf: sqlite3_bind_blob(handle, index, ptr, Int32(bytes.count), SQLITE_TRANSIENT))
            }
       }
    }
    #endif



}


#if SKIP

#else
// let SQLITE_STATIC = unsafeBitCast(0, sqlite3_destructor_type.self)
let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
#endif

public enum SQLValue {
    case null
    case text(_ string: String)
    case integer(_ int: Int64)
    case float(_ double: Double)
    case blob(_ data: Data)

    var columnType: ColumnType {
        // warnings about let pattern with no effect and default bot needed works around Grphyon translation mixed associated type w/ empty enum
        switch self {
        case .null:
            return ColumnType.null
        case let .text(string: _):
            return ColumnType.text
        case let .integer(int: _):
            return ColumnType.integer
        case let .float(double: _):
            return ColumnType.float
        case let .blob(data: _):
            return ColumnType.blob
        default:
            return ColumnType.null
        }
    }

    func toBindArg() -> Any? {
        switch self {
        case .null:
            return nil
        case let .text(string: str):
            return str
        case let .integer(int: num):
            return num
        case let .float(double: dbl):
            return dbl
        case let .blob(data: bytes):
            return bytes
        default: // needed for Kotlin when mixed associated type w/ empty enum
            return nil
        }
    }

    func toBindString() -> String? {
        switch self {
        case .null:
            return nil
        case let .text(string: str):
            return str
        case let .integer(int: num):
            return num.description
        case let .float(double: dbl):
            return dbl.description
        case let .blob(data: bytes):
            return nil // bytes.description // mis-transpiles
        default: // needed for Kotlin when mixed associated type w/ empty enum
            return nil
        }
    }

    /// If this is a `text` value, then return the underlying string
    var textValue: String? {
        switch self {
        case let .text(string: str): return str
        default: return nil
        }
    }

    /// If this is a `integer` value, then return the underlying integer
    var integerValue: Int64? {
        switch self {
        case let .integer(int: num): return num
        default: return nil
        }
    }

    /// If this is a `float` value, then return the underlying double
    var floatValue: Double? {
        switch self {
        case let .float(double: dbl): return dbl
        default: return nil
        }
    }

    /// If this is a `blob` value, then return the underlying data
    var blobValue: Data? {
        switch self {
        case let .blob(data: dat): return dat
        default: return nil
        }
    }

}

/// The type of a SQLite colums.
///
/// Every value in SQLite has one of five fundamental datatypes:
///  - 64-bit signed integer
///  - 64-bit IEEE floating point number
///  - string
///  - BLOB
///  - NULL
public enum ColumnType : Int32 {
    /// `SQLITE_NULL`
    case null = 0
    /// `SQLITE_INTEGER`, a 64-bit signed integer
    case integer = 1
    /// `SQLITE_FLOAT`, a 64-bit IEEE floating point number
    case float = 2
    /// `SQLITE_TEXT`, a string
    case text = 3
    /// `SQLITE_BLOB`, a byte array
    case blob = 4

    /// Returns true if this column is expected to hold a numeric type.
    var isNumeric: Bool {
        switch self {
        case .integer: return true
        case .float: return true
        default: return false
        }
    }
}

/// A cursor to the open result set returned by `Connection.query`.
public final class Cursor {
    fileprivate let connection: Connection

    #if SKIP
    fileprivate var cursor: android.database.Cursor
    #else
    typealias Handle = OpaquePointer
    fileprivate var handle: Handle?
    #endif

    /// Whether the cursor is closed or not
    public private(set) var closed = false

    fileprivate init(_ connection: Connection, _ SQL: String, params: [SQLValue]) throws {
        self.connection = connection

        #if SKIP
        let bindArgs: [String?] = params.map { $0.toBindString() }
        self.cursor = connection.db.rawQuery(SQL, bindArgs.toTypedArray())
        #else
        try connection.check(resultOf: sqlite3_prepare_v2(connection.handle, SQL, -1, &handle, nil))
        for (index, param) in params.enumerated() {
            try connection.bind(handle: self.handle, parameter: param, index: .init(index + 1))
        }
        #endif
    }

    var columnCount: Int32 {
        #if SKIP
        self.cursor.getColumnCount()
        #else
        sqlite3_column_count(handle)
        #endif
    }

    /// Moves to the next row in the result set, returning `false` if there are no more rows to traverse.
    func next() throws -> Bool {
        #if SKIP
        self.cursor.moveToNext()
        #else
        try connection.check(resultOf: sqlite3_step(handle)) == SQLITE_ROW
        #endif
    }

    /// Returns the name of the column at the given zero-based index.
    public func getColumnName(column: Int32) -> String {
        #if SKIP
        self.cursor.getColumnName(column)
        #else
        String(cString: sqlite3_column_name(handle, column))
        #endif
    }

    public func getColumnType(column: Int32) -> ColumnType {
        //return ColumnType(rawValue: getTypeConstant(column: column))

        switch getTypeConstant(column: column) {
        case ColumnType.null.rawValue:
            return .null
        case ColumnType.integer.rawValue:
            return .integer
        case ColumnType.float.rawValue:
            return .float
        case ColumnType.text.rawValue:
            return .text
        case ColumnType.blob.rawValue:
            return .blob
        //case let type: // “error: Unsupported switch case item (failed to translate SwiftSyntax node)”
        default:
            return .null
            //fatalError("unsupported column type")
        }
    }

    /// Returns the value contained in the given column, coerced to the expected type based on the column definition.
    public func getValue(column: Int32) -> SQLValue {
        switch getColumnType(column: column) {
        case .null:
            return .null
        case .text:
            return .text(getString(column: column))
        case .integer:
            return .integer(getInt64(column: column))
        case .float:
            return .float(getDouble(column: column))
        case .blob:
            return .null // .blob(data: getBlob(column: column)) // introduces compile error w/ Gryphon: “error: Unable to get closure type (failed to translate SwiftSyntax node).”
        default:
            return .null
        }
    }

    /// Returns the values of the current row as an array
    public func getRow() -> [SQLValue] {
        return (0..<columnCount).map { column in
            getValue(column: column)
        }
    }

    /// Returns a textual description of the row's values in a format suitable for printing to a console
    public func rowText(header: Bool = false, values: Bool = false, width: Int = 80) -> String {
        var str = ""
        let sep = header == false && values == false ? "+" : "|"
        str += sep
        let count = /* gryphon value: columnCount */ Int(columnCount)
        var cellSpan = (width / count) - 2
        if cellSpan < 0 {
            cellSpan = 0
            cellSpan = 0
        }

        for col in 0..<count {
            let i = /* gryphon value: col */ Int32(col)
            let cell: String
            if header {
                cell = getColumnName(column: i)
            } else if values {
                cell = getValue(column: i).toBindString() ?? ""
            } else {
                cell = ""
            }

            let numeric = header || values ? getColumnType(column: i).isNumeric : false
            let padding = header || values ? " " : "-"
            str += padding
            str += cell.pad(to: cellSpan - 2, with: padding, rightAlign: numeric)
            str += padding
            if col < count - 1 {
                str += sep
            }
        }
        str += sep
        return str
    }

    /// Steps to the next row and returns all the values in the row.
    /// - Parameter close: if true, closes the cursor after returning the values; this can be useful for single-shot execution of queries where only one row is expected.
    /// - Returns: an array of ``SQLValue`` containing the row contents.
   public func nextRow(close: Bool = false) throws -> [SQLValue]? {
       do {
           if try next() == false {
               try self.close()
               return nil
           } else {
               let values = getRow()
               if close {
                   try self.close()
               }
               return values
           }
       } catch let error {
           try? self.close()
           throw error
       }
    }

    public func getDouble(column: Int32) -> Double {
        #if SKIP
        self.cursor.getDouble(column)
        #else
        sqlite3_column_double(handle, column)
        #endif
    }

    public func getInt64(column: Int32) -> Int64 {
        #if SKIP
        self.cursor.getLong(column)
        #else
        sqlite3_column_int64(handle, column)
        #endif
    }

    public func getString(column: Int32) -> String {
        #if SKIP
        self.cursor.getString(column)
        #else
        String(cString: UnsafePointer(sqlite3_column_text(handle, Int32(column))))
        #endif
    }

    public func getBlob(column: Int32) -> Data {
        #if SKIP
        return self.cursor.getBlob(column)
        #else
        if let pointer = sqlite3_column_blob(handle, Int32(column)) {
            let length = Int(sqlite3_column_bytes(handle, Int32(column)))
            //let ptr = UnsafeBufferPointer(start: pointer.assumingMemoryBound(to: Int8.self), count: length)
            return Data(bytes: pointer, count: length)
        } else {
            // The return value from sqlite3_column_blob() for a zero-length BLOB is a NULL pointer.
            return Data()
        }
        #endif
    }

    private func getTypeConstant(column: Int32) -> Int32 {
        #if SKIP
        self.cursor.getType(column)
        #else
        sqlite3_column_type(handle, column)
        #endif
    }

    func close() throws {
        if !closed {
            #if SKIP
            self.cursor.close()
            #else
            try connection.check(resultOf: sqlite3_finalize(handle))
            #endif
        }
        closed = true
    }

    #if SKIP
    // TODO: finalize { close() }
    #else
    deinit {
        try? close()
    }
    #endif
}


extension Connection {
    /// Test case lives here until we can get module symbols linking from `CrossSQLTests.swift`
    static func testDatabase() throws {
        // FIXME: cannot determine type
        //let random: Random = Random.shared
        //let rnd: Double = (random as Random).randomDouble()
        let rnd = 1

        let dbname = "/tmp/demosql_\(rnd).db"

        dbg("connecting to: " + dbname)
        let conn = try Connection(dbname)

        assert(try! conn.query(sql: "SELECT 1.0").nextRow(close: true)?.first?.floatValue == 1.0)
        assert(try! conn.query(sql: "SELECT 'ABC'").nextRow(close: true)?.first?.textValue == "ABC")
        assert(try! conn.query(sql: "SELECT lower('ABC')").nextRow(close: true)?.first?.textValue == "abc")
        assert(try! conn.query(sql: "SELECT 3.0/2.0, 4.0*2.5").nextRow(close: true)?.last?.floatValue == 10.0)

        assert(try! conn.query(sql: "SELECT ?", params: [.text("ABC")]).nextRow(close: true)?.first?.textValue == "ABC")
        assert(try! conn.query(sql: "SELECT upper(?), lower(?)", params: [.text("ABC"), .text("XYZ")]).nextRow(close: true)?.last?.textValue == "xyz")

        // gryphon ignore
        assert(try! conn.query(sql: "SELECT ?", params: [.float(1.5)]).nextRow(close: true)?.last?.floatValue == 1.5) // compiles but AssertionError in Kotlin

        // gryphon ignore
        assert(try! conn.query(sql: "SELECT 1").nextRow(close: true)?.first?.integerValue == 1) // Kotlin error: “Operator '==' cannot be applied to 'Long?' and 'Int'”

        do {
            try conn.execute(sql: "DROP TABLE FOO")
        } catch {
            // exception expected when re-running on existing database
        }

        try conn.execute(sql: "CREATE TABLE FOO(NAME VARCHAR, NUM INTEGER, DBL FLOAT)")
        for i in 1...10 {
            try conn.execute(sql: "INSERT INTO FOO VALUES(?, ?, ?)", params: [.text("NAME_" + i.description), .integer(/* gryphon value: i.toLong() */ Int64(i)), .float(Double(i))])
        }

        let cursor = try conn.query(sql: "SELECT * FROM FOO")
        let colcount = cursor.columnCount
        dbg("columns: \(colcount)")
        assert(colcount == 3)

        var row = 0
        let consoleWidth = 45

        while try cursor.next() {
            if row == 0 {
                // header and border rows
                dbg(cursor.rowText(header: false, values: false, width: consoleWidth))
                dbg(cursor.rowText(header: true, values: false, width: consoleWidth))
                dbg(cursor.rowText(header: false, values: false, width: consoleWidth))
            }

            dbg(cursor.rowText(header: false, values: true, width: consoleWidth))

            row += 1

            assert(cursor.getColumnName(column: 0) == "NAME")
            assert(cursor.getColumnType(column: 0) == .text)
            assert(cursor.getString(column: 0) == "NAME_\(row)")

            assert(cursor.getColumnName(column: 1) == "NUM")
            assert(cursor.getColumnType(column: 1) == .integer)
            assert(cursor.getInt64(column: 1) == /* gryphon value: row.toLong() */ Int64(row))

            assert(cursor.getColumnName(column: 2) == "DBL")
            assert(cursor.getColumnType(column: 2) == .float)
            assert(cursor.getDouble(column: 2) == Double(row))
        }
        dbg(cursor.rowText(header: false, values: false, width: consoleWidth))

        try cursor.close()
        assert(cursor.closed == true)

        try conn.execute(sql: "DROP TABLE FOO")

        conn.close()
        assert(conn.closed == true)

        let dataFile: Data = try Data.init(contentsOfFile: dbname)
        assert(dataFile.count > 1024) // 8192 on Darwin, 12288 for Android

        // 'removeItem(at:)' is deprecated: URL paths not yet implemented in Kotlin
        //try FileManager.default.removeItem(at: URL(fileURLWithPath: dbname, isDirectory: false))

        try FileManager.default.removeItem(atPath: dbname)
    }
}
