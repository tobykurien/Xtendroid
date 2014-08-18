package org.xtendroid.xtendroidtest.activities

import android.app.ProgressDialog
import android.widget.BaseAdapter
import java.util.Date
import java.util.List
import org.xtendroid.adapter.BeanAdapter
import org.xtendroid.app.AndroidActivity
import org.xtendroid.app.OnCreate
import org.xtendroid.utils.BgTask
import org.xtendroid.xtendroidtest.R
import org.xtendroid.xtendroidtest.models.ManyItem

import static extension org.xtendroid.utils.AlertUtils.*
import static extension org.xtendroid.xtendroidtest.db.DbService.*

@AndroidActivity(R.layout.list_and_text) class DbTestActivity {
	var List<ManyItem> manyItems 
	
	@OnCreate
	def init() {
		manyItems = db.lazyFindAll("manyitems", "id", ManyItem)
		mainList.adapter = new BeanAdapter(this, R.layout.main_list_row, manyItems)
		
		if (manyItems.size == 0) {
			// let's make many items
			val pd = new ProgressDialog(this)
			pd.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL)
			pd.title = "Creating many items"
			pd.indeterminate = false
			pd.max = 1000
			pd.progress = 0
			val now = new Date
			
			new BgTask<String>.runInBgWithProgress(pd, [|
				(0..1000).forEach [i|
					db.insert("manyitems", #{
						'createdAt' -> now,
						'itemName' -> "Item " + i,
						'itemOrder' -> i
					})

					// TODO - stop this process if pd is cancelled
					runOnUiThread [| pd.progress = i ]
				]
				"done"
			], [r|
				manyItems = db.lazyFindAll("manyitems", "id", ManyItem)
				(mainList.adapter as BaseAdapter).notifyDataSetChanged
			], [e|
				toast("ERROR: " + e.message)
			])
		}
	}
}