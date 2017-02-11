package org.xtendroid.xtendroidtest.activities

import java.util.ArrayList
import org.xtendroid.app.AndroidActivity
import org.xtendroid.app.OnCreate
import org.xtendroid.xtendroidtest.R
import org.xtendroid.xtendroidtest.adapter.AdapterWithViewHolder
import org.xtendroid.xtendroidtest.models.User
import org.xtendroid.xtendroidtest.adapter.RVAdapter
import android.support.v7.widget.LinearLayoutManager

/**
 * Test usage of @AndroidAdapter annotation
 */
@AndroidActivity(R.layout.activity_recyclerview) class RecyclerViewActivity {
	
	@OnCreate 
	def init() {	
		val users = new ArrayList<User>;
		(1..10).forEach [i|
			var u = new User
			u.firstName = "User" + i
			u.lastName = "Surname" + i
			u.age = i
			users.add(u)
		]
		
		rv.adapter = new RVAdapter(this, users)
		rv.setHasFixedSize(true);
		var llm = new LinearLayoutManager(this);
		llm.setOrientation(LinearLayoutManager.VERTICAL);
		rv.setLayoutManager(llm);
	}
	
}