package CrossSQL

import android.database.sqlite.*
import org.junit.*
import org.junit.Assert.*
import org.junit.runner.*

import android.database.*
import android.database.sqlite.*

@RunWith(org.robolectric.RobolectricTestRunner::class)
@org.robolectric.annotation.Config(manifest=org.robolectric.annotation.Config.NONE) // otherwise warns about missing AndroidManifest.xml
class CrossSQLTest {
    @Test
    fun testDatabase() {
        System.out.println("### TESTING DATABASE")

        assertEquals(true, true)

        val db = SQLiteDatabase.openOrCreateDatabase("/tmp/sql.db", null, null)
        val cursor = db.rawQuery("select * from android_metadata", null)
        while (cursor.moveToNext()) {
            val str = cursor.getString(0)
            assertEquals("en_US", str)
        }
        
        cursor.close()
        db.close()
        System.out.println("### DONE TESTING DATABASE")
    }
}
