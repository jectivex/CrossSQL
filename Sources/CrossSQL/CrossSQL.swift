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
    #if KOTLIN
    public let db: android.database.sqlite.SQLiteDatabase
    #else
    public var handle: OpaquePointer { _handle! }
    fileprivate var _handle: OpaquePointer?
    #endif

    /// Whether the connection to the database is closed or not
    public private(set) var closed = false

    public init(_ filename: String, readonly: Bool = false) throws {
        #if KOTLIN
        self.db = SQLiteDatabase.openOrCreateDatabase(filename, null, null)
        #else
        let flags = readonly ? SQLITE_OPEN_READONLY : (SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE)
        try check(sqlite3_open_v2(filename, &_handle, flags | SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_URI, nil))
        #endif
    }

    // FIXME: no deinit support in Kotlin (“Unknown declaration (failed to translate SwiftSyntax node).”)
    #if KOTLIN

    #else
    deinit {
        close()
    }
    #endif

    /// Closes the connection to the database
    func close() {
        if !closed {
            #if KOTLIN
            self.db.close()
            #else
            sqlite3_close(handle)
            #endif
            closed = true
        }
    }

    /// Executes a single SQL statement.
    public func execute(sql: String) throws {
        #if KOTLIN
        db.execSQL(sql)
        #else
        try check(sqlite3_exec(handle, sql, nil, nil, nil))
        #endif
    }

    #if KOTLIN

    #else
    @discardableResult fileprivate func check(_ resultCode: Int32) throws -> Int32 {
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
    public func query(sql: String, params: [String] = []) throws -> Cursor {
        try Cursor(self, sql, params: params)
    }

    // some random static function is needed to get Gryphon to generate a Companion object to extend (below)
    private static func noop() throws {
    }
}


#if KOTLIN

#else
// let SQLITE_STATIC = unsafeBitCast(0, sqlite3_destructor_type.self)
let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
#endif

/// A cursor to the open result set returned by `Connection.query`.
public final class Cursor {
    fileprivate let connection: Connection

    #if KOTLIN
    fileprivate var cursor: android.database.Cursor
    #else
    fileprivate var handle: OpaquePointer?
    #endif

    /// Whether the cursor is closed or not
    public private(set) var closed = false

    fileprivate init(_ connection: Connection, _ SQL: String, params: [String]) throws {
        self.connection = connection

        #if KOTLIN
        //self.statement = connection.db.compileStatement(SQL)
        self.cursor = connection.db.rawQuery(SQL, params.toTypedArray())
        #else
        try connection.check(sqlite3_prepare_v2(connection.handle, SQL, -1, &handle, nil))
        for (index, param) in params.enumerated() {
            try bind(parameter: .text(string: param), index: .init(index))
        }
        #endif
    }


    #if KOTLIN

    #else
    /// Binds the given parameter at the given index.
    private func bind(parameter: SQLValue, index: Int32) throws {
        switch parameter {
        case .null:
            try connection.check(sqlite3_bind_null(handle, Int32(index)))
        case let .text(string: string):
            try connection.check(sqlite3_bind_text(handle, Int32(index), string, -1, SQLITE_TRANSIENT))
//        case let value as Blob where value.bytes.count == 0:
//            try connection.check(sqlite3_bind_zeroblob(handle, Int32(idx), 0))
//        case let value as Blob:
//            try connection.check(sqlite3_bind_blob(handle, Int32(idx), value.bytes, Int32(value.bytes.count), SQLITE_TRANSIENT))
//        case let value as Double:
//            try connection.check(sqlite3_bind_double(handle, Int32(idx), value))
//        case let value as Int64:
//            try connection.check(sqlite3_bind_int64(handle, Int32(idx), value))
        }
    }
    #endif

    public enum SQLValue {
        case null
        case text(string: String)

        var columnType: ColumnType {
            switch self {
            case .null:
                return ColumnType.null
            case let .text(string: _): // case label is needed by Gryphon
                return ColumnType.text
            default: // needed for Kotlin when mixed associated type w/ empty enum
                return ColumnType.null
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

    var columnCount: Int {
        #if KOTLIN
        self.cursor.getColumnCount()
        #else
        Int(sqlite3_column_count(handle))
        #endif
    }

    /// Moves to the next row in the result set, returning `false` if there are no more rows to traverse.
    func next() throws -> Bool {
        #if KOTLIN
        self.cursor.moveToNext()
        #else
        try connection.check(sqlite3_step(handle)) == SQLITE_ROW
        #endif
    }

    /// Returns the name of the column at the given zero-based index.
    public func getColumnName(column: Int32) -> String {
        #if KOTLIN
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

    public func getDouble(column: Int32) -> Double {
        #if KOTLIN
        self.cursor.getDouble(column)
        #else
        sqlite3_column_double(handle, column)
        #endif
    }

    public func getInt64(column: Int32) -> Int64 {
        #if KOTLIN
        self.cursor.getLong(column)
        #else
        sqlite3_column_int64(handle, column)
        #endif
    }

    public func getString(column: Int32) -> String {
        #if KOTLIN
        self.cursor.getString(column)
        #else
        String(cString: UnsafePointer(sqlite3_column_text(handle, Int32(column))))
        #endif
    }

    public func getBlob(column: Int32) -> Data {
        #if KOTLIN
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
        #if KOTLIN
        self.cursor.getType(column)
        #else
        sqlite3_column_type(handle, column)
        #endif
    }

    func close() {
        if !closed {
            #if KOTLIN
            self.cursor.close()
            #else
            sqlite3_finalize(handle)
            #endif
        }
        closed = true
    }

    #if KOTLIN

    #else
    deinit {
        close()
    }
    #endif
}


// MARK: Random

/// A cross-platform random number generator
public class Random {
    #if KOTLIN
    //let random: java.util.Random = java.util.Random()
    let random: java.util.Random = java.security.SecureRandom()
    #else
    var rng: RandomNumberGenerator = SystemRandomNumberGenerator()
    #endif

    public func randomDouble() -> Double {
        #if KOTLIN
        // Returns the next pseudorandom, uniformly distributed double value between 0.0 and 1.0 from this random number generator's sequence.
        // The general contract of nextDouble is that one double value, chosen (approximately) uniformly from the range 0.0d (inclusive) to 1.0d (exclusive), is pseudorandomly generated and returned.
        return random.nextDouble()
        #else
        return Double.random(in: 0..<1, using: &rng)
        #endif
    }
}

// MARK: URL

#if KOTLIN
public typealias URL = java.net.URL
#else
import struct Foundation.URL
#endif

// MARK: Data

#if KOTLIN
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

#if KOTLIN
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
    #if KOTLIN
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

        try conn.execute(sql: "CREATE TABLE FOO(NAME VARCHAR, NUM INTEGER)")
        for i in 1...10 {
            try conn.execute(sql: "INSERT INTO FOO VALUES('\(i)', \(i))")
        }

        let cursor = try conn.query(sql: "SELECT * FROM FOO")
        let colcount = cursor.columnCount
        dbg("columns: \(colcount)")
        assert(colcount == 2)

        while try cursor.next() {
            assert(cursor.getColumnName(column: 0) == "NAME")
            assert(cursor.getColumnType(column: 0) == .text)
            assert(cursor.getColumnName(column: 1) == "NUM")
            assert(cursor.getColumnType(column: 1) == .integer)
        }

        cursor.close()
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
