package org.xtendroid.xtendroidtest;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;
import org.xtendroid.app.AndroidActivity;
import org.xtendroid.app.OnCreate;
import org.xtendroid.xtendroidtest.MainActivity_CallBacks;
import org.xtendroid.xtendroidtest.R;

@AndroidActivity(layout = R.layout.activity_main)
@SuppressWarnings("all")
public class MainActivity extends Activity implements MainActivity_CallBacks {
  @OnCreate
  public void create(final Bundle savedInstanceState) {
    TextView _mainHello = this.getMainHello();
    String _string = this.getString(R.string.hello_world);
    _mainHello.setText(_string);
  }
  
  public void onCreate(final Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_main);
    create(savedInstanceState);
  }
  
  public TextView getMainHello() {
    return (TextView) findViewById(R.id.main_hello);
  }
}
