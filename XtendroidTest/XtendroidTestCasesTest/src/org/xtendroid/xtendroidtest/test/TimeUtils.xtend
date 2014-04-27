package org.xtendroid.xtendroidtest.test

import android.test.AndroidTestCase

import static extension org.xtendroid.utils.TimeUtils.*

class TimeUtils extends AndroidTestCase {
	def testOne() {
		var date1 = now
		var date2 = now + 24.hours
		
		assertEquals(date2 - date1, 24.hours)
		assertEquals(date2 - 1.hour, date1 + 23.hours)
	}
}