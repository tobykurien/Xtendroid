package org.xtendroid.xtendroidtest.test;

import android.content.Context;
import android.test.AndroidTestCase;
import android.test.suitebuilder.annotation.SmallTest;
import android.util.Log;
import com.google.common.collect.Maps;
import java.util.Collections;
import java.util.Date;
import java.util.Map;
import junit.framework.Assert;
import org.eclipse.xtext.xbase.lib.IntegerRange;
import org.xtendroid.db.LazyList;
import org.xtendroid.utils.TimeUtils;
import org.xtendroid.xtendroidtest.db.DbService;
import org.xtendroid.xtendroidtest.models.ManyItem;

@SmallTest
@SuppressWarnings("all")
public class DbLazyList extends AndroidTestCase {
  public void setUp() {
    Context _context = this.getContext();
    DbService _db = DbService.getDb(_context);
    Map<String, Object> res = _db.executeForMap("select count(*) as cnt from manyItems", null);
    Object _get = res.get("cnt");
    int _parseInt = Integer.parseInt(((String) _get));
    boolean _lessThan = (_parseInt < 1000);
    if (_lessThan) {
      Context _context_1 = this.getContext();
      DbService _db_1 = DbService.getDb(_context_1);
      _db_1.delete("manyItems");
      IntegerRange _upTo = new IntegerRange(1, 1000);
      for (final Integer i : _upTo) {
        Context _context_2 = this.getContext();
        DbService _db_2 = DbService.getDb(_context_2);
        Map<String, Object> _xsetliteral = null;
        Date _now = TimeUtils.now();
        Map<String, Object> _tempMap = Maps.<String, Object>newHashMap();
        _tempMap.put("createdAt", _now);
        _tempMap.put("itemName", ("Item " + i));
        _tempMap.put("itemOrder", i);
        _xsetliteral = Collections.<String, Object>unmodifiableMap(_tempMap);
        _db_2.insert("manyItems", _xsetliteral);
      }
    }
  }
  
  public void testLazyList() {
    Context _context = this.getContext();
    DbService _db = DbService.getDb(_context);
    LazyList<ManyItem> list = _db.<ManyItem>lazyFindAll("manyItems", null, ManyItem.class);
    Assert.assertNotNull(list);
    int _size = list.size();
    Assert.assertEquals(1000, _size);
    IntegerRange _upTo = new IntegerRange(205, 900);
    for (final Integer i : _upTo) {
      {
        ManyItem _get = list.get((i).intValue());
        String _itemName = _get.getItemName();
        String _plus = ("Got " + _itemName);
        Log.d("lazylisttest", _plus);
        ManyItem _get_1 = list.get((i).intValue());
        String _itemName_1 = _get_1.getItemName();
        Assert.assertEquals(("Item " + Integer.valueOf(((i).intValue() + 1))), _itemName_1);
      }
    }
    ManyItem _get = list.get(0);
    String _itemName = _get.getItemName();
    Assert.assertEquals("Item 1", _itemName);
    ManyItem _get_1 = list.get(204);
    String _itemName_1 = _get_1.getItemName();
    Assert.assertEquals("Item 205", _itemName_1);
    ManyItem _get_2 = list.get(999);
    String _itemName_2 = _get_2.getItemName();
    Assert.assertEquals("Item 1000", _itemName_2);
  }
  
  public void tearDown() {
  }
}
