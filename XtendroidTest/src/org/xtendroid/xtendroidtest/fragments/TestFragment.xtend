package org.xtendroid.xtendroidtest.fragments

import android.os.Bundle
import org.xtendroid.annotations.AndroidFragment
import org.xtendroid.app.OnCreate
import org.xtendroid.xtendroidtest.R

@AndroidFragment(R.layout.fragment_test) class TestFragment {

	@OnCreate
	def init() {
		fragText.text = "Hello, from Fragment!"
	}
	
}