package com.tobykurien.xtendroid.db;

import android.content.ContentValues;
import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import asia.sonix.android.orm.AbatisService;
import java.util.Map;
import java.util.Set;

/**
 * Base class for creating your own database service class. This
 * class ultimately inherits from SQLiteOpenHelper, so you can use standard
 * Android db code in the subclass. The constructor is protected, so
 * create a getInstance() method as follows:
 * 
 * class DbService extends BaseDbService {
 * protected DbService(Context context) {
 * super(context, "dbname", 1);
 * }
 * 
 * public static getInstance(Context context) {
 * return new DbService(context);
 * }
 * }
 */
@SuppressWarnings("all")
public class BaseDbService extends AbatisService {
  /**
   * Specify the database name and version number in the subclass
   */
  protected BaseDbService(final Context context, final String dbName, final int version) {
    super(context, dbName, version);
  }
  
  /**
   * Override this to handle database version upgrades between versions
   */
  public void onUpgrade(final SQLiteDatabase db, final int oldVersion, final int newVersion) {
  }
  
  /**
   * Generic method to insert records into the database from a Map
   * of key-value pairs.
   * @return the id of the inserted row
   */
  public long insert(final String table, final Map<String,? extends Object> values) {
    ContentValues _contentValues = new ContentValues();
    ContentValues vals = _contentValues;
    Set<String> _keySet = values.keySet();
    for (final String key : _keySet) {
      Object _get = values.get(key);
      String _valueOf = String.valueOf(_get);
      vals.put(key, _valueOf);
    }
    SQLiteDatabase db = this.getWritableDatabase();
    try {
      return db.insert(table, "", vals);
    } finally {
      db.close();
    }
  }
  
  /**
   * Generic method to update a record with the given id in the database from a Map
   * of key-value pairs.
   * @return the number of rows affected
   */
  public int update(final String table, final Map<String,? extends Object> values, final String id) {
    ContentValues _contentValues = new ContentValues();
    ContentValues vals = _contentValues;
    Set<String> _keySet = values.keySet();
    for (final String key : _keySet) {
      Object _get = values.get(key);
      String _valueOf = String.valueOf(_get);
      vals.put(key, _valueOf);
    }
    SQLiteDatabase db = this.getWritableDatabase();
    try {
      return db.update(table, vals, "id = ?", new String[] { id });
    } finally {
      db.close();
    }
  }
  
  /**
   * Delete the specified row from the specified table
   * @return the number of rows affected
   */
  public int delete(final String table, final String id) {
    SQLiteDatabase db = this.getWritableDatabase();
    try {
      return db.delete(table, "id = ?", new String[] { id });
    } finally {
      db.close();
    }
  }
  
  /**
   * Delete all rows from the specified table
   * @return the number of rows affected
   */
  public int delete(final String table) {
    SQLiteDatabase db = this.getWritableDatabase();
    try {
      return db.delete(table, "1", null);
    } finally {
      db.close();
    }
  }
}
