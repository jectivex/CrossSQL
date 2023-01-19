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
    public let db: SQLiteDatabase
    #else
    public var handle: OpaquePointer { _handle! }
    fileprivate var _handle: OpaquePointer?
    #endif

    public init(_ filename: String, readonly: Bool = false) throws {
        #if KOTLIN
        self.db = SQLiteDatabase.openOrCreateDatabase(filename, null, null)
        #else
        let flags = readonly ? SQLITE_OPEN_READONLY : (SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE)
        try check(sqlite3_open_v2(filename, &_handle, flags | SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_URI, nil))
        #endif
    }

    func close() {
        #if KOTLIN
        self.db.close()
        #else
        sqlite3_close(handle)
        #endif
    }

    // FIXME: no deinit support (“Unknown declaration (failed to translate SwiftSyntax node).”)
    // deinit {
    //    close()
    // }

    func execute(sql: String) throws {
        #if KOTLIN
        db.execSQL(sql)
        #else
        try check(sqlite3_exec(handle, sql, nil, nil, nil))
        #endif
    }

    #if KOTLIN

    #else
    @discardableResult func check(_ resultCode: Int32) throws -> Int32 {
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

    static func demoDatabase() throws {
        func debug(_ value: String) {
            #if KOTLIN
            System.out.println("DEBUG Kotlin: " + value)
            #else
            print("DEBUG Swift:", value)
            #endif
        }

        let rnd = Random().randomInt()
        let dbname = "/tmp/demosql_\(rnd).db"
        let conn = try Connection(dbname)
        try conn.execute(sql: "CREATE TABLE FOO(NAME VARCHAR)")
        conn.close()
    }
}

/// A cross-platform random number generator
public class Random {
    #if KOTLIN
    let random: java.util.Random = java.util.Random()
    #else
    var rng = SystemRandomNumberGenerator()
    #endif

    public func randomInt() -> Int {
        #if KOTLIN
        return Math.abs(random.nextInt())
        #else
        return abs(Int.random(in: (.min)...(.max), using: &rng))
        #endif
    }
}
