package org.xtendroid.xtendroidtest.test

import android.test.AndroidTestCase
import java.util.Date
import org.xtendroid.xtendroidtest.models.User

import static extension org.xtendroid.utils.TimeUtils.*
import static extension org.xtendroid.xtendroidtest.db.DbService.*

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
      assertEquals("tobykurien", toby.userName)
      assertEquals(now, toby.createdAt)
      assertEquals(true, toby.active)
      assertNull(toby.expiryDate)
      
      val expiry = new Date(System.currentTimeMillis + 24.hours)
      context.db.update("users", #{
         "username" -> "tobyk",
         "active" -> false,
         "expiryDate" -> expiry
      }, tobyId)
      
      toby = context.db.findById("users", tobyId, User)
      assertNotNull(toby)
      assertEquals("tobyk", toby.userName)
      assertEquals(false, toby.active)
      assertNotNull(toby.expiryDate)
      assertEquals(expiry, toby.expiryDate)
      
      context.db.delete("users", String.valueOf(tobyId))
      var users = context.db.findAll("users", null, User)
      assertNotNull(users)
      assertEquals(0, users.length)
   }
   
}