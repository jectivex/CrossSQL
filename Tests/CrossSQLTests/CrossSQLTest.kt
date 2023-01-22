package CrossSQL

import org.junit.Test
import org.junit.runner.RunWith

/** Hand-written test case that simply calls `Connection.demoDatabase()` */
@RunWith(org.robolectric.RobolectricTestRunner::class)
@org.robolectric.annotation.Config(manifest=org.robolectric.annotation.Config.NONE) // otherwise warns about missing AndroidManifest.xml
class CrossSQLTest {
    @Test
    fun testDatabase() {
        Connection.demoDatabase()
    }

    
    //@Test
    //fun dataShouldBeHelloWorld() = runTest {
    //    val data = fetchData()
    //    assertEquals("Hello world", data)
    //}

}

//suspend fun fetchData(): String {
//    delay(1000L)
//    return "Hello world"
//}

