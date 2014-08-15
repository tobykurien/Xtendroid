package org.xtendroid.xtendroidtest.fragments

import org.xtendroid.annotations.AndroidFragment
import org.xtendroid.annotations.BundleProperty
import org.xtendroid.app.OnCreate
import org.xtendroid.xtendroidtest.R

@AndroidFragment(R.layout.activity_parcelable) class BundleFragment {
   @BundleProperty String category
   @BundleProperty String country
   
   @OnCreate
   def init() {
      parcelText.text = '''Fragment got bundle params: «country» «category»'''
   }
}