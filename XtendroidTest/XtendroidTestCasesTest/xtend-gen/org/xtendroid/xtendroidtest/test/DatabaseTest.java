package org.xtendroid.xtendroidtest.test;

import android.content.Context;
import android.test.AndroidTestCase;
import android.test.suitebuilder.annotation.SmallTest;
import com.google.common.collect.Maps;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;
import junit.framework.Assert;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.IntegerRange;
import org.xtendroid.utils.TimeUtils;
import org.xtendroid.xtendroidtest.db.DbService;
import org.xtendroid.xtendroidtest.models.User;

/**
 * Test the Xtendroid database service
 */
@SmallTest
@SuppressWarnings("all")
public class DatabaseTest extends AndroidTestCase {
  public void testDbLargeData() {
    Context _context = this.getContext();
    DbService _db = DbService.getDb(_context);
    _db.delete("users");
    final Date now = new Date();
    IntegerRange _upTo = new IntegerRange(0, 30);
    for (final Integer i : _upTo) {
      Context _context_1 = this.getContext();
      DbService _db_1 = DbService.getDb(_context_1);
      Map<String,Object> _xsetliteral = null;
      Map<String,Object> _tempMap = Maps.<String, Object>newHashMap();
      _tempMap.put("createdAt", now);
      _tempMap.put("firstName", ("User " + i));
      _tempMap.put("lastName", ("Surname " + i));
      _tempMap.put("userName", ("username" + i));
      _tempMap.put("age", i);
      _tempMap.put("active", Boolean.valueOf(true));
      _xsetliteral = Collections.<String, Object>unmodifiableMap(_tempMap);
      _db_1.insert("users", _xsetliteral);
    }
    Context _context_2 = this.getContext();
    DbService _db_2 = DbService.getDb(_context_2);
    Map<String,Integer> _xsetliteral_1 = null;
    Map<String,Integer> _tempMap_1 = Maps.<String, Integer>newHashMap();
    _tempMap_1.put("age <=", Integer.valueOf(18));
    _xsetliteral_1 = Collections.<String, Integer>unmodifiableMap(_tempMap_1);
    List<User> res = _db_2.<User>findByFields("users", _xsetliteral_1, null, User.class);
    Assert.assertNotNull(res);
    final List<User> _converted_res = (List<User>)res;
    int _length = ((Object[])Conversions.unwrapArray(_converted_res, Object.class)).length;
    Assert.assertEquals(19, _length);
    Context _context_3 = this.getContext();
    DbService _db_3 = DbService.getDb(_context_3);
    Map<String,Integer> _xsetliteral_2 = null;
    Map<String,Integer> _tempMap_2 = Maps.<String, Integer>newHashMap();
    _tempMap_2.put("age <=", Integer.valueOf(18));
    _xsetliteral_2 = Collections.<String, Integer>unmodifiableMap(_tempMap_2);
    List<User> _findByFields = _db_3.<User>findByFields("users", _xsetliteral_2, null, 5, 0, User.class);
    res = _findByFields;
    Assert.assertNotNull(res);
    final List<User> _converted_res_1 = (List<User>)res;
    int _length_1 = ((Object[])Conversions.unwrapArray(_converted_res_1, Object.class)).length;
    Assert.assertEquals(5, _length_1);
    Context _context_4 = this.getContext();
    DbService _db_4 = DbService.getDb(_context_4);
    Map<String,Integer> _xsetliteral_3 = null;
    Map<String,Integer> _tempMap_3 = Maps.<String, Integer>newHashMap();
    _tempMap_3.put("age <=", Integer.valueOf(18));
    _xsetliteral_3 = Collections.<String, Integer>unmodifiableMap(_tempMap_3);
    List<User> _findByFields_1 = _db_4.<User>findByFields("users", _xsetliteral_3, null, 5, 16, User.class);
    res = _findByFields_1;
    Assert.assertNotNull(res);
    final List<User> _converted_res_2 = (List<User>)res;
    int _length_2 = ((Object[])Conversions.unwrapArray(_converted_res_2, Object.class)).length;
    Assert.assertEquals(3, _length_2);
  }
  
  public void testDbBasic() {
    Context _context = this.getContext();
    DbService _db = DbService.getDb(_context);
    _db.delete("users");
    final Date now = new Date();
    Context _context_1 = this.getContext();
    DbService _db_1 = DbService.getDb(_context_1);
    Map<String,Object> _xsetliteral = null;
    Map<String,Object> _tempMap = Maps.<String, Object>newHashMap();
    _tempMap.put("createdAt", now);
    _tempMap.put("firstName", "Toby");
    _tempMap.put("lastName", "Kurien");
    _tempMap.put("userName", "tobykurien");
    _tempMap.put("active", Boolean.valueOf(true));
    _xsetliteral = Collections.<String, Object>unmodifiableMap(_tempMap);
    long tobyId = _db_1.insert("users", _xsetliteral);
    Context _context_2 = this.getContext();
    DbService _db_2 = DbService.getDb(_context_2);
    List<User> users = _db_2.<User>findAll("users", null, User.class);
    Assert.assertNotNull(users);
    final List<User> _converted_users = (List<User>)users;
    int _length = ((Object[])Conversions.unwrapArray(_converted_users, Object.class)).length;
    Assert.assertEquals(1, _length);
    User _get = users.get(0);
    long _id = _get.getId();
    Assert.assertEquals(tobyId, _id);
    Context _context_3 = this.getContext();
    DbService _db_3 = DbService.getDb(_context_3);
    User toby = _db_3.<User>findById("users", tobyId, User.class);
    Assert.assertNotNull(toby);
    String _firstName = toby.getFirstName();
    Assert.assertEquals("Toby", _firstName);
    String _lastName = toby.getLastName();
    Assert.assertEquals("Kurien", _lastName);
    String _userName = toby.getUserName();
    Assert.assertEquals("tobykurien", _userName);
    Date _createdAt = toby.getCreatedAt();
    Assert.assertEquals(now, _createdAt);
    boolean _isActive = toby.isActive();
    Assert.assertEquals(true, _isActive);
    Date _expiryDate = toby.getExpiryDate();
    Assert.assertNull(_expiryDate);
    long _currentTimeMillis = System.currentTimeMillis();
    long _hours = TimeUtils.hours(24);
    long _plus = (_currentTimeMillis + _hours);
    final Date expiry = new Date(_plus);
    Context _context_4 = this.getContext();
    DbService _db_4 = DbService.getDb(_context_4);
    Map<String,Object> _xsetliteral_1 = null;
    Map<String,Object> _tempMap_1 = Maps.<String, Object>newHashMap();
    _tempMap_1.put("username", "tobyk");
    _tempMap_1.put("active", Boolean.valueOf(false));
    _tempMap_1.put("expiryDate", expiry);
    _xsetliteral_1 = Collections.<String, Object>unmodifiableMap(_tempMap_1);
    _db_4.update("users", _xsetliteral_1, tobyId);
    Context _context_5 = this.getContext();
    DbService _db_5 = DbService.getDb(_context_5);
    User _findById = _db_5.<User>findById("users", tobyId, User.class);
    toby = _findById;
    Assert.assertNotNull(toby);
    String _firstName_1 = toby.getFirstName();
    Assert.assertEquals("Toby", _firstName_1);
    String _lastName_1 = toby.getLastName();
    Assert.assertEquals("Kurien", _lastName_1);
    Date _createdAt_1 = toby.getCreatedAt();
    Assert.assertEquals(now, _createdAt_1);
    String _userName_1 = toby.getUserName();
    Assert.assertEquals("tobyk", _userName_1);
    boolean _isActive_1 = toby.isActive();
    Assert.assertEquals(false, _isActive_1);
    Date _expiryDate_1 = toby.getExpiryDate();
    Assert.assertNotNull(_expiryDate_1);
    Date _expiryDate_2 = toby.getExpiryDate();
    Assert.assertEquals(expiry, _expiryDate_2);
    Context _context_6 = this.getContext();
    DbService _db_6 = DbService.getDb(_context_6);
    String _valueOf = String.valueOf(tobyId);
    _db_6.delete("users", _valueOf);
    Context _context_7 = this.getContext();
    DbService _db_7 = DbService.getDb(_context_7);
    List<User> _findAll = _db_7.<User>findAll("users", null, User.class);
    users = _findAll;
    Assert.assertNotNull(users);
    final List<User> _converted_users_1 = (List<User>)users;
    int _length_1 = ((Object[])Conversions.unwrapArray(_converted_users_1, Object.class)).length;
    Assert.assertEquals(0, _length_1);
  }
}
