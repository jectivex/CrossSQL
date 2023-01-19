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
        Connection.demoDatabase()
        System.out.println("### DONE TESTING DATABASE")
    }
}
