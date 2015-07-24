package org.xtendroid.xtendroidtest.activities

import android.app.ProgressDialog
import android.os.AsyncTask
import java.util.ArrayList
import org.xtendroid.app.AndroidActivity
import org.xtendroid.app.OnCreate
import org.xtendroid.utils.BgTask
import org.xtendroid.xtendroidtest.R

import static extension org.xtendroid.utils.AlertUtils.*
import static extension org.xtendroid.utils.TimeUtils.*
import static extension org.xtendroid.utils.AsyncBuilder.*

@AndroidActivity(R.layout.activity_main) class BgTaskActivity {
   var tasks = new ArrayList<AsyncTask>
   
   @OnCreate
   def init() {
      // Create a determinate progress bar
      val pd = new ProgressDialog(this)
      pd.max = 50
      pd.progress = 0
      pd.indeterminate = false
      pd.progressStyle = ProgressDialog.STYLE_HORIZONTAL

      // Use AsynBuilder to run a background task      
      var task = async(pd) [a, params|
         // Do some work in the background thread
         for (i : 1..50) {
            Thread.sleep(100)
            // update the progress
            a.progress(i)
         }

         // we have access to the parameters too         
         return "Back from bg task with " + params?.get(0)
      ].first [
         // This runs before the background task
         mainHello.text = "Running bg task..."
      ].then [String result|
         // this runs with the result of the background thread
         mainHello.text = result
      ].onProgress [Object[] values|
         // this runs if progress is published in the background thread
         pd.progress = values.get(0) as Integer
      ].onError [Exception error|
         // this runs if an error occurred anywhere else
         mainHello.text = '''Error! «error.class.name» «error.message»'''
      ].start("Param1") // don't forget to call start to kick-off the task

      // keep a pointer to all tasks so we can cancel them later      
      tasks.add(task)
   }
   
   override protected onDestroy() {
      // cancel any running tasks
      tasks.forEach[ it.cancel(true) ]
      super.onDestroy()
   }
   
}