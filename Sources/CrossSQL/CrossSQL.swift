#if KOTLIN
// gryphon insert: import java.util.*
#else
#if os(Linux)
import CSQLite
#else
import SQLite3
#endif
#endif

public class Connection {

    public init() throws {
    }

    /// Returns true if he file at the given path exists.
    public func connect(path: String) throws -> Bool {
        #if KOTLIN
        return true
        #else
        return false
        #endif
    }

    func demoDatabase() throws {
        func debug(_ value: String) {
            #if KOTLIN
            System.out.println("DEBUG Kotlin: " + value)
            #else
            print("DEBUG Swift:", value)
            #endif
        }

        debug("DEMO DATABASE")

        #if KOTLIN
        //print("###")
        //typealias SQLiteDatabase = android.database.sqlite.SQLiteDatabase // “CrossSQL.kt: (17, 9): Nested and local type aliases are not supported”
        let db: android.database.sqlite.SQLiteDatabase = android.database.sqlite.SQLiteDatabase.openOrCreateDatabase("/tmp/sql.db", null, null)

        let cursor: android.database.Cursor = db.rawQuery("select * from android_metadata", null)
        while cursor.moveToNext() {
            let str: kotlin.String = cursor.getString(0)
            //assertEquals("en_US", str)
            debug("READ STRING: " + str)
        }

        cursor.close()
        db.close()
        #else

        // TODO: Swift version
        sqlite3_open("/tmp/sql.db", nil)
        #endif

        debug("DONE DEMO DATABASE")
    }
}
