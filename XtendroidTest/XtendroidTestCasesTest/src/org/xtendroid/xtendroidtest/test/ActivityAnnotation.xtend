package org.xtendroid.xtendroidtest.test

import android.test.ActivityInstrumentationTestCase2
import android.widget.TextView
import org.xtendroid.xtendroidtest.MainActivity
import org.xtendroid.xtendroidtest.R

class ActivityAnnotation extends ActivityInstrumentationTestCase2<MainActivity> {
	
	new() {
		super(MainActivity)
	}
	
	def void testAnnotation() {
		val tv = activity.findViewById(R.id.main_hello) as TextView
		assertEquals(activity.getString(R.string.hello_world), tv.text)
	}
}