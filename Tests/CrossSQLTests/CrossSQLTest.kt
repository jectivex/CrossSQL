package CrossSQL

/** Hand-written test case that simply calls `Connection.demoDatabase()` */
@org.junit.runner.RunWith(org.robolectric.RobolectricTestRunner::class)
@org.robolectric.annotation.Config(manifest=org.robolectric.annotation.Config.NONE) // otherwise warns about missing AndroidManifest.xml
class CrossSQLTest {
    @org.junit.Test
    fun testDatabase() {
        Connection.demoDatabase()
    }
}
