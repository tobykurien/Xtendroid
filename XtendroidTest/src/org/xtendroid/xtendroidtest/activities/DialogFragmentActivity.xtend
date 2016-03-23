package org.xtendroid.xtendroidtest.activities

import org.xtendroid.app.AndroidActivity
import org.xtendroid.app.OnCreate
import org.xtendroid.xtendroidtest.R
import org.xtendroid.xtendroidtest.fragments.CustomDialog

@AndroidActivity(R.layout.activity_dialog_fragment) class DialogFragmentActivity {
   @OnCreate
   def init() {
      dialogButton.onClickListener = [
         new CustomDialog().show(fragmentManager, "dlg")
      ]
   }
}