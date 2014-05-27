package org.xtendroid.xtendroidtest.test

import android.test.ActivityInstrumentationTestCase2
import android.test.suitebuilder.annotation.SmallTest
import org.xtendroid.xtendroidtest.SettingsActivity

@SmallTest
class AndroidPreferenceAnnotation extends ActivityInstrumentationTestCase2<SettingsActivity> {
	
	new() {
		super(SettingsActivity)
	}
	
	def void testAnnotation() {
		val url = activity.findPreference("url")
		val enabled = activity.findPreference("enabled")
		val maxTimeout = activity.findPreference("max_timeout")

		assertNotNull(url)
		assertNotNull(enabled)
		assertNotNull(maxTimeout)

		assertEquals(url.enabled, false)
	}
}