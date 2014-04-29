package org.xtendroid.xtendroidtest.test

import android.test.AndroidTestCase
import java.util.Date

import static extension org.xtendroid.utils.TimeUtils.*

class TimeUtils extends AndroidTestCase {
	def testOne() {
		var date1 = now
		var date2 = now + 24.hours
		
		assertEquals(date2 - date1, 24.hours)
		assertEquals(date2 - 1.hour, date1 + 23.hours)
		
		var date3 = new Date()
		var date4 = date3 + 2.hours
		var date5 = new Date(date4.time)
		
		assertEquals(date3.time - date4.time, -2.hours)
		assertTrue(date4 == date5)
	}
}