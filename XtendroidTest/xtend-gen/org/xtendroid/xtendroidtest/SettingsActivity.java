package org.xtendroid.xtendroidtest;

import android.os.Bundle;
import android.preference.PreferenceActivity;
import org.xtendroid.xtendroidtest.R;

@SuppressWarnings("all")
public class SettingsActivity extends PreferenceActivity {
  protected void onCreate(final Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    this.addPreferencesFromResource(R.xml.settings);
  }
}
