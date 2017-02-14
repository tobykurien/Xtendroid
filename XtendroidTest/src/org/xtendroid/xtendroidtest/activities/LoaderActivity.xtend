package org.xtendroid.xtendroidtest.activities

import org.xtendroid.app.AndroidActivity
import org.xtendroid.xtendroidtest.R
import org.xtendroid.app.OnCreate
import org.xtendroid.xtendroidtest.fragments.FragmentWithLoader
import android.app.Activity

@AndroidActivity(R.layout.activity_loader) class LoaderActivity {
   @OnCreate def init() {
      fragmentManager.beginTransaction
         .replace(R.id.fragment, new FragmentWithLoader)
         .commit
   }
}