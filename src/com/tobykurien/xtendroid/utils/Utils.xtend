package com.tobykurien.xtendroid.utils

import java.lang.reflect.Method

class Utils {
   /**
    * Convert Java bean getter name into resource name format, i.e.
    * getFirstName -> first_name
    * isToast -> toast
    */   
   def static toResourceName(Method m) {
      var name = m.name
      if (m.name.startsWith("get")) {
         name = m.name.substring(3)
      } else if (m.name.startsWith("is")) {
         name = m.name.substring(2)
      }
      toResourceName(name)
   }

   /**
    * Convert from Java-style camel case to resource-style lowercase with underscores, e.g.
    * FirstName -> first_name
    */   
   def static toResourceName(String name) {
      name.replaceAll("(?=[\\p{Lu}])","_").toLowerCase().replaceAll("^_","");
   }
   
   /**
    * Uppercase first letter for using a resource as getter/setter
    */
   def static upperCaseFirst(String str) {
      Character.toUpperCase(str.charAt(0)) + str.substring(1)
   }
}