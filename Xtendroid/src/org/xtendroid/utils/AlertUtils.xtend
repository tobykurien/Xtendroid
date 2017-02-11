package org.xtendroid.utils

import android.R
import android.app.AlertDialog
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.os.Handler
import android.support.v4.app.Fragment
import android.support.v4.app.NotificationCompat
import android.widget.Toast

/**
 * UI-based utilities for common UI tasks like toast, confirm, notification
 */
class AlertUtils {
   
   /**
    * Allow runOnUiThread from any context
    */
   def public static runOnUiThread(Context context, ()=>void uiCode) {
      val handler = new Handler(context.mainLooper)
      handler.post(uiCode)
   }

   /**
    * Allow runOnUiThread from any Fragment
    */
   def public static runOnUiThread(Fragment fragment, ()=>void uiCode) {
      val handler = new Handler(fragment.getActivity.getMainLooper)
      handler.post(uiCode)
   }

   /**
    * Display a notification in the system bar
    */
   def public static showNotification(Context context, int notifId, int iconResId, int title, String message, PendingIntent intent) {
      var mNotificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE)
            as NotificationManager;

      var mBuilder = new NotificationCompat.Builder(context)
         .setSmallIcon(iconResId)
         .setContentTitle(context.getString(title))
         .setStyle(new NotificationCompat.BigTextStyle().bigText(message))
         .setContentText(message);

      mBuilder.setContentIntent(intent);
      mNotificationManager.notify(notifId, 
         mBuilder.build()
      );
   }

   /**
    * Cancel a previously-displayed notification
    */   
   def public static cancelNotification(Context context, int notifId) {
      var nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
      nm.cancel(notifId)
   }
   
   /**
    * Show a toast from any context
    */
   def public static toast(Context context, String message) {
      Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
   }
   
   /**
    * Show a toast from any Fragment
    */
   def public static toast(Fragment fragment, String message) {
      toast(fragment.activity, message)
   }
   
   /**
    * Show a toast from any context, which displays for a longer period of time
    */
   def public static toastLong(Context context, String message) {
      Toast.makeText(context, message, Toast.LENGTH_LONG).show()
   }
   
   /**
    * Show a toast from any Fragment, which displays for a longer period of time
    */
   def public static toastLong(Fragment fragment, String message) {
      toastLong(fragment.activity, message)
   }
   
   /**
    * Show a dialog box with Ok/Cancel to confirm an action.
    * NOTE: set android:configChanges="..." to handle rotation, else this
    *       will cause an app crash on rotation
    */
   def public static confirm(Context context, String message, ()=>void confirmed, ()=>void cancelled) {
      new AlertDialog.Builder(context)
         .setMessage(message)
         .setPositiveButton(R.string.ok, [a,b| confirmed?.apply(); a.dismiss; ])
         .setNegativeButton(R.string.cancel, [a,b| cancelled?.apply(); a.dismiss; ])
         .create.show
   }

   /**
    * Show a dialog box with Ok/Cancel to confirm an action.
    * NOTE: set android:configChanges="..." to handle rotation, else this
    *       will cause an app crash on rotation
    */
   def public static confirm(Context context, String message, ()=>void confirmed) {
      confirm(context, message, confirmed, null)
   }
   
   /**
    * Show a dialog box with Ok/Cancel to confirm an action.
    * NOTE: set android:configChanges="..." to handle rotation, else this
    *       will cause an app crash on rotation
    */
   def public static confirm(Fragment fragment, String message, ()=>void confirmed, ()=>void cancelled) {
      confirm(fragment.activity, message, confirmed, cancelled)
   }   

   /**
    * Show a dialog box with Ok/Cancel to confirm an action.
    * NOTE: set android:configChanges="..." to handle rotation, else this
    *       will cause an app crash on rotation
    */
   def public static confirm(Fragment fragment, String message, ()=>void confirmed) {
      confirm(fragment.activity, message, confirmed)
   }   
}