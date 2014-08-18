package org.xtendroid.xtendroidtest

import org.xtendroid.annotations.AndroidPreference

/**
 * Storage of settings, for use in testing.
 */
@AndroidPreference class Settings {
	boolean enabled = true
	String url = ""
	
	// this value not shown in preference screen
	long maxTimeout = 0 // long values not supported in pref screen
}