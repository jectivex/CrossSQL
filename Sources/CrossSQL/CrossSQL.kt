package CrossSQL

import android.database.*
import android.database.sqlite.*
import CrossFoundation.*

class Connection {
    companion object {
        fun open(url: URL, readonly: Boolean = false): Connection = Connection(url.path, readonly)

        private fun noop() {
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

    open fun execute(sql: String, params: List<SQLValue> = listOf()) {
        val bindArgs: List<Any?> = params.map { it.toBindArg() }
        db.execSQL(sql, bindArgs.toTypedArray())
    }

    open fun query(sql: String, params: List<SQLValue> = listOf()): Cursor = Cursor(connection = this, SQL = sql, params = params)

    // some random static function is needed to get Gryphon to generate a Companion object to extend (below)
}

sealed class SQLValue {
    class Null: SQLValue()
    class Text(val string: String): SQLValue()
    class Integer(val int: Long): SQLValue()
    class Float(val double: Double): SQLValue()
    class Blob(val data: Data): SQLValue()

    internal val columnType: ColumnType
        get() {
            // warnings about let pattern with no effect and default bot needed works around Grphyon translation mixed associated type w/ empty enum
            return when (this) {
                is SQLValue.Null -> ColumnType.NULL
                is SQLValue.Text -> ColumnType.TEXT
                is SQLValue.Integer -> ColumnType.INTEGER
                is SQLValue.Float -> ColumnType.FLOAT
                is SQLValue.Blob -> ColumnType.BLOB
                else -> ColumnType.NULL
            }
        }

    fun toBindArg(): Any? {
        return when (this) {
            is SQLValue.Null -> null
            is SQLValue.Text -> {
                val str: String = this.string
                str
            }
            is SQLValue.Integer -> {
                val num: Long = this.int
                num
            }
            is SQLValue.Float -> {
                val dbl: Double = this.double
                dbl
            }
            is SQLValue.Blob -> {
                val bytes: Data = this.data
                bytes
            }
            else -> {
                // needed for Kotlin when mixed associated type w/ empty enum
                null
            }
        }
    }

    fun toBindString(): String? {
        return when (this) {
            is SQLValue.Null -> null
            is SQLValue.Text -> {
                val str: String = this.string
                str
            }
            is SQLValue.Integer -> {
                val num: Long = this.int
                num.toString()
            }
            is SQLValue.Float -> {
                val dbl: Double = this.double
                dbl.toString()
            }
            is SQLValue.Blob -> {
                val bytes: Data = this.data
                null
            }
            else -> {
                // needed for Kotlin when mixed associated type w/ empty enum
                null
            }
        }
    }

    internal val textValue: String?
        get() {
            return when (this) {
                is SQLValue.Text -> {
                    val str: String = this.string
                    str
                }
                else -> null
            }
        }
    internal val integerValue: Long?
        get() {
            return when (this) {
                is SQLValue.Integer -> {
                    val num: Long = this.int
                    num
                }
                else -> null
            }
        }
    internal val floatValue: Double?
        get() {
            return when (this) {
                is SQLValue.Float -> {
                    val dbl: Double = this.double
                    dbl
                }
                else -> null
            }
        }
    internal val blobValue: Data?
        get() {
            return when (this) {
                is SQLValue.Blob -> {
                    val dat: Data = this.data
                    dat
                }
                else -> null
            }
        }
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

    internal val isNumeric: Boolean
        get() {
            return when (this) {
                ColumnType.INTEGER -> true
                ColumnType.FLOAT -> true
                else -> false
            }
        }
}

class Cursor {
    internal val connection: Connection
    internal open var cursor: android.database.Cursor
    open var closed: Boolean = false

    internal constructor(connection: Connection, SQL: String, params: List<SQLValue>) {
        this.connection = connection
        val bindArgs: List<String?> = params.map { it.toBindString() }
        this.cursor = connection.db.rawQuery(SQL, bindArgs.toTypedArray())
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

    open fun getValue(column: Int): SQLValue {
        return when (getColumnType(column = column)) {
            ColumnType.NULL -> SQLValue.Null()
            ColumnType.TEXT -> SQLValue.Text(getString(column = column))
            ColumnType.INTEGER -> SQLValue.Integer(getInt64(column = column))
            ColumnType.FLOAT -> SQLValue.Float(getDouble(column = column))
            ColumnType.BLOB -> SQLValue.Null()
            else -> SQLValue.Null()
        }
    }

    open fun getRow(): List<SQLValue> {
        return (0 until columnCount).map({ column -> getValue(column = column) })
    }

    open fun rowText(header: Boolean = false, values: Boolean = false, width: Int = 80): String {
        var str: String = ""
        val sep: String = if (header == false && values == false) { "+" } else { "|" }

        str += sep

        val count: Int = columnCount
        var cellSpan: Int = (width / count) - 2

        if (cellSpan < 0) {
            cellSpan = 0
            cellSpan = 0
        }

        for (col in 0 until count) {
            val i: Int = col
            val cell: String

            if (header) {
                cell = getColumnName(column = i)
            }
            else if (values) {
                cell = getValue(column = i).toBindString() ?: ""
            }
            else {
                cell = ""
            }

            val numeric: Boolean = if (header || values) { getColumnType(column = i).isNumeric } else { false }
            val padding: String = if (header || values) { " " } else { "-" }

            str += padding

            str += cell.pad(cellSpan - 2, padding, numeric)

            str += padding

            if (col < count - 1) {
                str += sep
            }
        }

        str += sep

        return str
    }

    open fun singleValue(): SQLValue? = nextRow(close = true)?.firstOrNull()

    open fun nextRow(close: Boolean = false): List<SQLValue>? {
        try {
            if (next() == false) {
                this.close()
                return null
            }
            else {
                val values: List<SQLValue> = getRow()
                if (close) {
                    this.close()
                }
                return values
            }
        }
        catch (error: Exception) {
            this.close()
            throw error
        }
    }

    open fun getDouble(column: Int): Double = this.cursor.getDouble(column)

    open fun getInt64(column: Int): Long = this.cursor.getLong(column)

    open fun getString(column: Int): String = this.cursor.getString(column)

    open fun getBlob(column: Int): Data {
        return Data(this.cursor.getBlob(column))
    }

    private fun getTypeConstant(column: Int): Int = this.cursor.getType(column)

    internal open fun close() {
        if (!closed) {
            this.cursor.close()
        }
        closed = true
    }

    // TODO: finalize { close() }
}

fun Connection.Companion.testDatabase() {
    // FIXME: cannot determine type
    //let random: Random = Random.shared
    //let rnd: Double = (random as Random).randomDouble()
    val rnd: Int = 1
    val dbname: String = "/tmp/demosql_${rnd}.db"

    dbg("connecting to: " + dbname)

    val conn: Connection = Connection(filename = dbname)

    assert(conn.query(sql = "SELECT 1.0").nextRow(close = true)?.firstOrNull()?.floatValue == 1.0)
    assert(conn.query(sql = "SELECT 'ABC'").nextRow(close = true)?.firstOrNull()?.textValue == "ABC")
    assert(
        conn.query(sql = "SELECT lower('ABC')").nextRow(close = true)?.firstOrNull()?.textValue == "abc")
    assert(
        conn.query(sql = "SELECT 3.0/2.0, 4.0*2.5").nextRow(close = true)?.lastOrNull()?.floatValue == 10.0)
    assert(
        conn.query(sql = "SELECT ?", params = listOf(SQLValue.Text("ABC"))).nextRow(close = true)?.firstOrNull()?.textValue == "ABC")
    assert(
        conn.query(
                sql = "SELECT upper(?), lower(?)",
                params = listOf(SQLValue.Text("ABC"), SQLValue.Text("XYZ"))).nextRow(
                close = true)?.lastOrNull()?.textValue == "xyz")

    // compiles but AssertionError in Kotlin
    // Kotlin error: “Operator '==' cannot be applied to 'Long?' and 'Int'”
    try {
        conn.execute(sql = "DROP TABLE FOO")
    }
    catch (_error: Exception) {
        // exception expected when re-running on existing database
    }

    conn.execute(sql = "CREATE TABLE FOO(NAME VARCHAR, NUM INTEGER, DBL FLOAT)")

    for (i in 1..10) {
        conn.execute(
            sql = "INSERT INTO FOO VALUES(?, ?, ?)",
            params = listOf(SQLValue.Text("NAME_" + i.toString()), SQLValue.Integer(i.toLong()), SQLValue.Float(i.toDouble())))
    }

    val cursor: Cursor = conn.query(sql = "SELECT * FROM FOO")
    val colcount: Int = cursor.columnCount

    dbg("columns: ${colcount}")
    assert(colcount == 3)

    var row: Int = 0
    val consoleWidth: Int = 45

    while (cursor.next()) {
        if (row == 0) {
            // header and border rows
            dbg(cursor.rowText(false, false, consoleWidth))
            dbg(cursor.rowText(true, false, consoleWidth))
            dbg(cursor.rowText(false, false, consoleWidth))
        }

        dbg(cursor.rowText(false, true, consoleWidth))

        row += 1

        assert(cursor.getColumnName(column = 0) == "NAME")
        assert(cursor.getColumnType(column = 0) == ColumnType.TEXT)
        assert(cursor.getString(column = 0) == "NAME_${row}")
        assert(cursor.getColumnName(column = 1) == "NUM")
        assert(cursor.getColumnType(column = 1) == ColumnType.INTEGER)
        assert(cursor.getInt64(column = 1) == row.toLong())
        assert(cursor.getColumnName(column = 2) == "DBL")
        assert(cursor.getColumnType(column = 2) == ColumnType.FLOAT)
        assert(cursor.getDouble(column = 2) == row.toDouble())
    }

    dbg(cursor.rowText(false, false, consoleWidth))
    cursor.close()
    assert(cursor.closed == true)
    conn.execute(sql = "DROP TABLE FOO")
    conn.close()
    assert(conn.closed == true)

    // .init not being resolved for some reason…
    // let dataFile: Data = try Data.init(contentsOfFile: dbname)
    // assert(dataFile.count > 1024) // 8192 on Darwin, 12288 for Android
    // 'removeItem(at:)' is deprecated: URL paths not yet implemented in Kotlin
    //try FileManager.default.removeItem(at: URL(fileURLWithPath: dbname, isDirectory: false))
    FileManager.default.removeItem(dbname)
}
