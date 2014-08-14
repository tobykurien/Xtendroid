package org.xtendroid.xtendroidtest.activities

import android.os.Bundle
import android.preference.PreferenceActivity
import org.xtendroid.xtendroidtest.R

class SettingsActivity extends PreferenceActivity {
   
   override protected onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState)
      addPreferencesFromResource(R.xml.settings)
   }
}