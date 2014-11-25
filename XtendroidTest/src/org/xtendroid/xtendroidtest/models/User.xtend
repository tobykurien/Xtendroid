package org.xtendroid.xtendroidtest.models

import java.util.Date
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class User {
   long id
   Date createdAt
   String firstName
   String lastName
   String userName
   int age
   boolean active
   Date expiryDate
}