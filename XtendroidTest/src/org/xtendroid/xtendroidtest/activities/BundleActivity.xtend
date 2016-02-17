package org.xtendroid.xtendroidtest.activities

import android.app.Activity
import android.os.Bundle
import org.xtendroid.annotations.BundleProperty
import org.xtendroid.xtendroidtest.R
import org.xtendroid.xtendroidtest.fragments.BundleFragment
import org.xtendroid.xtendroidtest.models.User

class BundleActivity extends Activity {
   override protected onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState)
      setContentView(R.layout.activity_bundle)

      // let's pass our data into a Fragment
      var frag = new BundleFragment
      frag.putCategory("New category")
      frag.putCountry("South Africa")
      frag.putUser(new User("John", "Smith"))
      fragmentManager.beginTransaction
         .add(R.id.bundleFragment, frag)
         .commit
   }
}