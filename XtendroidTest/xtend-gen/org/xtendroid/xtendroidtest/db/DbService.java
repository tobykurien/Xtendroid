package org.xtendroid.xtendroidtest.db;

import android.content.Context;

@SuppressWarnings("all")
public class DbService /* implements BaseDbService  */{
  protected DbService(final Context context) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method super is undefined for the type DbService");
  }
  
  public static DbService getDb(final Context context) {
    return new DbService(context);
  }
}
