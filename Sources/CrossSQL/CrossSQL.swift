#if KOTLIN
// gryphon insert: import java.util.*
#else
import Foundation
import SQLite3
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
        #if KOTLIN
        System.out.println("### DEMO DATABASE")
        //print("###")
        //typealias SQLiteDatabase = android.database.sqlite.SQLiteDatabase // “CrossSQL.kt: (17, 9): Nested and local type aliases are not supported”
        let db: android.database.sqlite.SQLiteDatabase = android.database.sqlite.SQLiteDatabase.openOrCreateDatabase("/tmp/sql.db", null, null)

        let cursor: android.database.Cursor = db.rawQuery("select * from android_metadata", null)
        while cursor.moveToNext() {
            let str: kotlin.String = cursor.getString(0)
            //assertEquals("en_US", str)
            System.out.println("### READ STRING: " + str)
        }

        
        cursor.close()
        db.close()
        System.out.println("### DONE DEMO DATABASE")
        #else

        print("### TODO: Swift tests for database")
        
        #endif
    }

}
