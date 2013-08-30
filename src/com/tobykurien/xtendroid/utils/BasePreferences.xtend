package com.tobykurien.xtendroid.utils

import android.content.Context
import android.content.SharedPreferences
import android.preference.PreferenceManager
import java.util.HashMap

/**
 * A base class for easy access to SharedPreferences. Implements caching of
 * SharedPreferences instances. Use in conjunction with the @Preference 
 * annotation
 */
class BasePreferences {
   protected SharedPreferences pref
   protected static val cache = new HashMap<String, BasePreferences>

   protected new() {
   }

   static def BasePreferences getPreferences(Context context, Class subclass) {
      if(cache.keySet.length > 5) cache.clear // avoid memory leaks by clearing often
      if (cache.get(context.toString()) == null) {
         val preferences = PreferenceManager.getDefaultSharedPreferences(context.getApplicationContext())
         cache.put(context.toString(), newInstance(subclass, preferences))
      }

      cache.get(context.toString())
   }

   def private setPref(SharedPreferences preferences) {
      pref = preferences
   }

   def static newInstance(Class cls, SharedPreferences preferences) {
      var BasePreferences instance

      if (!typeof(BasePreferences).isAssignableFrom(cls))
         throw new IllegalArgumentException(
            "BasePreferences: Class " + cls.getName() + " is not a subclass of BasePreferences?");
            
      try {
         instance = cls.newInstance() as BasePreferences;
      } catch (Exception ex) {
         throw new IllegalStateException(
            "BasePreferences: Could not instantiate object (no default constructor?) for " + cls.getName() + ": " + ex.getMessage(), ex);
      }
      
      instance.setPref(preferences)
      return instance;
   }

}
