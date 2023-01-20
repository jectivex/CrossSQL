package CrossSQL

import android.database.*
import android.database.sqlite.*

class Connection {
    companion object {
        internal fun demoDatabase() {
            val rnd: Double = Random().randomDouble()
            val dbname: String = "/tmp/demosql_${rnd}.db"

            dbg(value = "connecting to: " + dbname)

            val conn: Connection = Connection(filename = dbname)

            conn.execute(sql = "CREATE TABLE FOO(NAME VARCHAR, NUM INTEGER)")

            for (i in 1..10) {
                conn.execute(sql = "INSERT INTO FOO VALUES('${i}', ${i})")
            }

            assert(conn.query(sql = "SELECT 1").columnCount == 1)

            val cursor: Cursor = conn.query(sql = "SELECT * FROM FOO")
            val colcount: Int = cursor.columnCount

            dbg(value = "columns: ${colcount}")
            assert(colcount == 2)

            while (cursor.next()) {
                assert(cursor.getColumnName(column = 0) == "NAME")
                assert(cursor.getColumnType(0) == Cursor.ColumnType.TEXT)
                assert(cursor.getColumnName(column = 1) == "NUM")
                assert(cursor.getColumnType(1) == Cursor.ColumnType.INTEGER)
            }

            assert(cursor.closed == false)
            cursor.close()
            assert(cursor.closed == true)
            conn.execute(sql = "DROP TABLE FOO")
            assert(conn.closed == false)
            conn.close()
            assert(conn.closed == true)
            FileManager.default.removeItem(path = dbname)
        }
    }

    val db: android.database.sqlite.SQLiteDatabase
    open var closed: Boolean = false

    constructor(filename: String, readonly: Boolean = false) {
        this.db = SQLiteDatabase.openOrCreateDatabase(filename, null, null)
    }

    // FIXME: no deinit support in Kotlin (“Unknown declaration (failed to translate SwiftSyntax node).”)
    internal open fun close() {
        if (!closed) {
            this.db.close()
            closed = true
        }
    }

    open fun execute(sql: String) {
        db.execSQL(sql)
    }

    internal open fun query(sql: String, params: List<String> = listOf()): Cursor = Cursor(connection = this, SQL = sql, params = params)
}

class Cursor {
    internal val connection: Connection
    internal open var cursor: android.database.Cursor
    open var closed: Boolean = false

    internal constructor(connection: Connection, SQL: String, params: List<String>) {
        this.connection = connection
        //self.statement = connection.db.compileStatement(SQL)
        this.cursor = connection.db.rawQuery(SQL, params.toTypedArray())
    }

    enum class ColumnType(val rawValue: Int) {
        NULL(rawValue = 0),
        INTEGER(rawValue = 1),
        FLOAT(rawValue = 2),
        TEXT(rawValue = 3),
        BLOB(rawValue = 4);

        companion object {
            operator fun invoke(rawValue: Int): ColumnType? = values().firstOrNull { it.rawValue == rawValue }
        }
    }

    internal open val columnCount: Int
        get() = this.cursor.getColumnCount()

    internal open fun next(): Boolean = this.cursor.moveToNext()

    open fun getColumnName(column: Int): String = this.cursor.getColumnName(column)

    open fun getColumnType(column: Int): ColumnType {
        //return ColumnType(rawValue: getTypeConstant(column: column))
        return when (getTypeConstant(column = column)) {
            ColumnType.NULL.rawValue -> ColumnType.NULL
            ColumnType.INTEGER.rawValue -> ColumnType.INTEGER
            ColumnType.FLOAT.rawValue -> ColumnType.FLOAT
            ColumnType.TEXT.rawValue -> ColumnType.TEXT
            ColumnType.BLOB.rawValue -> ColumnType.BLOB
            else -> ColumnType.NULL
        }
    }

    open fun getDouble(column: Int): Double = this.cursor.getDouble(column)

    open fun getInt64(column: Int): Long = this.cursor.getLong(column)

    open fun getString(column: Int): String = this.cursor.getString(column)

    open fun getBlob(column: Int): Data {
        return this.cursor.getBlob(column)
    }

    private fun getTypeConstant(column: Int): Int = this.cursor.getType(column)

    internal open fun close() {
        if (!closed) {
            this.cursor.close()
        }
        closed = true
    }
}

internal fun dbg(value: String) {
    System.out.println("DEBUG Kotlin: " + value)
}

open class Random {
    //let random: java.util.Random = java.util.Random()
    internal val random: java.util.Random = java.security.SecureRandom()

    open fun randomDouble(): Double {
        // Returns the next pseudorandom, uniformly distributed double value between 0.0 and 1.0 from this random number generator's sequence.
        // The general contract of nextDouble is that one double value, chosen (approximately) uniformly from the range 0.0d (inclusive) to 1.0d (exclusive), is pseudorandomly generated and returned.
        return random.nextDouble()
    }
}

internal sealed class JSum {
    class Nul: JSum()
    class Bol(val bol: Boolean): JSum()
    class Num(val num: Double): JSum()
    class Str(val str: String): JSum()
    class Arr(val arr: List<JSum>): JSum()
    class Obj(val obj: Map<String, JSum>): JSum()
}

typealias Data = kotlin.ByteArray

// A Foundation-compatible Data.
//public class Data : Hashable {
//    let bytes: ByteArray
//    public init(bytes: ByteArray) {
//        self.bytes = bytes
//    }
//}
open class FileManager {
    companion object {
        val `default`: FileManager = FileManager()
    }

    private constructor() {
    }

    open fun removeItem(path: String) {
        if (java.io.File(path).delete() != true) {
            throw UnableToDeleteFileError(path)
        }
    }

    internal data class UnableToDeleteFileError(
        val path: String
    ): Exception()
}
