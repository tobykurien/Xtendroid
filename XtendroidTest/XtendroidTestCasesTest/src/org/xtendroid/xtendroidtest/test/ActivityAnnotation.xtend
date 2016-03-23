package org.xtendroid.xtendroidtest.test

import android.test.ActivityInstrumentationTestCase2
import android.widget.TextView
import org.xtendroid.xtendroidtest.R
import org.xtendroid.xtendroidtest.activities.MainActivity

class ActivityAnnotation extends ActivityInstrumentationTestCase2<MainActivity> {
	
	new() {
		super(MainActivity)
	}
	
	def void testAnnotation() {
		val annotationTv = (activity as MainActivity).mainHello
		val tv = activity.findViewById(R.id.main_hello) as TextView
		assertEquals(activity.getString(R.string.welcome), tv.text)
		
		activity.runOnUiThread [|
			annotationTv.text = "Testing"
			assertEquals(annotationTv.text, tv.text)
		]
		
		Thread.sleep(1000) // wait for above thread to run
	}
}