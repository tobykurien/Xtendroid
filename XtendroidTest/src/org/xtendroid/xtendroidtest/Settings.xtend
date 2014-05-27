package org.xtendroid.xtendroidtest

import android.content.Context
import org.xtendroid.utils.BasePreferences
import org.xtendroid.annotations.AndroidPreference

/**
 * Storage of settings, for use in testing.
 */
class Settings extends BasePreferences {
	@AndroidPreference boolean enabled = true
	@AndroidPreference String url = ""
	
	// this value not shown in preference screen
	@AndroidPreference long maxTimeout = 0 // long values not supported in pref screen
	
	def static Settings getSettings(Context context) {
      return getPreferences(context, Settings)
   }	
}