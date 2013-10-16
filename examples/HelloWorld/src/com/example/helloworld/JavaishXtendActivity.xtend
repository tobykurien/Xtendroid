package com.example.helloworld

import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import android.widget.Toast
import android.app.Activity

class JavaishXtendActivity extends Activity {
   
   override protected void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState)
      val Button button = new Button(this)
      button.setText("Say Hello!")
      button.setOnClickListener([ View v |
            Toast.makeText(v.getContext(), "Hello from javaish Xtend!", Toast.LENGTH_LONG).show()
         ])
      val LinearLayout layout = new LinearLayout(this)
      layout.setGravity(Gravity.CENTER)
      layout.addView(button)
      setContentView(layout)
   }
}