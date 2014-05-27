package org.xtendroid.xtendroidtest.test;

import android.preference.Preference;
import android.test.ActivityInstrumentationTestCase2;
import android.test.suitebuilder.annotation.SmallTest;
import junit.framework.Assert;
import org.xtendroid.xtendroidtest.SettingsActivity;

@SmallTest
@SuppressWarnings("all")
public class AndroidPreferenceAnnotation extends ActivityInstrumentationTestCase2<SettingsActivity> {
  public AndroidPreferenceAnnotation() {
    super(SettingsActivity.class);
  }
  
  public void testAnnotation() {
    SettingsActivity _activity = this.getActivity();
    final Preference url = _activity.findPreference("url");
    SettingsActivity _activity_1 = this.getActivity();
    final Preference enabled = _activity_1.findPreference("enabled");
    SettingsActivity _activity_2 = this.getActivity();
    final Preference maxTimeout = _activity_2.findPreference("max_timeout");
    Assert.assertNotNull(url);
    Assert.assertNotNull(enabled);
    Assert.assertNotNull(maxTimeout);
    boolean _isEnabled = url.isEnabled();
    Assert.assertEquals(_isEnabled, false);
  }
}
