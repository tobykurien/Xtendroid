package org.xtendroid.xtendroidtest.test

import android.test.AndroidTestCase
import java.util.Date

import static extension org.xtendroid.xtendroidtest.db.DbService.*
import org.xtendroid.xtendroidtest.models.User

class DatabaseTest extends AndroidTestCase {
   
   def testDbBasic() {
      context.db.delete("users")

      val now = new Date      
      var tobyId = context.db.insert("users", #{
         "createdAt" -> now,
         "firstName" -> "Toby",
         "lastName" -> "Kurien",
         "userName" -> "tobykurien",
         "active" -> true 
      })
      
      var toby = context.db.findById("users", tobyId, User)
      assertNotNull(toby)
      assertEquals("Toby", toby.firstName)
      assertEquals("Kurien", toby.lastName)
      assertEquals(now, toby.createdAt)
      assertEquals(true, toby.active)
      assertNull(toby.expiryDate)
   }
   
}