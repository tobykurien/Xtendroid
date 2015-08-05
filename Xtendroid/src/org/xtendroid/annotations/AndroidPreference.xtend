package org.xtendroid.annotations

import java.util.List
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMemberDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.xtendroid.utils.BasePreferences
import org.xtendroid.utils.NamingUtils
import android.content.Context
import android.app.Fragment

@Active(AndroidPreferenceProcessor)
annotation AndroidPreference {
}

class AndroidPreferenceProcessor implements TransformationParticipant<MutableMemberDeclaration> {

	override doTransform(List<? extends MutableMemberDeclaration> elements, TransformationContext context) {
		elements.forEach[e|e.transform(context)]
	}

	def dispatch void transform(MutableClassDeclaration clazz, extension TransformationContext context) {
      
		// extend BasePreferences
      if (clazz.extendedClass == Object.newTypeReference()) {
         clazz.extendedClass = BasePreferences.newTypeReference
      }    

		// add singleton instance getter
      clazz.addMethod("get" + clazz.simpleName) [
         addParameter("context", Context.newTypeReference)
         setReturnType(clazz.newTypeReference())
         setStatic(true)
         body = '''
            return BasePreferences.getPreferences(context, «clazz.simpleName».class);
         '''
      ]
		
		// add a getter for fragments too
      clazz.addMethod("get" + clazz.simpleName) [
         addParameter("fragment", Fragment.newTypeReference)
         setReturnType(clazz.newTypeReference())
         setStatic(true)
         body = '''
            return BasePreferences.getPreferences(fragment.getActivity(), «clazz.simpleName».class);
         '''
      ]
 
 		clazz.declaredFields.forEach[f| 
			if (f.visibility == Visibility.PRIVATE && f.annotations.empty) 
				f.doTransform(context)
		]
	}

	def dispatch void transform(MutableFieldDeclaration it, extension TransformationContext context) {
		it.doTransform(context)
	}

	def doTransform(MutableFieldDeclaration field, extension TransformationContext context) {
      if (field.initializer == null)
      {
         field.addError("A Preference field must have an initializer.")      	
      }
      if (field.type.isInferred)
      {
         field.addError("A Preference field must have an explicit type.")
         return;      	
      }
      
      val clazz = field.declaringType     
      val isTypeOfBasePreferences = BasePreferences.newTypeReference.isAssignableFrom(clazz.newTypeReference)
		if (!isTypeOfBasePreferences)
		{
			clazz.addError('This class must extend org.xtendroid.utils.BasePreferences')
		}

      field.markAsRead
      // add synthetic init-method
      var getter = if (field.type.simpleName.equalsIgnoreCase("Boolean")) "is" else "get"
      field.declaringType.addMethod(getter + field.simpleName.toFirstUpper) [
         visibility = Visibility.PUBLIC
         returnType = field.type
         val methodName = "get" + returnType.prefMethodName
         // reassign the initializer expression to be the init method’s body
         // this automatically removes the expression as the field’s initializer
         body = '''
            return pref.«methodName»("«NamingUtils.toResourceName(field.simpleName)»", «field.simpleName»);
         '''
      ]

      // add a getter method which lazily initializes the field
      field.declaringType.addMethod("set" + field.simpleName.toFirstUpper) [
         visibility = Visibility.PUBLIC
         returnType = context.primitiveBoolean
         addParameter("value", field.type)
         val methodName = "put" + field.type.prefMethodName
         body = '''
            pref.edit().«methodName»("«NamingUtils.toResourceName(field.simpleName)»", value).apply();
            return true;
         '''
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
