package CrossSQL

import java.util.*

open class Connection {
    constructor() {
    }

    open fun connect(path: String): Boolean {
        return true
    }

    internal open fun demoDatabase() {
        System.out.println("### TESTING DATABASE")

        //print("###")
        //typealias SQLiteDatabase = android.database.sqlite.SQLiteDatabase // “CrossSQL.kt: (17, 9): Nested and local type aliases are not supported”
        val db: android.database.sqlite.SQLiteDatabase = android.database.sqlite.SQLiteDatabase.openOrCreateDatabase("/tmp/sql.db", null, null)

        //        let cursor = db.rawQuery("select * from android_metadata", null)
        //        while cursor.moveToNext() {
        //            let str = cursor.getString(0)
        //            assertEquals("en_US", str)
        //        }
        //        cursor.close()
        //        db.close()
        System.out.println("### DONE TESTING DATABASE")
    }
}
