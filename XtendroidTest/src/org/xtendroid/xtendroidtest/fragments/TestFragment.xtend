package org.xtendroid.xtendroidtest.fragments

import org.xtendroid.annotations.AndroidFragment
import org.xtendroid.app.OnCreate
import org.xtendroid.xtendroidtest.R

/**
 * Fragment to test the @AndroidFragment annotation
 */
@AndroidFragment(R.layout.fragment_test) class TestFragment {

	@OnCreate
	def init() {
		fragText.text = "Hello, from Fragment!"
	}
	
}