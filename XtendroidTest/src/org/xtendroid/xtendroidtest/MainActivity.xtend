package org.xtendroid.xtendroidtest

import org.xtendroid.app.AndroidActivity
import org.xtendroid.app.OnCreate

@AndroidActivity(layout=R.layout.activity_main) class MainActivity {
	@OnCreate
	def create() {
		mainHello.text = getString(R.string.hello_world)
	}
}