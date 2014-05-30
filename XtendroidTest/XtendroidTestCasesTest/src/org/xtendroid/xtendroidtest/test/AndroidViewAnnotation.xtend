package org.xtendroid.xtendroidtest.test

import android.test.ActivityInstrumentationTestCase2
import android.widget.TextView
import org.xtendroid.xtendroidtest.MainActivity2
import org.xtendroid.xtendroidtest.R

class AndroidViewAnnotation extends ActivityInstrumentationTestCase2<MainActivity2> {
	
	new() {
		super(MainActivity2)
	}
	
	def void testAnnotation() {
		val annotationTv = (activity as MainActivity2).mainHello		
		val tv = activity.findViewById(R.id.main_hello) as TextView
		assertEquals(activity.getString(R.string.hello_world), tv.text)
		
		assertEquals(annotationTv.id, tv.id)

		activity.runOnUiThread [|
			annotationTv.text = "Testing"
			assertEquals(annotationTv.text, tv.text)
		]
		
		Thread.sleep(1000) // wait for above thread to run
	}	
}