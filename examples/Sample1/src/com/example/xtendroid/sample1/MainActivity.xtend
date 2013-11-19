package com.example.xtendroid.sample1

import android.app.Activity
import android.app.ProgressDialog
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import java.io.ByteArrayOutputStream
import java.net.HttpURLConnection
import java.net.URL
import org.xtendroid.annotations.AndroidView
import org.xtendroid.utils.BgTask

import static extension org.xtendroid.utils.AlertUtils.*
import android.text.Html

/**
 * Sample 1 - simple sample to show the usage of basic UI helpers as well as 
 * asynchronous processing
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
            try { 
               getData('http://www.iheartquotes.com/api/v1/random')               
            } catch (Exception e) {
               // handle errors by toasting it
               runOnUiThread [| toast("Error: " + e.message) ]
               "ERROR: " + e.message // return error as well
            }
         ],[result|
            mainQuote.text = Html.fromHtml(result)
            null // this function returns a Void (not used), so return null
         ])
      ])
   }

   /**
    * Get data from the internet
    *
    * @param url
    * @return
    * @throws IOException
    */
   def String getData(String url) {
      // connect to the URL
      var u = new URL(url)
      var c = u.openConnection() as HttpURLConnection
      c.connect()
      
      if (c.getResponseCode() == HttpURLConnection.HTTP_OK) {
         // read data into a buffer
         var is = c.getInputStream()
         var int oneChar
         var os = new ByteArrayOutputStream()
         while ((oneChar = is.read()) > 0) {
            os.write(oneChar)
         }
         is.close()
         
         // return the data as a String
         return os.toString()
      }

      return null
   }
}
