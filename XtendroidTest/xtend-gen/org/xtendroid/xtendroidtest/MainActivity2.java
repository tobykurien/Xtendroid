package org.xtendroid.xtendroidtest;

import android.app.Activity;
import android.os.Bundle;
import android.widget.ListView;
import android.widget.TextView;
import org.xtendroid.xtendroidtest.R;

@SuppressWarnings("all")
public class MainActivity2 extends Activity {
  protected void onCreate(final Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    this.setContentView(R.layout.activity_main);
    TextView _mainHello = this.getMainHello();
    String _string = this.getString(R.string.hello_world);
    _mainHello.setText(_string);
  }
  
  private TextView _init_mainHello() {
    return (TextView) findViewById(R.id.main_hello);
  }
  
  public TextView getMainHello() {
    if (_mainHello==null)
    _mainHello = _init_mainHello();
    return _mainHello;
  }
  
  private TextView _mainHello;
  
  private ListView _init_mainList() {
    return (ListView) findViewById(R.id.main_list);
  }
  
  public ListView getMainList() {
    if (_mainList==null)
    _mainList = _init_mainList();
    return _mainList;
  }
  
  private ListView _mainList;
}
