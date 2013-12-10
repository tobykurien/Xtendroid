package org.xtendroid.utils

import android.app.ProgressDialog
import android.os.AsyncTask
import android.os.Build

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
   var ProgressDialog pd

   def runInBgWithProgress(ProgressDialog pdialog, ()=>R bg, (R)=>void ui) {
      pd = pdialog
      runInBg(bg, ui)
   }

   def runInBg(()=>R bg, (R)=>void ui) {
      bgFunction = bg
      uiFunction = ui
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
      return bgFunction.apply()
   }

   override protected onPostExecute(R result) {
      try {
         if (uiFunction != null) uiFunction.apply(result)
      } finally {
         dismissProgress
      }
   }

   def dismissProgress() {
      if(pd != null) pd.dismiss()
   }
}
