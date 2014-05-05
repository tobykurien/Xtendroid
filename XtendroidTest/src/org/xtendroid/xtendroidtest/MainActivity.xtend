package org.xtendroid.xtendroidtest

import org.xtendroid.app.AndroidActivity
import org.xtendroid.app.OnCreate
import org.xtendroid.adapter.BeanAdapter

import static extension org.xtendroid.xtendroidtest.db.DbService.*
import org.xtendroid.xtendroidtest.models.ManyItem

@AndroidActivity(layout=R.layout.activity_main) class MainActivity {
	@OnCreate
	def create() {
		mainHello.text = getString(R.string.hello_world)
		
		var manyItems = db.lazyFindAll("manyitems", "id", ManyItem)
		mainList.adapter = new BeanAdapter(this, R.layout.main_list_row, manyItems)
	}
}