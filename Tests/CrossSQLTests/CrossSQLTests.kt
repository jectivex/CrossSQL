// =========================================
// GENERATED FILE; EDITS WILL BE OVERWRITTEN
// =========================================
package CrossSQL
import CrossFoundation.*

import kotlin.test.*
import org.junit.Test
import org.junit.Assert
import org.junit.runner.RunWith

import kotlinx.coroutines.*
import kotlinx.coroutines.test.*

@RunWith(org.robolectric.RobolectricTestRunner::class)
@org.robolectric.annotation.Config(manifest=org.robolectric.annotation.Config.NONE)
internal class CrossSQLTests: XCTestCase {
    @Test fun testDatabase() {
        Connection.testDatabase()
    }

    @Test fun testConnection() {
        val url: URL = URL.init("/tmp/testConnection.db", false)
        val conn: Connection = Connection.open(url)

        XCTAssertEqual(1.0, conn.query("SELECT 1.0").singleValue()?.floatValue)
        XCTAssertEqual(3.5, conn.query("SELECT 1.0 + 2.5").singleValue()?.floatValue)
        conn.close()
    }
}



// Mimics the API of XCTest for a JUnit test
// Behavior difference: JUnit assert* thows an exception, but XCTAssert* just reports the failure and continues

private interface XCTestCase {
    fun XCTFail() = Assert.fail()

    fun XCTFail(msg: String) = Assert.fail(msg)

    fun XCTUnwrap(ob: Any?) = { Assert.assertNotNull(ob); ob }
    fun XCTUnwrap(ob: Any?, msg: String) = { Assert.assertNotNull(msg, ob); ob }

    fun XCTAssertTrue(a: Boolean) = Assert.assertTrue(a as Boolean)
    fun XCTAssertTrue(a: Boolean, msg: String) = Assert.assertTrue(msg, a)
    fun XCTAssertFalse(a: Boolean) = Assert.assertFalse(a)
    fun XCTAssertFalse(a: Boolean, msg: String) = Assert.assertFalse(msg, a)

    fun XCTAssertNil(a: Any?) = Assert.assertNull(a)
    fun XCTAssertNil(a: Any?, msg: String) = Assert.assertNull(msg, a)
    fun XCTAssertNotNil(a: Any?) = Assert.assertNotNull(a)
    fun XCTAssertNotNil(a: Any?, msg: String) = Assert.assertNotNull(msg, a)

    fun XCTAssertIdentical(a: Any?, b: Any?) = Assert.assertSame(a, b)
    fun XCTAssertIdentical(a: Any?, b: Any?, msg: String) = Assert.assertSame(msg, a, b)
    fun XCTAssertNotIdentical(a: Any?, b: Any?) = Assert.assertNotSame(a, b)
    fun XCTAssertNotIdentical(a: Any?, b: Any?, msg: String) = Assert.assertNotSame(msg, a, b)

    fun XCTAssertEqual(a: Any?, b: Any?) = Assert.assertEquals(a, b)
    fun XCTAssertEqual(a: Any?, b: Any?, msg: String) = Assert.assertEquals(msg, a, b)
    fun XCTAssertNotEqual(a: Any?, b: Any?) = Assert.assertNotEquals(a, b)
    fun XCTAssertNotEqual(a: Any?, b: Any?, msg: String) = Assert.assertNotEquals(msg, a, b)

    // additional overloads needed for XCTAssert*() which have different signatures on Linux (@autoclosures) than on Darwin platforms (direct values)

    fun XCTUnwrap(ob: () -> Any?) = { val x = ob(); Assert.assertNotNull(x); x }
    fun XCTUnwrap(ob: () -> Any?, msg: () -> String) = { val x = ob(); Assert.assertNotNull(msg(), x); x }

    fun XCTAssertTrue(a: () -> Boolean) = Assert.assertTrue(a())
    fun XCTAssertTrue(a: () -> Boolean, msg: () -> String) = Assert.assertTrue(msg(), a())
    fun XCTAssertFalse(a: () -> Boolean) = Assert.assertFalse(a())
    fun XCTAssertFalse(a: () -> Boolean, msg: () -> String) = Assert.assertFalse(msg(), a())

    fun XCTAssertNil(a: () -> Any?) = Assert.assertNull(a())
    fun XCTAssertNil(a: () -> Any?, msg: () -> String) = Assert.assertNull(msg(), a())
    fun XCTAssertNotNil(a: () -> Any?) = Assert.assertNotNull(a())
    fun XCTAssertNotNil(a: () -> Any?, msg: () -> String) = Assert.assertNotNull(msg(), a())

    fun XCTAssertIdentical(a: () -> Any?, b: () -> Any?) = Assert.assertSame(a(), b())
    fun XCTAssertIdentical(a: () -> Any?, b: () -> Any?, msg: () -> String) = Assert.assertSame(msg(), a(), b())
    fun XCTAssertNotIdentical(a: () -> Any?, b: () -> Any?) = Assert.assertNotSame(a(), b())
    fun XCTAssertNotIdentical(a: () -> Any?, b: () -> Any?, msg: () -> String) = Assert.assertNotSame(msg(), a(), b())

    fun XCTAssertEqual(a: () -> Any?, b: () -> Any?) = Assert.assertEquals(a(), b())
    fun XCTAssertEqual(a: () -> Any?, b: () -> Any?, msg: () -> String) = Assert.assertEquals(msg(), a(), b())
    fun XCTAssertNotEqual(a: () -> Any?, b: () -> Any?) = Assert.assertNotEquals(a(), b())
    fun XCTAssertNotEqual(a: () -> Any?, b: () -> Any?, msg: () -> String) = Assert.assertNotEquals(msg(), a(), b())
}

