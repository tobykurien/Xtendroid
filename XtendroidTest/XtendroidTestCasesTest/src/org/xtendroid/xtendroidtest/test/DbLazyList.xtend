package org.xtendroid.xtendroidtest.test

import android.test.AndroidTestCase
import android.test.suitebuilder.annotation.SmallTest
import android.util.Log
import org.xtendroid.xtendroidtest.models.ManyItem

import static org.xtendroid.utils.TimeUtils.*

import static extension org.xtendroid.xtendroidtest.db.DbService.*

@SmallTest
class DbLazyList extends AndroidTestCase {
	override void setUp() {
		// check for data
		var res = context.db.executeForMap("select count(*) as cnt from manyItems", null)
		if (Integer.parseInt(res.get("cnt") as String) < 1000) {
			// delete current items
			context.db.delete("manyItems")
			// add 1000 items
			for (i: 1..1000) {
				context.db.insert("manyItems", #{
					"createdAt" -> now,
					"itemName" -> "Item " + i,
					"itemOrder" -> i
				})
			}
		}
	}
	
	def testLazyList() {
		// run tests over the large data set
		var list = context.db.lazyFindAll("manyItems", null, ManyItem)
		
		// check correct size
		assertNotNull(list)
		assertEquals(1000, list.size)
		
		// check correct items retrieved
		for (i: 205..900) {
			Log.d("lazylisttest", "Got " + list.get(i).itemName)
			assertEquals("Item " + (i + 1), list.get(i).itemName)
		}
		
		// check random access
  	   assertEquals("Item 1", list.get(0).itemName)
  	   assertEquals("Item 205", list.get(204).itemName)
  	   assertEquals("Item 1000", list.get(999).itemName)
	}
	
	override void tearDown() {
	}
}
