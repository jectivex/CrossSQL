package CrossSQL

import android.database.*
import android.database.sqlite.*

class Connection {
    companion object {
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

    internal fun toBindArg(): Any? {
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

    internal fun toBindString(): String? {
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
            ColumnType.TEXT -> SQLValue.Text(string = getString(column = column))
            ColumnType.INTEGER -> SQLValue.Integer(int = getInt64(column = column))
            ColumnType.FLOAT -> SQLValue.Float(double = getDouble(column = column))
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

            str += cell.pad(cell = cell, cellSpan = cellSpan - 2, padding = padding, rightAlign = numeric)

            str += padding

            if (col < count - 1) {
                str += sep
            }
        }

        str += sep

        return str
    }

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
        return this.cursor.getBlob(column)
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

// MARK: Random
open class Random {
    //let random: java.util.Random = java.util.Random()
    internal val random: java.util.Random = java.security.SecureRandom()

    open fun randomDouble(): Double {
        // Returns the next pseudorandom, uniformly distributed double value between 0.0 and 1.0 from this random number generator's sequence.
        // The general contract of nextDouble is that one double value, chosen (approximately) uniformly from the range 0.0d (inclusive) to 1.0d (exclusive), is pseudorandomly generated and returned.
        return random.nextDouble()
    }
}

internal fun String.pad(
    cell: String,
    cellSpan: Int,
    padding: String = " ",
    rightAlign: Boolean = false)
    : String
{
    var cell: String = cell

    while (cell.length > cellSpan) {
        cell = cell.dropLast(1)
    }

    while (cell.length < cellSpan) {
        if (rightAlign) {
            cell = padding + cell
        }
        else {
            cell = cell + padding
        }
    }

    return cell
}

// Kotlin:  Unresolved reference: Range
//    public static func random(in range: Range<Double>) -> Double {
//        return Random().randomDouble()
//    }
// MARK: URL
typealias URL = java.net.URL

// MARK: Data
typealias Data = kotlin.ByteArray

val Data.count: Int
    get() = size

fun readData(filePath: String): Data = java.io.File(filePath).readBytes()

// MARK: FileManager
class FileManager {
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
    ): java.io.IOException()
}

// MARK: Utilities
internal fun dbg(value: String) {
    System.out.println("DEBUG Kotlin: " + value)
}

// MARK: JSON
internal sealed class JSON {
    class Nul: JSON()
    class Bol(val boolean: Boolean): JSON()
    class Num(val number: Double): JSON()
    class Str(val string: String): JSON()
    class Arr(val array: List<JSON>): JSON()
    class Obj(val dictionary: Map<String, JSON>): JSON()
}

// MARK: Unconditional Swift/Kotlin
internal fun Connection.Companion.demoDatabase() {
    val rnd: Double = Random().randomDouble()
    val dbname: String = "/tmp/demosql_${rnd}.db"

    dbg(value = "connecting to: " + dbname)

    val conn: Connection = Connection(filename = dbname)

    assert(conn.query(sql = "SELECT 1.0").nextRow(close = true)?.firstOrNull()?.floatValue == 1.0)
    assert(conn.query(sql = "SELECT 'ABC'").nextRow(close = true)?.firstOrNull()?.textValue == "ABC")
    assert(
        conn.query(sql = "SELECT lower('ABC')").nextRow(close = true)?.firstOrNull()?.textValue == "abc")
    assert(
        conn.query(sql = "SELECT 3.0/2.0, 4.0*2.5").nextRow(close = true)?.lastOrNull()?.floatValue == 10.0)
    assert(
        conn.query(sql = "SELECT ?", params = listOf(SQLValue.Text(string = "ABC"))).nextRow(close = true)?.firstOrNull()?.textValue == "ABC")
    assert(
        conn.query(
                sql = "SELECT upper(?), lower(?)",
                params = listOf(SQLValue.Text(string = "ABC"), SQLValue.Text(string = "XYZ"))).nextRow(
                close = true)?.lastOrNull()?.textValue == "xyz")

    //
    // Kotlin error: “Operator '==' cannot be applied to 'Long?' and 'Int'”
    conn.execute(sql = "CREATE TABLE FOO(NAME VARCHAR, NUM INTEGER, DBL FLOAT)")

    for (i in 1..10) {
        conn.execute(
            sql = "INSERT INTO FOO VALUES(?, ?, ?)",
            params = listOf(SQLValue.Text(string = i.toString()), SQLValue.Integer(int = i.toLong()), SQLValue.Float(double = i.toDouble())))
    }

    val cursor: Cursor = conn.query(sql = "SELECT * FROM FOO")
    val colcount: Int = cursor.columnCount

    dbg(value = "columns: ${colcount}")
    assert(colcount == 3)

    var row: Int = 0
    val consoleWidth: Int = 80

    while (cursor.next()) {
        if (row == 0) {
            // header and border rows
            dbg(value = cursor.rowText(width = consoleWidth))
            dbg(value = cursor.rowText(header = true, width = consoleWidth))
            dbg(value = cursor.rowText(width = consoleWidth))
        }

        dbg(value = cursor.rowText(values = true, width = consoleWidth))

        row += 1

        assert(cursor.getColumnName(column = 0) == "NAME")
        assert(cursor.getColumnType(column = 0) == ColumnType.TEXT)
        assert(cursor.getString(column = 0) == "${row}")
        assert(cursor.getColumnName(column = 1) == "NUM")
        assert(cursor.getColumnType(column = 1) == ColumnType.INTEGER)
        assert(cursor.getInt64(column = 1) == row.toLong())
        assert(cursor.getColumnName(column = 2) == "DBL")
        assert(cursor.getColumnType(column = 2) == ColumnType.FLOAT)
        assert(cursor.getDouble(column = 2) == row.toDouble())
    }

    dbg(value = cursor.rowText(width = consoleWidth))
    cursor.close()
    assert(cursor.closed == true)
    conn.execute(sql = "DROP TABLE FOO")
    conn.close()
    assert(conn.closed == true)

    val dataFile: Data = readData(dbname)

    assert(dataFile.count > 1024)

    // 8192 on Darwin, 12288 for Android
    // 'removeItem(at:)' is deprecated: URL paths not yet implemented in Kotlin
    //try FileManager.default.removeItem(at: URL(fileURLWithPath: dbname, isDirectory: false))
    FileManager.default.removeItem(path = dbname)
}

internal fun Connection.Companion.demoDatabaseAsync() {
    dbg(value = "ASYNC TEST")

    // FIXME: not really async
    // let url: URL = URL("https://www.example.org")
    // let session = URLSession.shared
    // let contents = try await session.fetch(url: url)
    //let contents: String = try String(from: url)
    //assert(contents.contains("Example Domain"))
}
