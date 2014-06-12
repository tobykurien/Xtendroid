package com.example.helloworld

import android.content.Context
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import org.xtendroid.app.AndroidActivity
import android.app.Activity
import android.os.Bundle
import android.widget.Toast
import android.view.Gravity

import static extension com.example.helloworld.UiBuilder.*

@AndroidActivity(R.layout.main) class HelloWorldActivity {
   
   /**
    * Type safe callback
    */
   override void sayHello(View v) {
      messageView.text = "Hello Android from Xtend!"
   }
   
}

class HelloWorldActivity_2 extends Activity {
   

   override protected void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState)
      
      val button = new Button(this)
      button.text = "Say Hello!"
      button.onClickListener = [ 
         Toast.makeText(context, "Hello Android from Xtend!", Toast.LENGTH_LONG).show
      ]
      
      val layout = new LinearLayout(this)
      layout.gravity = Gravity.CENTER
      layout.addView(button)
      contentView = layout
   }
}

class HelloWorldActivity_3 extends Activity {
   

   override protected void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState)
      
      contentView = linearLayout [
         gravity = Gravity.CENTER
         addView( button [
            text = "Say Hello!"
            onClickListener = [ 
               Toast.makeText(context, "Hello Android from Xtend!", Toast.LENGTH_LONG).show
            ]
         ])
      ]
   }
}

class UiBuilder {
   
   def static LinearLayout linearLayout(Context it, (LinearLayout)=>void initializer) {
      new LinearLayout(it) => initializer
   }
   
   def static Button button(Context it, (Button)=>void initializer) {
      new Button(it) => initializer
   }
   
} 