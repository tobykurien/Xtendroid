package com.example.xtendroid.sample1

import android.app.ProgressDialog
import android.text.Html
import android.view.View
import com.google.common.io.ByteStreams
import java.io.ByteArrayOutputStream
import java.net.HttpURLConnection
import java.net.URL
import org.xtendroid.app.AndroidActivity

import static org.xtendroid.utils.AsyncBuilder.*

import static extension org.xtendroid.utils.AlertUtils.*

/**
 * Simple sample to show the usage of basic UI helpers as well as 
 * asynchronous processing. This example fetches a random quote from the internet
 * when a button is pressed, and displays it in a TextView. 
 */
@AndroidActivity(R.layout.activity_main) class MainActivity {

	// Button's onClick method
	override loadQuote(View v) {
      // show progress
      val pd = new ProgressDialog(this)
      pd.message = "Loading quote..."
      
      // load quote in the background
      async(pd) [task, params|
         // get the data in the background
         getData('http://www.iheartquotes.com/api/v1/random')               
      ].then [String result|
         // update the UI with new data
         mainQuote.text = Html.fromHtml(result)
      ].onError [Exception error|
         // handle any errors by toasting it
         toast("Error: " + error.message)
      ].start()
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
			ByteStreams.copy(c.inputStream, os)            
         return os.toString
      }

      throw new Exception("[" + c.responseCode + "] " + c.responseMessage)
   }
}
