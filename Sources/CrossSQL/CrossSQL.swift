#if GRYPHON
// gryphon insert: import android.database.*
// gryphon insert: import android.database.sqlite.*
#else
#if os(Linux)
import CSQLite
#else
import SQLite3
#endif
#endif

/// A connection to SQLite.
public final class Connection {
    #if os(Android)
    public let db: android.database.sqlite.SQLiteDatabase
    #else
    public typealias Handle = OpaquePointer
    fileprivate var _handle: Handle?
    public var handle: Handle { _handle! }
    #endif

    /// Whether the connection to the database is closed or not
    public private(set) var closed = false

    public init(_ filename: String, readonly: Bool = false) throws {
        #if os(Android)
        self.db = SQLiteDatabase.openOrCreateDatabase(filename, null, null)
        #else
        let flags = readonly ? SQLITE_OPEN_READONLY : (SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE)
        try check(resultOf: sqlite3_open_v2(filename, &_handle, flags | SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_URI, nil))
        #endif
    }

    // FIXME: no deinit support in Kotlin (“Unknown declaration (failed to translate SwiftSyntax node).”)
    #if os(Android)

    #else
    deinit {
        close()
    }
    #endif

    /// Closes the connection to the database
    func close() {
        if !closed {
            #if os(Android)
            self.db.close()
            #else
            sqlite3_close(handle)
            #endif
            closed = true
        }
    }

    /// Executes a single SQL statement.
    public func execute(sql: String, params: [SQLValue] = []) throws {
        #if os(Android)
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

    #if os(Android)

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

    #if os(Android)

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


#if os(Android)

#else
// let SQLITE_STATIC = unsafeBitCast(0, sqlite3_destructor_type.self)
let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
#endif

public enum SQLValue {
    case null
    case text(string: String)
    case integer(int: Int64)
    case float(double: Double)
    case blob(data: Data)

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

/// The type of a SQLite colums
public enum ColumnType : Int32 {
    /// `SQLITE_NULL`
    case null = 0
    /// `SQLITE_INTEGER`
    case integer = 1
    /// `SQLITE_FLOAT`
    case float = 2
    /// `SQLITE_TEXT`
    case text = 3
    /// `SQLITE_BLOB`
    case blob = 4
}

/// A cursor to the open result set returned by `Connection.query`.
public final class Cursor {
    fileprivate let connection: Connection

    #if os(Android)
    fileprivate var cursor: android.database.Cursor
    #else
    typealias Handle = OpaquePointer
    fileprivate var handle: Handle?
    #endif

    /// Whether the cursor is closed or not
    public private(set) var closed = false

    fileprivate init(_ connection: Connection, _ SQL: String, params: [SQLValue]) throws {
        self.connection = connection

//        func bindArgString(param: SQLValue) -> String? {
//            return param.toBindArg().flatMap {
//                "\($0)"
//            }
//        }
        
        #if os(Android)
        let bindArgs = params.map { $0.toBindArg() }
        var bindArgStrings: [String] = []
//        bindArgStrings = bindArgs.map { $0?.description as String? }
//        for arg in bindArgs {
//            bindArgStrings.append("")
//        }
        //bindArgStrings = bindArgs.map { $0!.description } // “error: Unable to get closure type (failed to translate SwiftSyntax node).”
        self.cursor = connection.db.rawQuery(SQL, bindArgStrings.toTypedArray())
        #else
        try connection.check(resultOf: sqlite3_prepare_v2(connection.handle, SQL, -1, &handle, nil))
        for (index, param) in params.enumerated() {
            try connection.bind(handle: self.handle, parameter: param, index: .init(index + 1))
        }
        #endif
    }


    var columnCount: Int32 {
        #if os(Android)
        self.cursor.getColumnCount()
        #else
        sqlite3_column_count(handle)
        #endif
    }

    /// Moves to the next row in the result set, returning `false` if there are no more rows to traverse.
    func next() throws -> Bool {
        #if os(Android)
        self.cursor.moveToNext()
        #else
        try connection.check(resultOf: sqlite3_step(handle)) == SQLITE_ROW
        #endif
    }

    /// Returns the name of the column at the given zero-based index.
    public func getColumnName(column: Int32) -> String {
        #if os(Android)
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

    /// Returns the values of the current row
    public func getRowValues() -> [SQLValue] {
        return (0..<columnCount).map { column in
            switch getColumnType(column: column) {
            case .null:
                return .null
            case .text:
                return .text(string: getString(column: column))
            case .integer:
                return .integer(int: getInt64(column: column))
            case .float:
                return .float(double: getDouble(column: column))
            case .blob:
                return .null // .blob(data: getBlob(column: column)) // introduces compile error w/ Gryphon: “error: Unable to get closure type (failed to translate SwiftSyntax node).”
            default:
                return .null
            }
        }
    }

    /// Steps to the next row and returns all the values in the row.
    /// - Parameter close: if true, closes the cursor after returning the values; this can be useful for single-shot execution of queries where only a single row is expected.
    /// - Returns: an array of ``SQLValue`` containing the row contents.
    public func nextRow(close: Bool = false) throws -> [SQLValue]? {
        if try next() {
            let values = getRowValues()
            if close {
                try self.close()
            }
            return values
        } else {
            try self.close()
            return nil
        }
    }

    public func getDouble(column: Int32) -> Double {
        #if os(Android)
        self.cursor.getDouble(column)
        #else
        sqlite3_column_double(handle, column)
        #endif
    }

    public func getInt64(column: Int32) -> Int64 {
        #if os(Android)
        self.cursor.getLong(column)
        #else
        sqlite3_column_int64(handle, column)
        #endif
    }

    public func getString(column: Int32) -> String {
        #if os(Android)
        self.cursor.getString(column)
        #else
        String(cString: UnsafePointer(sqlite3_column_text(handle, Int32(column))))
        #endif
    }

    public func getBlob(column: Int32) -> Data {
        #if os(Android)
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
        #if os(Android)
        self.cursor.getType(column)
        #else
        sqlite3_column_type(handle, column)
        #endif
    }

    func close() throws {
        if !closed {
            #if os(Android)
            self.cursor.close()
            #else
            try connection.check(resultOf: sqlite3_finalize(handle))
            #endif
        }
        closed = true
    }

    #if os(Android)
    // TODO: finalize { close() }
    #else
    deinit {
        try? close()
    }
    #endif
}


// MARK: Random

/// A cross-platform random number generator
public class Random {
    #if os(Android)
    //let random: java.util.Random = java.util.Random()
    let random: java.util.Random = java.security.SecureRandom()
    #else
    var rng: RandomNumberGenerator = SystemRandomNumberGenerator()
    #endif

    public func randomDouble() -> Double {
        #if os(Android)
        // Returns the next pseudorandom, uniformly distributed double value between 0.0 and 1.0 from this random number generator's sequence.
        // The general contract of nextDouble is that one double value, chosen (approximately) uniformly from the range 0.0d (inclusive) to 1.0d (exclusive), is pseudorandomly generated and returned.
        return random.nextDouble()
        #else
        return Double.random(in: 0..<1, using: &rng)
        #endif
    }
}

// MARK: URL

#if os(Android)
public typealias URL = java.net.URL
#else
import struct Foundation.URL

extension URL {
    /// Convenience init to match java.net.URL string constructor.
    public init!(_ stringURL: String) {
        self.init(string: stringURL)
    }
}
#endif

// MARK: Data

#if os(Android)
public typealias Data = kotlin.ByteArray

extension Data {
    /// Foundation uses `count`, Java uses `size`.
    public var count: Int { size }
}

/// Reads the data from the given file
public func readData(fromPath filePath: String) throws -> Data {
    java.io.File(filePath).readBytes()
}

#else
import struct Foundation.Data

/// Reads the data from the given file
public func readData(fromPath filePath: String) throws -> Data {
    try Data(contentsOf: URL(fileURLWithPath: filePath, isDirectory: false))
}

#endif

// MARK: FileManager

#if os(Android)
/// An interface to the file system compatible with ``Foundation.FileManager``
public final class FileManager {
    public static let `default` = FileManager()

    private init() {
    }

    public func removeItem(atPath path: String) throws {
        if java.io.File(path).delete() != true {
            throw UnableToDeleteFileError(path: path)
        }
    }

    struct UnableToDeleteFileError : java.io.IOException {
        let path: String
    }
}
#else
import class Foundation.FileManager

public extension FileManager {
    @available(*, deprecated, message: "file URLs not yet implemented on Kotlin side")
    func removeItem(at url: URL) throws {
        fatalError("unavailable in Kotlin")
        //try self.removeItem(at: url)
    }

}
#endif


// Alternate data solution: wrapping it in a custom type

// A Foundation-compatible Data.
//public class Data : Hashable {
//    let bytes: ByteArray
//    public init(bytes: ByteArray) {
//        self.bytes = bytes
//    }
//}



// MARK: Utilities

func dbg(_ value: String) {
    #if os(Android)
    System.out.println("DEBUG Kotlin: " + value)
    #else
    print("DEBUG Swift:", value)
    #endif
}

// MARK: JSON

/// A JSON type, which can be null, boolean, number, string, array, or object.
enum JSON {
    case nul
    case bol(boolean: Bool)
    case num(number: Double)
    case str(string: String)
    case arr(array: [JSON])
    case obj(dictionary: [String: JSON])
}

// MARK: Unconditional Swift/Kotlin

extension Connection {
    static func demoDatabase() throws {
        let rnd = Random().randomDouble()
        //let rnd = Double.random(in: 0..<1)

        let dbname = "/tmp/demosql_\(rnd).db"

        dbg("connecting to: " + dbname)
        let conn = try Connection(dbname)

//        assert(try! conn.query(sql: "SELECT 1").nextRow(close: true)?.first?.integerValue == 1)
//        assert(try! conn.query(sql: "SELECT 1.0").nextRow(close: true)?.first?.floatValue == 1.0)
//        assert(try! conn.query(sql: "SELECT 'ABC'").nextRow(close: true)?.first?.textValue == "ABC")

        try conn.execute(sql: "CREATE TABLE FOO(NAME VARCHAR, NUM INTEGER, DBL FLOAT)")
        for i in 1...10 {
            try conn.execute(sql: "INSERT INTO FOO VALUES(?, \(i), \(i))", params: [.text(string: i.description)])
        }


        let cursor = try conn.query(sql: "SELECT * FROM FOO")
        let colcount = cursor.columnCount
        dbg("columns: \(colcount)")
        assert(colcount == 3)

        var row = 0
        while try cursor.next() {
            row += 1
            assert(cursor.getColumnName(column: 0) == "NAME")
            assert(cursor.getColumnType(column: 0) == .text)
            assert(cursor.getString(column: 0) == "\(row)")

            assert(cursor.getColumnName(column: 1) == "NUM")
            assert(cursor.getColumnType(column: 1) == .integer)
            assert(cursor.getInt64(column: 1) == /* gryphon value: row.toLong() */ Int64(row))

            assert(cursor.getColumnName(column: 2) == "DBL")
            assert(cursor.getColumnType(column: 2) == .float)
            assert(cursor.getDouble(column: 2) == Double(row))
        }

        try cursor.close()
        assert(cursor.closed == true)

        try conn.execute(sql: "DROP TABLE FOO")

        conn.close()
        assert(conn.closed == true)

        let dataFile: Data = try readData(fromPath: dbname)
        assert(dataFile.count > 1024) // 8192 on Darwin, 12288 for Android

        // 'removeItem(at:)' is deprecated: URL paths not yet implemented in Kotlin
        //try FileManager.default.removeItem(at: URL(fileURLWithPath: dbname, isDirectory: false))

        try FileManager.default.removeItem(atPath: dbname)
    }
}

extension Connection {
    static func demoDatabaseAsync() async throws {
        dbg("ASYNC TEST")
        // FIXME: not really async
        // let url: URL = URL("https://www.example.org")

        // let session = URLSession.shared
        // let contents = try await session.fetch(url: url)

        //let contents: String = try String(from: url)

        //assert(contents.contains("Example Domain"))
    }
}

