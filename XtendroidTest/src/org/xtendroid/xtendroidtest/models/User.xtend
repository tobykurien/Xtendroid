package org.xtendroid.xtendroidtest.models

import java.util.Date
import org.eclipse.xtend.lib.annotations.Accessors
import org.xtendroid.parcel.AndroidParcelable

@Accessors @AndroidParcelable class User {
   long id
   Date createdAt
   String firstName
   String lastName
   String userName
   int age
   boolean active
   Date expiryDate

   new(String firstName, String lastName) {
      this.firstName = firstName
      this.lastName = lastName
   }

   override toString() {
      '''«firstName» «lastName»'''
   }
}