package com.tobykurien.xtendroid.utils

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.support.v4.app.NotificationCompat
import android.widget.Toast

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
}