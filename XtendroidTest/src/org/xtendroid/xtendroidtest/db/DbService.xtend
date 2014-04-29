package org.xtendroid.xtendroidtest.db

import android.content.Context
import org.xtendroid.db.BaseDbService

class DbService extends BaseDbService {
   
   protected new(Context context) {
      super(context, "xtendroid_test", 1)
   }

   // convenience method for syntactic sugar
   def static getDb(Context context) {
      return new DbService(context)
   }         
}