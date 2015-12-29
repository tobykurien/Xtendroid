package org.xtendroid.xtendroidtest.fragments

import android.app.AlertDialog
import android.app.DialogFragment
import android.os.Bundle
import org.xtendroid.annotations.AndroidDialogFragment
import org.xtendroid.app.OnCreate
import org.xtendroid.xtendroidtest.R

@AndroidDialogFragment(R.layout.fragment_dialog) class CustomDialog extends DialogFragment {
   
   override onCreateDialog(Bundle savedInstanceState) {
      new AlertDialog.Builder(activity)
         .setView(contentView)   // contentView is inflated by the @AndroidDialogFragment annotation
         .setPositiveButton("Ok", [ dismiss ])
         .create
   }
   
   @OnCreate
   def init() {
      title.text = "Hello, Dialog!"
      message.text = "This is a dialog fragment, created using an AlertDialog.Builder, and managed using a regular DialogFragment"
   }
}