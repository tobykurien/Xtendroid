package org.xtendroid.xtendroidtest

import android.content.Intent
import android.view.Menu
import android.view.MenuItem
import org.xtendroid.adapter.BeanAdapter
import org.xtendroid.app.AndroidActivity
import org.xtendroid.app.OnCreate
import org.xtendroid.xtendroidtest.models.ManyItem

import static extension org.xtendroid.xtendroidtest.db.DbService.*
import android.view.View

@AndroidActivity(R.layout.activity_main) class MainActivity {
	@OnCreate
	def create() {
		mainHello.text = getString(R.string.hello_world)
		
		// Run the DbLazyList test to populate the database with lots of items
		var manyItems = db.lazyFindAll("manyitems", "id", ManyItem)
		mainList.adapter = new BeanAdapter(this, R.layout.main_list_row, manyItems)
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
	
	override loadFragmentActivity(View element) {
		var intent = new Intent(this, FragmentActivity)
		startActivity(intent)
	}
	
}