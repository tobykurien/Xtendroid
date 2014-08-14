package org.xtendroid.xtendroidtest.activities

import org.xtendroid.adapter.BeanAdapter
import org.xtendroid.app.AndroidActivity
import org.xtendroid.xtendroidtest.R
import org.xtendroid.xtendroidtest.models.ManyItem

import static extension org.xtendroid.xtendroidtest.db.DbService.*

@AndroidActivity(R.layout.list_and_text) class DbTestActivity {
	def init() {
		// Run the DbLazyList test to populate the database with lots of items
		var manyItems = db.lazyFindAll("manyitems", "id", ManyItem)
		mainList.adapter = new BeanAdapter(this, R.layout.main_list_row, manyItems)
	}
}