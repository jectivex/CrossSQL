package CrossSQL

import java.util.*

open class Connection {
    constructor() {
    }

    open fun connect(path: String): Boolean {
        return true
    }

    internal open fun demoDatabase() {
        fun debug(value: String) {
            System.out.println("DEBUG Kotlin: " + value)
        }

        debug(value = "DEMO DATABASE")

        //print("###")
        //typealias SQLiteDatabase = android.database.sqlite.SQLiteDatabase // “CrossSQL.kt: (17, 9): Nested and local type aliases are not supported”
        val db: android.database.sqlite.SQLiteDatabase = android.database.sqlite.SQLiteDatabase.openOrCreateDatabase("/tmp/sql.db", null, null)
        val cursor: android.database.Cursor = db.rawQuery("select * from android_metadata", null)

        while (cursor.moveToNext()) {
            val str: kotlin.String = cursor.getString(0)
            //assertEquals("en_US", str)
            debug("READ STRING: " + str)
        }

        cursor.close()
        db.close()
        debug(value = "DONE DEMO DATABASE")
    }
}
