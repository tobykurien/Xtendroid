package org.xtendroid.xtendroidtest.test;

import android.preference.CheckBoxPreference;
import android.preference.EditTextPreference;
import android.preference.Preference;
import android.test.ActivityInstrumentationTestCase2;
import android.test.suitebuilder.annotation.SmallTest;
import junit.framework.Assert;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.xtendroid.xtendroidtest.Settings;
import org.xtendroid.xtendroidtest.SettingsActivity;

@SmallTest
@SuppressWarnings("all")
public class AndroidPreferenceAnnotation extends ActivityInstrumentationTestCase2<SettingsActivity> {
  public AndroidPreferenceAnnotation() {
    super(SettingsActivity.class);
  }
  
  protected void setUp() throws Exception {
    super.setUp();
    SettingsActivity _activity = this.getActivity();
    Settings _settings = Settings.getSettings(_activity);
    _settings.setEnabled(false);
    SettingsActivity _activity_1 = this.getActivity();
    Settings _settings_1 = Settings.getSettings(_activity_1);
    _settings_1.setUrl("");
    SettingsActivity _activity_2 = this.getActivity();
    Settings _settings_2 = Settings.getSettings(_activity_2);
    _settings_2.setMaxTimeout(0);
  }
  
  public void testAnnotation() {
    try {
      SettingsActivity _activity = this.getActivity();
      Preference _findPreference = _activity.findPreference("enabled");
      final CheckBoxPreference enabled = ((CheckBoxPreference) _findPreference);
      SettingsActivity _activity_1 = this.getActivity();
      Preference _findPreference_1 = _activity_1.findPreference("url");
      final EditTextPreference url = ((EditTextPreference) _findPreference_1);
      Assert.assertNotNull(url);
      Assert.assertNotNull(enabled);
      SettingsActivity _activity_2 = this.getActivity();
      final Runnable _function = new Runnable() {
        public void run() {
          boolean _isChecked = enabled.isChecked();
          Assert.assertEquals(false, _isChecked);
          boolean _isEnabled = url.isEnabled();
          Assert.assertEquals(false, _isEnabled);
          String _text = url.getText();
          Assert.assertEquals("", _text);
          enabled.setChecked(true);
          url.setText("https://github.com/tobykurien/xtendroid");
          SettingsActivity _activity = AndroidPreferenceAnnotation.this.getActivity();
          Settings _settings = Settings.getSettings(_activity);
          _settings.setMaxTimeout(1000);
          SettingsActivity _activity_1 = AndroidPreferenceAnnotation.this.getActivity();
          Settings _settings_1 = Settings.getSettings(_activity_1);
          boolean _isEnabled_1 = _settings_1.isEnabled();
          Assert.assertEquals(true, _isEnabled_1);
          SettingsActivity _activity_2 = AndroidPreferenceAnnotation.this.getActivity();
          Settings _settings_2 = Settings.getSettings(_activity_2);
          String _url = _settings_2.getUrl();
          Assert.assertEquals("https://github.com/tobykurien/xtendroid", _url);
          SettingsActivity _activity_3 = AndroidPreferenceAnnotation.this.getActivity();
          Settings _settings_3 = Settings.getSettings(_activity_3);
          long _maxTimeout = _settings_3.getMaxTimeout();
          Assert.assertEquals(1000, _maxTimeout);
        }
      };
      _activity_2.runOnUiThread(_function);
      Thread.sleep(2000);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
