package org.xtendroid.xtendroidtest.activities

import java.util.ArrayList
import org.xtendroid.app.AndroidActivity
import org.xtendroid.app.OnCreate
import org.xtendroid.xtendroidtest.R
import org.xtendroid.xtendroidtest.adapter.AdapterWithViewHolder
import org.xtendroid.xtendroidtest.models.User

/**
 * Test usage of @AndroidAdapter annotation
 */
@AndroidActivity(R.layout.activity_main) class AndroidAdapterActivity {
	
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
		
		mainList.adapter = new AdapterWithViewHolder(this, users)		
	}
	
}