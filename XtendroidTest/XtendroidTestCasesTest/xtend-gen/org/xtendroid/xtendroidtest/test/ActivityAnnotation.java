package org.xtendroid.xtendroidtest.test;

import android.test.ActivityInstrumentationTestCase2;
import android.view.View;
import android.widget.TextView;
import junit.framework.Assert;
import org.xtendroid.xtendroidtest.MainActivity;
import org.xtendroid.xtendroidtest.R;

@SuppressWarnings("all")
public class ActivityAnnotation extends ActivityInstrumentationTestCase2<MainActivity> {
  public ActivityAnnotation() {
    super(MainActivity.class);
  }
  
  public void testAnnotation() {
    MainActivity _activity = this.getActivity();
    View _findViewById = _activity.findViewById(R.id.main_hello);
    final TextView tv = ((TextView) _findViewById);
    MainActivity _activity_1 = this.getActivity();
    String _string = _activity_1.getString(R.string.hello_world);
    CharSequence _text = tv.getText();
    Assert.assertEquals(_string, _text);
  }
}
