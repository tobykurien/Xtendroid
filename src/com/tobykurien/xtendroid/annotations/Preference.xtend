package com.tobykurien.xtendroid.annotations

import com.tobykurien.xtendroid.utils.Utils
import org.eclipse.xtend.lib.macro.AbstractFieldProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.services.TypeReferenceProvider
import static extension com.tobykurien.xtendroid.utils.Utils.* 

@Active(typeof(PreferenceProcessor))
annotation Preference {
}

class PreferenceProcessor extends AbstractFieldProcessor {

   override doTransform(MutableFieldDeclaration field, extension TransformationContext context) {
      // add synthetic init-method
      var getter = if(field.type == Boolean) "is" else "get"
      field.declaringType.addMethod(getter + field.simpleName.upperCaseFirst) [
         visibility = Visibility::PUBLIC
         returnType = field.type
         val methodName = "get" + returnType.prefMethodName
         // reassign the initializer expression to be the init method’s body
         // this automatically removes the expression as the field’s initializer
         body = [
            '''
               return pref.«methodName»("«Utils.toResourceName(field.simpleName)»", «field.simpleName»);
            '''
         ]
      ]

      // add a getter method which lazily initializes the field
      field.declaringType.addMethod("set" + field.simpleName.upperCaseFirst) [
         visibility = Visibility::PUBLIC
         returnType = context.primitiveBoolean
         val methodName = "put" + field.type.prefMethodName
         body = [
            '''
               pref.edit().«methodName»("«Utils.toResourceName(field.simpleName)»", «field.simpleName»).commit();
               return true;
            ''']
      ]
   }

   /**
    * Convert from Java type to SharedPreference method name
    */   
   def getPrefMethodName(TypeReference returnType) {
      switch (returnType.simpleName.toLowerCase) {
         case "boolean": "Boolean"
         case "long": "Long"
         case "int": "Int"
         case "string": "String"
         case "set": "StringSet"
         default: throw new IllegalStateException("Invalid preference type " + returnType)
      }      
   }
}
