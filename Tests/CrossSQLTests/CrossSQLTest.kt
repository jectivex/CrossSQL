package CrossSQL

import org.junit.*
import org.junit.Assert.*
import org.junit.runner.RunWith

import kotlinx.coroutines.*
import kotlinx.coroutines.test.*

import java.io.BufferedReader
import java.net.HttpURLConnection
import java.net.URL


/** Hand-written test case that simply calls `Connection.testDatabase()` */
@RunWith(org.robolectric.RobolectricTestRunner::class)
@org.robolectric.annotation.Config(manifest=org.robolectric.annotation.Config.NONE) // otherwise warns about missing AndroidManifest.xml
class CrossSQLTest {
    @Test
    fun testDatabase() {
        Connection.testDatabase()
    }

    @Test
    @OptIn(kotlinx.coroutines.ExperimentalCoroutinesApi::class) // otherwise warning: “CrossSQLTest.kt: (26, 31): This declaration needs opt-in. Its usage should be marked with '@kotlinx.coroutines.ExperimentalCoroutinesApi' or '@OptIn(kotlinx.coroutines.ExperimentalCoroutinesApi::class)'”
    fun testDatabaseAsync() = runTest {
        Connection.testDatabaseAsync()
    }

    @Test
    @OptIn(kotlinx.coroutines.ExperimentalCoroutinesApi::class)
    fun dataFetchShouldWork() = runTest {
        val data = getWebText(url = URL("https://www.example.org"))
        //print(data)
        assertTrue(data.contains("Example Domain"))
    }

    @Test
    fun testWeakRef() {
        demoWeakSelf("ABC")
    }

}

private suspend fun getWebText(url: URL): String = withContext(Dispatchers.IO) {
    url.run {
        val connection = openConnection() // as HttpURLConnection
        val stream = connection.inputStream
        val text = stream.bufferedReader().use(BufferedReader::readText)
        text
    }
}


fun demoWeakSelf(value: Any): Unit {
    java.lang.ref.WeakReference(value).run {
        this.get()?.let { ref ->
            System.out.println("weak ref contents:" + ref)
        }
    }
}
