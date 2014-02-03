package org.xtendroid.utils

import android.app.ProgressDialog
import android.os.AsyncTask
import android.os.Build
import android.util.Log

/**
 * Convenience class to run tasks in the background using AsyncTask.
 * The generic parameter is the type of the result from the background task to 
 * be passed into the UI task. To run progress updates, etc. from the background
 * closure, simply use runOnUiThread, e.g.: 
 *    runOnUiThread [| progressBar.setValue(progress) ]
 */
class BgTask<R> extends AsyncTask<Void, Void, R> {
   var ()=>R bgFunction
   var (R)=>void uiFunction
   var (Exception)=>void errFunction
   var boolean skipUiFunction = false
   var ProgressDialog pd
   var Exception exception

   def runInBgWithProgress(ProgressDialog pdialog, ()=>R bg) {
      runInBg(bg, null, null)
   }

   def runInBgWithProgress(ProgressDialog pdialog, ()=>R bg, (R)=>void ui) {
      runInBg(bg, ui, null)
   }

   def runInBgWithProgress(ProgressDialog pdialog, ()=>R bg, (R)=>void ui, (Exception)=>void error) {
      pd = pdialog
      runInBg(bg, ui, error)
   }

   def runInBg(()=>R bg) {
      runInBg(bg, null, null)
   }

   def runInBg(()=>R bg, (R)=>void ui) {
      runInBg(bg, ui, null)
   }
   
   def runInBg(()=>R bg, (R)=>void ui, (Exception)=>void error) {
      bgFunction = bg
      uiFunction = ui
      errFunction = error
      skipUiFunction = false

      if(pd != null && !pd.showing) pd.show()

      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
         // newer versions of Android use a single thread, rather default to multiple threads
        executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR)
      } else {
         // older versions of Android already use a thread pool
        execute
      }
   }

   override protected doInBackground(Void... arg0) {
      if (errFunction == null) return bgFunction.apply
      
      try {
         return bgFunction.apply
      } catch (Exception e) {
         skipUiFunction = true
         exception = e
         return null
      }
   }

   override protected onPostExecute(R result) {
      try {
         if (skipUiFunction && errFunction != null) {
            try {
               // run error function in UI thread
               errFunction.apply(exception)
            } catch (Exception e2) {
               Log.e("Xtendroid", "Error while executing error handler: " + e2.message, e2)
            } finally {
               exception = null
               skipUiFunction = false
            }
         } else {
            if (uiFunction != null) uiFunction.apply(result)
         }
      } finally {
         dismissProgress
      }
   }

   def dismissProgress() {
      if (pd != null && pd.showing) pd.dismiss
   }
}
