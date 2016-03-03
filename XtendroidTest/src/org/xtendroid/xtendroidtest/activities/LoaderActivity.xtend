package org.xtendroid.xtendroidtest.activities

import org.xtendroid.app.AndroidActivity
import org.xtendroid.xtendroidtest.R
import org.xtendroid.app.OnCreate
import org.xtendroid.xtendroidtest.fragments.FragmentWithLoader

@AndroidActivity(R.layout.activity_loader) class LoaderActivity extends android.support.v4.app.FragmentActivity {
   @OnCreate def init() {
      supportFragmentManager.beginTransaction
         .replace(R.id.fragment, new FragmentWithLoader)
         .commit
   }
}