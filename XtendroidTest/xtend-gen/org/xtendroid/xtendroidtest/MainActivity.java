package org.xtendroid.xtendroidtest;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.widget.ListView;
import android.widget.TextView;
import org.xtendroid.adapter.BeanAdapter;
import org.xtendroid.app.AndroidActivity;
import org.xtendroid.app.OnCreate;
import org.xtendroid.db.LazyList;
import org.xtendroid.xtendroidtest.MainActivity_CallBacks;
import org.xtendroid.xtendroidtest.R;
import org.xtendroid.xtendroidtest.SettingsActivity;
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
  
  public boolean onCreateOptionsMenu(final Menu menu) {
    boolean _xblockexpression = false;
    {
      MenuInflater _menuInflater = this.getMenuInflater();
      _menuInflater.inflate(org.xtendroid.xtendroidtest.R.menu.main, menu);
      _xblockexpression = true;
    }
    return _xblockexpression;
  }
  
  public boolean onOptionsItemSelected(final MenuItem item) {
    boolean _xblockexpression = false;
    {
      int _itemId = item.getItemId();
      switch (_itemId) {
        case R.id.action_settings:
          final Intent intent = new Intent(this, SettingsActivity.class);
          this.startActivity(intent);
          break;
      }
      _xblockexpression = super.onOptionsItemSelected(item);
    }
    return _xblockexpression;
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
