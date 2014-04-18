package org.xtendroid.xtendroidtest.db;

import android.content.Context;
import org.xtendroid.db.BaseDbService;

@SuppressWarnings("all")
public class DbService extends BaseDbService {
  protected DbService(final Context context) {
    super(context, "xtendroid_test", 1);
  }
  
  public static DbService getDb(final Context context) {
    return new DbService(context);
  }
}
