package org.xtendroid.utils

import android.app.ProgressDialog
import android.os.AsyncTask
import android.os.Build
import org.eclipse.xtext.xbase.lib.Functions.Function1

class AsyncBuilder<T> extends AsyncTask<Object, Object, T> {
   var ProgressDialog progressDialog
   var (Object[])=>T bgTask
   var (T)=>void uiTask
   var ()=>void onPreExecute
   var (Object[])=>void onProgress
   var (Exception)=>void onError
   var ()=>void onCancelled
   var Exception error

   def static AsyncBuilder async(Function1<Object[], ?> task) {
      return async(null, task)
   }
   
   def static AsyncBuilder async(ProgressDialog progressDialog, Function1<Object[], ?> task) {      
      var ab = new AsyncBuilder()
      ab.bgTask = task
      ab.progressDialog = progressDialog
      return ab
   }

   def AsyncBuilder then((T)=>void task) {
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

   def AsyncTask start() {
      return start(null)
   }
   
   def AsyncTask start(Object[] params) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
         // newer versions of Android use a single thread, rather default to multiple threads
        super.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR)
      } else {
         // older versions of Android already use a thread pool
        super.execute()
      }
   }
   
   override protected doInBackground(Object... params) {
      error = null
      try {
        if (bgTask != null) return bgTask.apply(params)
      } catch (Exception e) {
         error = e
         return null
      }
   }

   override protected onPostExecute(T result) {
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
         return
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
      if (!cancelled && onProgress != null) try { 
         onProgress.apply(values)
      } catch (Exception e) {
         error = e
      }
   }
   
}