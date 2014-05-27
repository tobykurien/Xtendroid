package org.xtendroid.xtendroidtest

import android.os.Bundle
import android.preference.PreferenceActivity

class SettingsActivity extends PreferenceActivity {
   
   override protected onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState)
      addPreferencesFromResource(R.xml.settings)
   }
}