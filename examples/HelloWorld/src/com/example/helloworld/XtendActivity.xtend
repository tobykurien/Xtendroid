package com.example.helloworld

import android.app.Activity
import android.os.Bundle
import android.view.Gravity
import android.widget.Button
import android.widget.LinearLayout
import android.widget.Toast
import static extension org.xtendroid.utils.AlertUtils.*

class XtendActivity extends Activity {

   override void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState)
      contentView = new LinearLayout(this) => [
         gravity = Gravity.CENTER
         addView(new Button(this) => [
            text = "Say Hello!"
            onClickListener = [
               toastLong("Hello from Xtend!")
            ]
         ])
      ]
   }
   
}
