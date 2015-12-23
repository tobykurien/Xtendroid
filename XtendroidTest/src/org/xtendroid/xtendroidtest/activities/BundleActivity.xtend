package org.xtendroid.xtendroidtest.activities

import android.app.Activity
import android.os.Bundle
import org.xtendroid.annotations.BundleProperty
import org.xtendroid.xtendroidtest.R
import org.xtendroid.xtendroidtest.fragments.BundleFragment

class BundleActivity extends Activity {
   @BundleProperty String country = "South Africa"
   @BundleProperty String category

   override protected onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState)
      setContentView(R.layout.activity_bundle)

      // let's pass our data into a Fragment
      var bundle = new Bundle
      BundleFragment.putCategory(bundle, "New category")
      BundleFragment.putCountry(bundle, country)
      
      var frag = new BundleFragment
      frag.setArguments(bundle)
      fragmentManager.beginTransaction
         .add(R.id.bundleFragment, frag)
         .commit
   }
}