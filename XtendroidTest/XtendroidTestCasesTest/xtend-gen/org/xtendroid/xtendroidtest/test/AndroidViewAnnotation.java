package org.xtendroid.xtendroidtest.test;

import android.test.ActivityInstrumentationTestCase2;
import android.view.View;
import android.widget.TextView;
import junit.framework.Assert;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.xtendroid.xtendroidtest.MainActivity2;
import org.xtendroid.xtendroidtest.R;

@SuppressWarnings("all")
public class AndroidViewAnnotation extends ActivityInstrumentationTestCase2<MainActivity2> {
  public AndroidViewAnnotation() {
    super(MainActivity2.class);
  }
  
  public void testAnnotation() {
    try {
      MainActivity2 _activity = this.getActivity();
      final TextView annotationTv = ((MainActivity2) _activity).getMainHello();
      MainActivity2 _activity_1 = this.getActivity();
      View _findViewById = _activity_1.findViewById(R.id.main_hello);
      final TextView tv = ((TextView) _findViewById);
      MainActivity2 _activity_2 = this.getActivity();
      String _string = _activity_2.getString(R.string.hello_world);
      CharSequence _text = tv.getText();
      Assert.assertEquals(_string, _text);
      int _id = annotationTv.getId();
      int _id_1 = tv.getId();
      Assert.assertEquals(_id, _id_1);
      MainActivity2 _activity_3 = this.getActivity();
      final Runnable _function = new Runnable() {
        public void run() {
          annotationTv.setText("Testing");
          CharSequence _text = annotationTv.getText();
          CharSequence _text_1 = tv.getText();
          Assert.assertEquals(_text, _text_1);
        }
      };
      _activity_3.runOnUiThread(_function);
      Thread.sleep(1000);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
