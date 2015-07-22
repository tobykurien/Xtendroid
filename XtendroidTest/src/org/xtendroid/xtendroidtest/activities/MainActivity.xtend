package org.xtendroid.xtendroidtest.activities

import android.content.Intent
import android.view.Menu
import android.view.MenuItem
import org.xtendroid.app.AndroidActivity
import org.xtendroid.app.OnCreate
import org.xtendroid.xtendroidtest.R
import org.xtendroid.adapter.BeanAdapter

/**
 * Main activity simply lists the demos and allows user to launch them
 */
@AndroidActivity(R.layout.activity_main) class MainActivity {
	// Xtendroid API demos
	var demos = #[
      new Demo('BgTask', BgTaskActivity),
		new Demo('@AndroidFragment', FragmentActivity),
      new Demo('@AndroidDialogFragment', DialogFragmentActivity),
		new Demo('@AndroidDatabase, BgTask', DbTestActivity),
		new Demo('@AndroidAdapter', AndroidAdapterActivity),
		new Demo('@AndroidPreference', SettingsActivity),
		new Demo('@AndroidLoader', LoaderActivity),
		new Demo('@AndroidParcelable', ParcelableActivity),
      new Demo('@BundleProperty', BundleActivity)
	]
	
	@OnCreate
	def create() {
		mainHello.text = getString(R.string.welcome)		
		mainList.adapter = new BeanAdapter(this, R.layout.list_row_demo, demos)
		mainList.onItemClickListener = [a,b,c,d|
			var item = a.adapter.getItem(c) as Demo
			var intent = new Intent(this, item.activity)
			startActivity(intent)
		]
	}
	
	override onCreateOptionsMenu(Menu menu) {
		menuInflater.inflate(R.menu.main, menu)
		true
	}
	
	override onOptionsItemSelected(MenuItem item) {
		switch (item.itemId) {
			case R.id.action_settings: {
				val intent = new Intent(this, SettingsActivity)
				startActivity(intent)
			}
		}
		
		super.onOptionsItemSelected(item)
	}
	
}

/**
 * Data bean to store each demo activity
 */
@Data class Demo {
   String title
   Class<?> activity
}
