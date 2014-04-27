package org.xtendroid.xtendroidtest.models

import java.util.Date

class User {
   @Property long id
   @Property Date createdAt
   @Property String firstName
   @Property String lastName
   @Property String userName
   @Property int age
   @Property boolean active
   @Property Date expiryDate
}