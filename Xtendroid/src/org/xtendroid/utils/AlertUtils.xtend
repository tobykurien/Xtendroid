package org.xtendroid.utils

import android.R
import android.app.AlertDialog
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.support.v4.app.Fragment
import android.support.v4.app.NotificationCompat
import android.widget.Toast
import org.eclipse.xtext.xbase.lib.Functions.Function0

class AlertUtils {

   def static showNotification(Context context, int notifId, int iconResId, int title, String message, PendingIntent intent) {
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
   
   def static cancelNotification(Context context, int notifId) {
      var nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
      nm.cancel(notifId)
   }
   
   def static toast(Context context, String message) {
      Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
   }
   
   def static toast(Fragment fragment, String message) {
      toast(fragment.activity, message)
   }
   
   def static toastLong(Context context, String message) {
      Toast.makeText(context, message, Toast.LENGTH_LONG).show()
   }
   
   def static toastLong(Fragment fragment, String message) {
      toastLong(fragment.activity, message)
   }
   
   def static confirm(Context context, String message, ()=>void confirmed) {
      new AlertDialog.Builder(context)
         .setMessage(message)
         .setPositiveButton(R.string.ok, [a,b| confirmed.apply() ])
         .setNegativeButton(R.string.cancel, [a,b| a.dismiss ])
         .create.show
   }
   
   def static confirm(Fragment fragment, String message, ()=>void confirmed) {
      confirm(fragment.activity, message, confirmed)
   }   
}