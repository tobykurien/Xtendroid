package org.xtendroid.xtendroidtest.test

import android.preference.CheckBoxPreference
import android.preference.EditTextPreference
import android.test.ActivityInstrumentationTestCase2
import android.test.suitebuilder.annotation.SmallTest
import org.xtendroid.xtendroidtest.activities.SettingsActivity

import static extension org.xtendroid.xtendroidtest.Settings.*

@SmallTest
class AndroidPreferenceAnnotation extends ActivityInstrumentationTestCase2<SettingsActivity> {
	
	new() {
		super(SettingsActivity)
	}
	
	override protected setUp() throws Exception {
		super.setUp()

		// reset settings		
		activity.settings.enabled = false
		activity.settings.url = ""
		activity.settings.maxTimeout = 0	
	}

	// This test is disabled for now as it is inconsistent (works first time only)
	def void disabled_testAnnotation() {
		// check that the reset settings are what display in the preference activity
		val enabled = activity.findPreference("enabled") as CheckBoxPreference
		val url = activity.findPreference("url") as EditTextPreference

		assertNotNull(url)
		assertNotNull(enabled)

		activity.runOnUiThread [|
			// check current state
			assertEquals(false, enabled.checked)
			assertEquals(false, url.enabled)
			//assertEquals(null, url.text)
			assertTrue(url.text == null || url.text.trim.length == 0)

			// fiddle with values
			enabled.setChecked(true)
			url.text = "https://github.com/tobykurien/xtendroid"
			activity.settings.maxTimeout = 1000
			
			// now check settings values
			assertEquals(true, activity.settings.enabled)
			assertEquals("https://github.com/tobykurien/xtendroid", activity.settings.url)
			assertEquals(1000, activity.settings.maxTimeout)
		]
		
		// wait for above stuff to run
		Thread.sleep(2000)
	}
}
