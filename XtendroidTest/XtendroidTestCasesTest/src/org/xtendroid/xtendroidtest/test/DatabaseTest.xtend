package org.xtendroid.xtendroidtest.test

import android.test.AndroidTestCase
import android.util.Log
import java.util.Date
import org.xtendroid.xtendroidtest.models.User

import static extension org.xtendroid.utils.TimeUtils.*
import static extension org.xtendroid.xtendroidtest.db.DbService.*

/**
 * Test the Xtendroid database service
 */
class DatabaseTest extends AndroidTestCase {
   
   def testDbLargeData() {
      context.db.delete("users")
   	
      val now = new Date      
      for(i: 0..20) {
	      context.db.insert("users", #{
	         "createdAt" -> now,
	         "firstName" -> "User " + i,
	         "lastName" -> "Surname " + i,
	         "userName" -> "username" + i,
	         "age" -> i,
	         "active" -> true 
	      })
      } 
      
      var res = context.db.findByFields("users", #{"age <=" -> 18}, null, User)
      assertNotNull(res)
      assertEquals(19, res.length)

      res = context.db.findByFields("users", #{"age <=" -> 18}, null, 5, 0, User)
      assertNotNull(res)
      assertEquals(5, res.length)

      res = context.db.findByFields("users", #{"age <=" -> 18}, null, 5, 16, User)
      assertNotNull(res)
      assertEquals(3, res.length)
   }
   
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

      var users = context.db.findAll("users", null, User)
      assertNotNull(users)
      assertEquals(1, users.length)
      assertEquals(tobyId, users.get(0).id)
      
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
      assertEquals("Toby", toby.firstName)
      assertEquals("Kurien", toby.lastName)
      assertEquals(now, toby.createdAt)
      assertEquals("tobyk", toby.userName)
      assertEquals(false, toby.active)
      assertNotNull(toby.expiryDate)
      assertEquals(expiry, toby.expiryDate)
      
      context.db.delete("users", String.valueOf(tobyId))
      users = context.db.findAll("users", null, User)
      assertNotNull(users)
      assertEquals(0, users.length)
   }
   
}