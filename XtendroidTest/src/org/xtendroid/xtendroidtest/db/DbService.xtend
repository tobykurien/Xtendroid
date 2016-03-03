package org.xtendroid.xtendroidtest.db

import android.content.Context
import org.xtendroid.db.AndroidDatabase

@AndroidDatabase class DbService {
   
   new(Context context) {
      super(context, "xtendroid_test", 1)
   }

}