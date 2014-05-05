package org.xtendroid.xtendroidtest;

import android.app.Activity;
import android.os.Bundle;
import android.widget.ListView;
import android.widget.TextView;
import org.xtendroid.adapter.BeanAdapter;
import org.xtendroid.app.AndroidActivity;
import org.xtendroid.app.OnCreate;
import org.xtendroid.db.LazyList;
import org.xtendroid.xtendroidtest.MainActivity_CallBacks;
import org.xtendroid.xtendroidtest.R;
import org.xtendroid.xtendroidtest.db.DbService;
import org.xtendroid.xtendroidtest.models.ManyItem;

@AndroidActivity(layout = R.layout.activity_main)
@SuppressWarnings("all")
public class MainActivity extends Activity implements MainActivity_CallBacks {
  @OnCreate
  public void create(final Bundle savedInstanceState) {
    TextView _mainHello = this.getMainHello();
    String _string = this.getString(R.string.hello_world);
    _mainHello.setText(_string);
    DbService _db = DbService.getDb(this);
    LazyList<ManyItem> manyItems = _db.<ManyItem>lazyFindAll("manyitems", "id", ManyItem.class);
    ListView _mainList = this.getMainList();
    BeanAdapter<ManyItem> _beanAdapter = new BeanAdapter<ManyItem>(this, R.layout.main_list_row, manyItems);
    _mainList.setAdapter(_beanAdapter);
  }
  
  public void onCreate(final Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_main);
    create(savedInstanceState);
  }
  
  public TextView getMainHello() {
    return (TextView) findViewById(R.id.main_hello);
  }
  
  public ListView getMainList() {
    return (ListView) findViewById(R.id.main_list);
  }
}
