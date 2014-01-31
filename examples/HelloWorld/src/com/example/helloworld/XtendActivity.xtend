package com.example.helloworld

import android.app.Activity
import android.os.Bundle
import android.view.Gravity
import android.widget.Button
import android.widget.LinearLayout
import android.widget.Toast

class XtendActivity extends Activity {

   override void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState)
      contentView = new LinearLayout(this) => [
         gravity = Gravity.CENTER
         addView(new Button(this) => [
            text = "Say Hello!"
            onClickListener = [
               Toast.makeText(context, "Hello from Xtend!", Toast.LENGTH_LONG).show()
            ]
         ])
      ]
   }
   
}
