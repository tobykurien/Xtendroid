package org.xtendroid.xtendroidtest.fragments

import android.support.v4.app.Fragment
import org.xtendroid.annotations.AndroidFragment
import org.xtendroid.xtendroidtest.R
import android.view.View
import android.os.Bundle

@AndroidFragment(R.layout.activity_main) class ListItemsFragment extends Fragment {

	override onViewCreated(View view, Bundle savedInstanceState) {
		super.onViewCreated(view, savedInstanceState)
		//mainHello.text = "Hello, from Fragment!"
	}
	
}