package CrossSQL

import android.database.*
import android.database.sqlite.*

class Connection {
    companion object {
        internal fun demoDatabase() {
            fun debug(value: String) {
                System.out.println("DEBUG Kotlin: " + value)
            }

            val rnd: Int = Random().randomInt()
            val dbname: String = "/tmp/demosql_${rnd}.db"
            val conn: Connection = Connection(filename = dbname)

            conn.execute(sql = "CREATE TABLE FOO(NAME VARCHAR)")
            conn.close()
        }
    }

    val db: SQLiteDatabase

    constructor(filename: String, readonly: Boolean = false) {
        this.db = SQLiteDatabase.openOrCreateDatabase(filename, null, null)
    }

    internal open fun close() {
        this.db.close()
    }

    // FIXME: no deinit support (“Unknown declaration (failed to translate SwiftSyntax node).”)
    // deinit {
    //    close()
    // }
    internal open fun execute(sql: String) {
        db.execSQL(sql)
    }
}

open class Random {
    internal val random: java.util.Random = java.util.Random()

    open fun randomInt(): Int {
        return Math.abs(random.nextInt())
    }
}
