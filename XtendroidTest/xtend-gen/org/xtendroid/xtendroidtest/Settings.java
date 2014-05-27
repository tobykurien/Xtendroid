package org.xtendroid.xtendroidtest;

import android.content.Context;
import org.xtendroid.annotations.AndroidPreference;
import org.xtendroid.utils.BasePreferences;

/**
 * Storage of settings, for use in testing.
 */
@SuppressWarnings("all")
public class Settings extends BasePreferences {
  @AndroidPreference
  private boolean enabled = true;
  
  @AndroidPreference
  private String url = "";
  
  @AndroidPreference
  private long maxTimeout = 0;
  
  public static Settings getSettings(final Context context) {
    return BasePreferences.<Settings>getPreferences(context, Settings.class);
  }
  
  public boolean isEnabled() {
    return pref.getBoolean("enabled", enabled);
  }
  
  public boolean setEnabled(final boolean value) {
    pref.edit().putBoolean("enabled", value).commit();
    return true;
  }
  
  public String getUrl() {
    return pref.getString("url", url);
  }
  
  public boolean setUrl(final String value) {
    pref.edit().putString("url", value).commit();
    return true;
  }
  
  public long getMaxTimeout() {
    return pref.getLong("max_timeout", maxTimeout);
  }
  
  public boolean setMaxTimeout(final long value) {
    pref.edit().putLong("max_timeout", value).commit();
    return true;
  }
}
