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
		for (i: 0..1000) {
			Log.d("lazylist", "Got " + list.get(i).itemName)
		}
	}
	
	override void tearDown() {
	}
}
