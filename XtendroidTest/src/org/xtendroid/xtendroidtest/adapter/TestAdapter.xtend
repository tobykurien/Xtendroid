package org.xtendroid.xtendroidtest.adapter

import android.widget.LinearLayout
import java.util.List
import org.xtendroid.adapter.AndroidAdapter
import org.xtendroid.annotations.CustomViewGroup
import org.xtendroid.xtendroidtest.R
import org.xtendroid.xtendroidtest.models.User

@AndroidAdapter class TestAdapter {
	List<User> users
	var MyViewGroup showWithData
}

@CustomViewGroup(layout=R.layout.list_row_user)
class MyViewGroup extends LinearLayout {
	def showWithData(User user) {
		userName.text = user.firstName + " " + user.lastName
	   userAge.text = user.age
	}
}