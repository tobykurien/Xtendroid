package com.tobykurien.xtendroid.utils

import android.app.Activity
import android.content.Context
import android.content.SharedPreferences
import android.preference.PreferenceManager
import android.support.v4.app.Fragment
import android.support.v4.app.FragmentActivity
import java.util.HashMap
import com.tobykurien.xtendroid.annotations.Preference

/**
 * A base class for easy access to SharedPreferences. Implements caching of
 * SharedPreferences instances. Use in conjunction with the @Preference 
 * annotation
 */
class BasePreferences {
   protected SharedPreferences pref
   protected static val cache = new HashMap<String, BasePreferences>
   
   protected new(SharedPreferences preferences) {
      pref = preferences
   }

   static def BasePreferences getPreferences(Activity activity) {
      getPreferences(activity) 
   }

   static def BasePreferences getPreferences(Fragment fragment) {
      getPreferences(fragment.activity)
   }
   
   static def BasePreferences getPreferences(Context context) {
      if (cache.keySet.length > 5) cache.clear // avoid memory leaks by clearing often
      if (cache.get(context.toString()) == null) {
         val preferences = PreferenceManager.getDefaultSharedPreferences(context.getApplicationContext())
         cache.put(context.toString(), new BasePreferences(preferences))         
      }
      
      cache.get(context.toString())
   }
}