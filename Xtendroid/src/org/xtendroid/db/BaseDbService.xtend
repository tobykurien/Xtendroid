package org.xtendroid.db

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import asia.sonix.android.orm.AbatisService
import java.util.Date
import java.util.List
import java.util.Map

/**
 * Base class for creating your own database service class. This 
 * class ultimately inherits from SQLiteOpenHelper, so you can use standard
 * Android db code in the subclass. The constructor is protected, so
 * create a getInstance() method as follows:
 * 
         class DbService extends BaseDbService {
            protected DbService(Context context) {
               super(context, "dbname", 1);
            }
         
            public static getInstance(Context context) {
               return new DbService(context);
            }
         }
 */
class BaseDbService extends AbatisService {
   /**
    * Specify the database name and version number in the subclass
    */
   protected new(Context context, String dbName, int version) {
      super(context, dbName, version)
   }
   
   /**
    * Override this to handle database version upgrades between versions
    */
   override onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
   }

   /**
    * Find an object by it's id
    */
   def <T> T findById(String table, long id, Class<T> bean) {
      super.<T>executeForBean(
         '''select * from «table» where id = #id#''',
         #{ 'id' -> id },
         bean
      )
   }

   /**
    * Find all objects in a table
    */
   def <T> List<T> findAll(String table, String orderBy, Class<T> bean) {
      this.<T>findByFields(table, #{}, orderBy, bean)
   }

   /**
    * Find an object by fields
    */
   def <T> List<T> findByFields(String table, Map<String, ? extends Object> values, String orderBy, Class<T> bean) {
      var where = values.keySet.fold("") [res, key|
         if (res.length == 0) '''«key» = #«key»#'''
         else '''«res» and «key» = #«key»#'''
      ]
      
      var order = ""
      if (orderBy != null && orderBy.trim.length > 0) {
         order = "order by " + orderBy
      } 
            
      super.<T>executeForBeanList(
         '''select * from «table» where «where» «order»''',
         values,
         bean
      )
   }

   /**
    * Convert the Map object into ContentValues object
    */
   def ContentValues getContentValues(Map<String, ? extends Object> values) {
      var vals = new ContentValues()
      for (String key : values.keySet) {
         var value = values.get(key)
         if (value instanceof Date) {
            vals.put(key, (value as Date).time)
         } else {
            vals.put(key, String.valueOf(value))
         }
      }
      vals
   }

   /**
    * Generic method to insert records into the database from a Map
    * of key-value pairs.
    * @return the id of the inserted row
    */
   def insert(String table, Map<String, ? extends Object> values) {
      var db = writableDatabase
      try {
         return db.insert(table, "", values.contentValues)
      } finally {
         db.close()
      }
   }
   
   /**
    * Generic method to update a record with the given id in the database from a Map
    * of key-value pairs.
    * @return the number of rows affected
    */
   def update(String table, Map<String, ?> values, long id) {
      update(table, values, String.valueOf(id))
   }

   def update(String table, Map<String, ? extends Object> values, String id) {
      var db = writableDatabase
      try {
         return db.update(table, values.contentValues, "id = ?", #[id])
      } finally {
         db.close()
      }
   }
   
   /**
    * Delete the specified row from the specified table
    * @return the number of rows affected
    */
   def delete(String table, String id) {
      var db = writableDatabase
      try {
         return db.delete(table, "id = ?", #[id])
      } finally {
         db.close()
      }
   }   

   /**
    * Delete all rows from the specified table
    * @return the number of rows affected
    */
   def delete(String table) {
      var db = writableDatabase
      try {
         return db.delete(table, "1", null)
      } finally {
         db.close()
      }
   }   

}