package org.xtendroid.xtendroidtest.adapter

import android.view.View
import android.view.ViewGroup
import java.util.List
import org.xtendroid.adapter.AndroidAdapter
import org.xtendroid.adapter.AndroidViewHolder
import org.xtendroid.xtendroidtest.R
import org.xtendroid.xtendroidtest.models.User
import android.support.v7.widget.RecyclerView
import android.support.v7.widget.RecyclerView.ViewHolder

/**
 * Testing RecyclerView Adapter
 */
// Viewholder
@AndroidViewHolder(R.layout.list_row_user) class MyViewHolder
    extends RecyclerView.ViewHolder {
}

@AndroidAdapter class RVAdapter extends RecyclerView.Adapter<MyViewHolder> {
    List<User> users

    override void onBindViewHolder(MyViewHolder vh, int position) {
        var item = getItem(position)
        vh.userName.text = item.firstName + " " + item.lastName
        vh.age.text = String.valueOf(item.age)
    }

    override MyViewHolder onCreateViewHolder(ViewGroup viewGroup, int position) {
        return MyViewHolder.getOrCreate(context, null, viewGroup)
    }
}

