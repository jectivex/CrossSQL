#if GRYPHON
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
        #if GRYPHON
        return true
        #else
        return false
        #endif
    }

    func demoDatabase() throws {
        #if GRYPHON
        System.out.println("### TESTING DATABASE")
        //print("###")
        //typealias SQLiteDatabase = android.database.sqlite.SQLiteDatabase // “CrossSQL.kt: (17, 9): Nested and local type aliases are not supported”
        let db: android.database.sqlite.SQLiteDatabase = android.database.sqlite.SQLiteDatabase.openOrCreateDatabase("/tmp/sql.db", null, null)

//        let cursor = db.rawQuery("select * from android_metadata", null)
//        while cursor.moveToNext() {
//            let str = cursor.getString(0)
//            assertEquals("en_US", str)
//        }

        
//        cursor.close()
//        db.close()
        System.out.println("### DONE TESTING DATABASE")
        #else
        #endif
    }

}
