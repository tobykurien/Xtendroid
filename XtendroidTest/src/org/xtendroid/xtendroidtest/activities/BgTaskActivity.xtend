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
      var pd = new ProgressDialog(this)
      pd.message = "Loading..."
      
      var task = async(pd) [params|
         Thread.sleep(5.seconds)
         return "Back from bg task"
      ].first [
         mainHello.text = "Running bg task..."
      ].then [String result|
         mainHello.text = result
      ].onError [Exception error|
         mainHello.text = '''Error! «error.class.name» «error.message»'''
      ].start()
      
      tasks.add(task)
   }
   
   override protected onDestroy() {
      tasks.forEach[ it.cancel(true) ]
      super.onDestroy()
   }
   
}