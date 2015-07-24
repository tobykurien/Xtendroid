package org.xtendroid.utils

import android.app.ProgressDialog
import android.os.AsyncTask
import android.os.Build
import org.eclipse.xtext.xbase.lib.Functions.Function2

class AsyncBuilder<Result> extends AsyncTask<Object, Object, Result> {
   var ProgressDialog progressDialog
   var (AsyncBuilder, Object[])=>Result bgTask
   var (Result)=>void uiTask
   var ()=>void onPreExecute
   var (Object[])=>void onProgress
   var (Exception)=>void onError
   var ()=>void onCancelled
   var Exception error

   def static AsyncBuilder async(Function2<AsyncBuilder, Object[], ?> task) {
      return async(null, task)
   }
   
   def static AsyncBuilder async(ProgressDialog progressDialog, Function2<AsyncBuilder, Object[], ?> task) {      
      var ab = new AsyncBuilder()
      ab.bgTask = task
      ab.progressDialog = progressDialog
      return ab
   }

   def AsyncBuilder then((Result)=>void task) {
      this.uiTask = task
      return this
   }
   
   def AsyncBuilder first(()=>void task) {
      this.onPreExecute = task
      return this
   }
   
   def AsyncBuilder onError((Exception)=>void task) {
      this.onError = task
      return this
   }

   def AsyncBuilder onCancelled(()=>void task) {
      this.onCancelled = task
      return this
   }

   def AsyncBuilder onProgress((Object[])=>void task) {
      this.onProgress = task
      return this
   }
   
   def void progress(Object... values) {
      publishProgress(values)
   }

   def AsyncTask start() {
      return start(null)
   }
   
   def AsyncTask start(Object... params) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
         // newer versions of Android use a single thread, rather default to multiple threads
        super.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, params)
      } else {
         // older versions of Android already use a thread pool
        super.execute(params)
      }
   }
   
   override protected doInBackground(Object... params) {
      if (cancelled || error != null) return null
      
      try {
        if (bgTask != null) return bgTask.apply(this, params)
      } catch (Exception e) {
         error = e
         return null
      }
   }

   override protected onPostExecute(Result result) {
      super.onPostExecute(result)
      if (!cancelled && error == null && uiTask != null) try {
         uiTask.apply(result)
      } catch (Exception e) {
         error = e
      }

      if (!cancelled && progressDialog != null) {
         progressDialog.hide()
      }
      
      if (error != null) {
         if (!cancelled) onError.apply(error)
      }
   }

   override protected onCancelled() {
      super.onCancelled()
      if (!cancelled && onCancelled != null) try { 
         onCancelled.apply()
      } catch (Exception e) {
         error = e
      }
   }
   
   override protected onPreExecute() {
      super.onPreExecute()
      error = null
      if (!cancelled && progressDialog != null) {
         progressDialog.show()
      }
      
      if (!cancelled && onPreExecute != null) try {
         onPreExecute.apply()
      } catch (Exception e) {
         error = e
      }
   }
   
   override protected onProgressUpdate(Object... values) {
      super.onProgressUpdate(values)
      onProgress.apply(values)
   }
   
}