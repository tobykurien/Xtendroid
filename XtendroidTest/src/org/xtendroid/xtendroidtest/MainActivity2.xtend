package org.xtendroid.xtendroidtest

import android.app.Activity
import android.os.Bundle
import org.xtendroid.annotations.AndroidView
import android.widget.TextView
import android.widget.ListView

class MainActivity2 extends Activity {
	@AndroidView TextView mainHello
	@AndroidView ListView mainList
	
	override protected onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState)
		setContentView = R.layout.activity_main
		mainHello.text = getString(R.string.hello_world)
	}
	
}