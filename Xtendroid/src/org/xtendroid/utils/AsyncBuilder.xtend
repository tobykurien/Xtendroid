package org.xtendroid.utils

import android.app.ProgressDialog
import android.os.AsyncTask
import android.os.Build
import org.eclipse.xtext.xbase.lib.Functions.Function2

class AsyncBuilder<Result> extends AsyncTask<Object, Object, Result> {
   var protected ProgressDialog progressDialog
   var protected (AsyncBuilder<Result>, Object[])=>Result bgTask
   var protected (Result)=>void uiTask
   var protected ()=>void onPreExecute
   var protected (Object[])=>void onProgress
   var protected (Exception)=>void onError
   var protected ()=>void onCancelled
   var protected Exception error

   def static <R> AsyncBuilder<R> async(Function2<AsyncBuilder<R>, Object[], R> task) {
      return async(null, task)
   }
   
   def static <R> AsyncBuilder<R> async(ProgressDialog progressDialog, Function2<AsyncBuilder<R>, Object[], R> task) {      
      var ab = new AsyncBuilder<R>()
      ab.bgTask = task
      ab.progressDialog = progressDialog
      return ab
   }

   def AsyncBuilder<Result> then((Result)=>void task) {
      this.uiTask = task
      return this
   }
   
   def AsyncBuilder<Result> first(()=>void task) {
      this.onPreExecute = task
      return this
   }
   
   def AsyncBuilder<Result> onError((Exception)=>void task) {
      this.onError = task
      return this
   }

   def AsyncBuilder<Result> onCancelled(()=>void task) {
      this.onCancelled = task
      return this
   }

   def AsyncBuilder<Result> onProgress((Object[])=>void task) {
      this.onProgress = task
      return this
   }
   
   def void progress(Object... values) {
      publishProgress(values)
   }

   def AsyncTask<Object, Object, Result> start() {
      return start(null as Object)
   }
   
   def AsyncTask<Object, Object, Result> start(Object... params) {
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
         progressDialog.dismiss()
      }
      
      if (error != null) {
         if (!cancelled) {
            if (onError != null) onError.apply(error)
            else throw error
         }
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