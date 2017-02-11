package org.xtendroid.xtendroidtest.activities

import org.xtendroid.app.AndroidActivity
import org.xtendroid.app.OnCreate
import org.xtendroid.xtendroidtest.R
import org.xtendroid.xtendroidtest.models.User
import org.xtendroid.adapter.BeanAdapter
import java.util.ArrayList
import android.support.v7.app.AppCompatActivity

/**
 * Use the BeanAdapter
 */
@AndroidActivity(R.layout.activity_beanadapter) class BeanAdapterActivity extends AppCompatActivity {

    @OnCreate def init() {
        // generate a bunch of users
        var users = new ArrayList<User>
        for (i : 1 .. 100) {
            val user = new User()
            user.userName = "User " + i
            user.age = i
            users.add(user)
        }

        // The rediculously simple code to display the users in a list
        var adapter = new BeanAdapter(this, R.layout.list_row_user, users)
        userList.adapter = adapter
    }
}