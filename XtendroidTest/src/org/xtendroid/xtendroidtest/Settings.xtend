package org.xtendroid.xtendroidtest

import org.xtendroid.annotations.AndroidPreference

/**
 * Storage of settings, for use in testing.
 */
@AndroidPreference class Settings {
	var boolean enabled = true
	var String url = ""
	
	// this value not shown in preference screen
	var long maxTimeout = 0 // long values not supported in pref screen
}