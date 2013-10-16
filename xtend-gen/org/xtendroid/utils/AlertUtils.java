package org.xtendroid.utils;

import android.R.string;
import android.app.AlertDialog;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.NotificationCompat.BigTextStyle;
import android.support.v4.app.NotificationCompat.Builder;
import android.widget.Toast;
import org.eclipse.xtext.xbase.lib.Functions.Function0;

@SuppressWarnings("all")
public class AlertUtils {
  public static void showNotification(final Context context, final int notifId, final int iconResId, final int title, final String message, final PendingIntent intent) {
    Object _systemService = context.getSystemService(Context.NOTIFICATION_SERVICE);
    NotificationManager mNotificationManager = ((NotificationManager) _systemService);
    Builder _builder = new Builder(context);
    Builder _setSmallIcon = _builder.setSmallIcon(iconResId);
    String _string = context.getString(title);
    Builder _setContentTitle = _setSmallIcon.setContentTitle(_string);
    BigTextStyle _bigTextStyle = new BigTextStyle();
    BigTextStyle _bigText = _bigTextStyle.bigText(message);
    Builder _setStyle = _setContentTitle.setStyle(_bigText);
    Builder mBuilder = _setStyle.setContentText(message);
    mBuilder.setContentIntent(intent);
    Notification _build = mBuilder.build();
    mNotificationManager.notify(notifId, _build);
  }
  
  public static void cancelNotification(final Context context, final int notifId) {
    Object _systemService = context.getSystemService(Context.NOTIFICATION_SERVICE);
    NotificationManager nm = ((NotificationManager) _systemService);
    nm.cancel(notifId);
  }
  
  public static void toast(final Context context, final String message) {
    Toast _makeText = Toast.makeText(context, message, Toast.LENGTH_SHORT);
    _makeText.show();
  }
  
  public static void toast(final Fragment fragment, final String message) {
    FragmentActivity _activity = fragment.getActivity();
    AlertUtils.toast(_activity, message);
  }
  
  public static void confirm(final Context context, final String message, final Function0<Void> confirmed) {
    android.app.AlertDialog.Builder _builder = new android.app.AlertDialog.Builder(context);
    android.app.AlertDialog.Builder _setMessage = _builder.setMessage(message);
    final OnClickListener _function = new OnClickListener() {
      public void onClick(final DialogInterface a, final int b) {
        confirmed.apply();
      }
    };
    android.app.AlertDialog.Builder _setPositiveButton = _setMessage.setPositiveButton(string.ok, _function);
    final OnClickListener _function_1 = new OnClickListener() {
      public void onClick(final DialogInterface a, final int b) {
        a.dismiss();
      }
    };
    android.app.AlertDialog.Builder _setNegativeButton = _setPositiveButton.setNegativeButton(string.cancel, _function_1);
    AlertDialog _create = _setNegativeButton.create();
    _create.show();
  }
  
  public static void confirm(final Fragment fragment, final String message, final Function0<Void> confirmed) {
    FragmentActivity _activity = fragment.getActivity();
    AlertUtils.confirm(_activity, message, confirmed);
  }
}
