package com.example.xtendroid.sample1

import android.app.Activity
import android.app.ProgressDialog
import android.os.Bundle
import android.text.Html
import android.widget.Button
import android.widget.TextView
import java.io.ByteArrayOutputStream
import java.net.HttpURLConnection
import java.net.URL
import org.xtendroid.annotations.AndroidView
import org.xtendroid.utils.BgTask

import static extension org.xtendroid.utils.AlertUtils.*

/**
 * Sample 1a - simple sample to show the usage of basic UI helpers as well as 
 * asynchronous processing. This example fetches a random quote from the internet
 * when a button is pressed, and displays it in a TextView.
 */
class MainActivity extends Activity {
   @AndroidView TextView mainQuote // loads from R.id.main_quote
   @AndroidView Button mainLoadQuote // loads from R.id.main_load_quote

   override protected onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState)
      contentView = R.layout.activity_main // same as setContentView(R.layout.activity_main)

      // set up the button to load quotes
      mainLoadQuote.setOnClickListener([
         // show progress
         val pd = new ProgressDialog(this)
         pd.message = "Loading quote..."
         
         // load quote in the background
         new BgTask<String>.runInBgWithProgress(pd,[|
            // get the data in the background
            getData('http://www.iheartquotes.com/api/v1/random')               
         ],[result|
            // update the UI with new data
            mainQuote.text = Html.fromHtml(result)
         ],[error|
            // handle any errors by toasting it
            toast("Error: " + error.message)
         ])
      ])
   }

   /**
    * Utility function to get data from the internet. In production code, 
    * you should rather use something like the Volley library.
    *
    * @param url
    * @return
    * @throws IOException
    */
   def static String getData(String url) {
      // connect to the URL
      var c = new URL(url).openConnection as HttpURLConnection
      c.connect
      
      if (c.responseCode == HttpURLConnection.HTTP_OK) {
         // read data into a buffer
         var os = new ByteArrayOutputStream
         var is = c.inputStream
         var int oneChar
         while ((oneChar = is.read) > 0) {
            os.write(oneChar)
         }
         is.close
         os.close
         
         // return the data as a String
         return os.toString
      }

      return null
   }
}
