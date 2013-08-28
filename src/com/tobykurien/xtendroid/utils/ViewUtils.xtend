package com.tobykurien.xtendroid.utils

import android.app.Activity
import android.app.Dialog
import android.support.v4.app.Fragment
import android.view.View
import android.widget.Button
import android.widget.Spinner
import android.widget.TextView
import java.util.HashMap

/**
 * Convenience methods to simplify code using findViewById(). These should be imported as static extensions.
 * Implements lazy loading.
 */
class ViewUtils {
   static var cache = new HashMap<Integer, View> 
   
   def static <T extends View> T getView(Activity a, int resId) {
      if (cache.get(resId) == null) {
        cache.put(resId, a.findViewById(resId) as View) 
      }
      
      cache.get(resId) as T 
   }

   def static <T extends View> T getView(Fragment f, int resId) {
      if (cache.get(resId) == null) {
        cache.put(resId, f.activity.findViewById(resId) as View) 
      }
      
      cache.get(resId) as T 
   }

   def static <T extends View> T getView(Dialog d, int resId) {
      if (cache.get(resId) == null) {
        cache.put(resId, d.findViewById(resId) as View) 
      }
      
      cache.get(resId) as T 
   }
   
   def static <T extends View> T getView(View v, int resId) {
      v.findViewById(resId) as T
   }

   def static TextView getTextView(Dialog d, int tvResId) {
      d.findViewById(tvResId) as TextView
   }

   def static Button getButton(Dialog d, int btnResId) {
      d.findViewById(btnResId) as Button
   }

   def static Spinner getSpinner(Dialog d, int resId) {
      d.findViewById(resId) as Spinner
   }

   def static TextView getTextView(View v, int tvResId) {
      v.findViewById(tvResId) as TextView
   }

   def static Button getButton(View v, int btnResId) {
      v.findViewById(btnResId) as Button
   }

   def static Spinner getSpinner(View v, int resId) {
      v.findViewById(resId) as Spinner
   }
}