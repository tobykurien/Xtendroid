package org.xtendroid.utils;

import android.app.Activity;
import android.app.Dialog;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.view.View;
import android.widget.Button;
import android.widget.ListView;
import android.widget.Spinner;
import android.widget.TextView;
import com.google.common.base.Objects;
import java.util.HashMap;
import org.eclipse.xtext.xbase.lib.Functions.Function0;

/**
 * Convenience methods to simplify code using findViewById(). These should be imported as static extensions.
 * Implements lazy loading.
 */
@SuppressWarnings("all")
public class ViewUtils {
  private static HashMap<Integer,View> cache = new Function0<HashMap<Integer,View>>() {
    public HashMap<Integer,View> apply() {
      HashMap<Integer,View> _hashMap = new HashMap<Integer, View>();
      return _hashMap;
    }
  }.apply();
  
  public static <T extends View> T getView(final Activity a, final int resId) {
    T _xblockexpression = null;
    {
      View _get = ViewUtils.cache.get(Integer.valueOf(resId));
      boolean _equals = Objects.equal(_get, null);
      if (_equals) {
        View _findViewById = a.findViewById(resId);
        ViewUtils.cache.put(Integer.valueOf(resId), ((View) _findViewById));
      }
      View _get_1 = ViewUtils.cache.get(Integer.valueOf(resId));
      _xblockexpression = (((T) _get_1));
    }
    return _xblockexpression;
  }
  
  public static <T extends View> T getView(final Fragment f, final int resId) {
    T _xblockexpression = null;
    {
      View _get = ViewUtils.cache.get(Integer.valueOf(resId));
      boolean _equals = Objects.equal(_get, null);
      if (_equals) {
        FragmentActivity _activity = f.getActivity();
        View _findViewById = _activity.findViewById(resId);
        ViewUtils.cache.put(Integer.valueOf(resId), ((View) _findViewById));
      }
      View _get_1 = ViewUtils.cache.get(Integer.valueOf(resId));
      _xblockexpression = (((T) _get_1));
    }
    return _xblockexpression;
  }
  
  public static <T extends View> T getView(final Dialog d, final int resId) {
    T _xblockexpression = null;
    {
      View _get = ViewUtils.cache.get(Integer.valueOf(resId));
      boolean _equals = Objects.equal(_get, null);
      if (_equals) {
        View _findViewById = d.findViewById(resId);
        ViewUtils.cache.put(Integer.valueOf(resId), ((View) _findViewById));
      }
      View _get_1 = ViewUtils.cache.get(Integer.valueOf(resId));
      _xblockexpression = (((T) _get_1));
    }
    return _xblockexpression;
  }
  
  public static <T extends View> T getView(final View v, final int resId) {
    View _findViewById = v.findViewById(resId);
    return ((T) _findViewById);
  }
  
  public static TextView getTextView(final Dialog d, final int tvResId) {
    View _findViewById = d.findViewById(tvResId);
    return ((TextView) _findViewById);
  }
  
  public static Button getButton(final Dialog d, final int btnResId) {
    View _findViewById = d.findViewById(btnResId);
    return ((Button) _findViewById);
  }
  
  public static Spinner getSpinner(final Dialog d, final int resId) {
    View _findViewById = d.findViewById(resId);
    return ((Spinner) _findViewById);
  }
  
  public static TextView getTextView(final View v, final int tvResId) {
    View _findViewById = v.findViewById(tvResId);
    return ((TextView) _findViewById);
  }
  
  public static ListView getListView(final View v, final int tvResId) {
    View _findViewById = v.findViewById(tvResId);
    return ((ListView) _findViewById);
  }
  
  public static Button getButton(final View v, final int btnResId) {
    View _findViewById = v.findViewById(btnResId);
    return ((Button) _findViewById);
  }
  
  public static Spinner getSpinner(final View v, final int resId) {
    View _findViewById = v.findViewById(resId);
    return ((Spinner) _findViewById);
  }
}
