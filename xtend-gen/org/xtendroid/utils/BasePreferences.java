package org.xtendroid.utils;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import com.google.common.base.Objects;
import java.util.HashMap;
import java.util.Set;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function0;

/**
 * A base class for easy access to SharedPreferences. Implements caching of
 * SharedPreferences instances. Use in conjunction with the @Preference
 * annotation
 */
@SuppressWarnings("all")
public class BasePreferences {
  protected SharedPreferences pref;
  
  protected final static HashMap<String,BasePreferences> cache = new Function0<HashMap<String,BasePreferences>>() {
    public HashMap<String,BasePreferences> apply() {
      HashMap<String,BasePreferences> _hashMap = new HashMap<String, BasePreferences>();
      return _hashMap;
    }
  }.apply();
  
  protected BasePreferences() {
  }
  
  public static BasePreferences getPreferences(final Context context, final Class subclass) {
    BasePreferences _xblockexpression = null;
    {
      Set<String> _keySet = BasePreferences.cache.keySet();
      int _length = ((Object[])Conversions.unwrapArray(_keySet, Object.class)).length;
      boolean _greaterThan = (_length > 5);
      if (_greaterThan) {
        BasePreferences.cache.clear();
      }
      String _string = context.toString();
      BasePreferences _get = BasePreferences.cache.get(_string);
      boolean _equals = Objects.equal(_get, null);
      if (_equals) {
        Context _applicationContext = context.getApplicationContext();
        final SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(_applicationContext);
        String _string_1 = context.toString();
        BasePreferences _newInstance = BasePreferences.newInstance(subclass, preferences);
        BasePreferences.cache.put(_string_1, _newInstance);
      }
      String _string_2 = context.toString();
      BasePreferences _get_1 = BasePreferences.cache.get(_string_2);
      _xblockexpression = (_get_1);
    }
    return _xblockexpression;
  }
  
  private SharedPreferences setPref(final SharedPreferences preferences) {
    SharedPreferences _pref = this.pref = preferences;
    return _pref;
  }
  
  public static BasePreferences newInstance(final Class cls, final SharedPreferences preferences) {
    BasePreferences instance = null;
    boolean _isAssignableFrom = BasePreferences.class.isAssignableFrom(cls);
    boolean _not = (!_isAssignableFrom);
    if (_not) {
      String _name = cls.getName();
      String _plus = ("BasePreferences: Class " + _name);
      String _plus_1 = (_plus + " is not a subclass of BasePreferences?");
      IllegalArgumentException _illegalArgumentException = new IllegalArgumentException(_plus_1);
      throw _illegalArgumentException;
    }
    try {
      Object _newInstance = cls.newInstance();
      instance = ((BasePreferences) _newInstance);
    } catch (final Throwable _t) {
      if (_t instanceof Exception) {
        final Exception ex = (Exception)_t;
        String _name_1 = cls.getName();
        String _plus_2 = ("BasePreferences: Could not instantiate object (no default constructor?) for " + _name_1);
        String _plus_3 = (_plus_2 + ": ");
        String _message = ex.getMessage();
        String _plus_4 = (_plus_3 + _message);
        IllegalStateException _illegalStateException = new IllegalStateException(_plus_4, ex);
        throw _illegalStateException;
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
    instance.setPref(preferences);
    return instance;
  }
  
  public static void clearCache() {
    BasePreferences.cache.clear();
  }
}
