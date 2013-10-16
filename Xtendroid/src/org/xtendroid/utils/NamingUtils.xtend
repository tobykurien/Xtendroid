package org.xtendroid.utils

import java.lang.reflect.Method

class NamingUtils {
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
   
   def static toJavaIdentifier(String string) {
      var boolean makeCamelCase = false
      val result = new StringBuilder()
      val char underScore = '_'
      for (c : string.toCharArray) {
         switch c {
            case underScore : {
               makeCamelCase = true
            }
            case Character.isJavaIdentifierPart(c) : {
               if (makeCamelCase) {
                  result.append(Character.toUpperCase(c))
                  makeCamelCase = false
               } else {
                  result.append(c)
               }
            }
            default : result.append(underScore)
         }
      }
      return result.toString
   }
   
}