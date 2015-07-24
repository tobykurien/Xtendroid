package org.xtendroid.annotations

import android.app.Activity
import android.app.Fragment
import android.content.Intent
import android.os.Bundle
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractFieldProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import android.os.Parcelable
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import java.util.ArrayList

@Active(BundlePropertyProcessor)
@Target(ElementType.FIELD)
annotation BundleProperty {
   String value = ''
}

class BundlePropertyProcessor extends AbstractFieldProcessor {
	
	val mapTypeToIntentPutInFix = #{
   		'ArrayList<String>' -> 'StringArrayList',
   		'ArrayList<Integer>' -> 'IntegerArrayList',
   		'ArrayList<CharSequence>' -> 'CharSequenceArrayList'
	}

   val mapTypeToMethodName = #{
      'Bundle' -> 'Bundle', // 'All'-> 'Bundle, the difference, is that 'All' does not require a key.
      'IBinder' -> 'Binder',
      'boolean' -> 'Boolean',
      'boolean[]' -> 'BooleanArray',
      'byte' -> 'Byte',
      'byte[]' -> 'ByteArray',
      'char' -> 'Char',
      'char[]' -> 'CharArray',
      'CharSequence' -> 'CharSequence',
      'CharSequence[]' -> 'CharSequenceArray',
      'ArrayList<CharSequence>' -> 'CharSequenceArrayList',
      'double' -> 'Double',
      'double[]' -> 'DoubleArray',
      'float' -> 'Float',
      'float[]' -> 'FloatArray',
      'int' -> 'Int',
      'int[]' -> 'IntArray',
      'ArrayList<Integer>' -> 'IntegerArrayList',
      'long' -> 'Long',
      'long[]' -> 'LongArray',
      'Parcelable' -> 'Parcelable',
      'Parcelable[]' -> 'ParcelableArray',
      'ArrayList<Parcelable>' -> 'ParcelableArrayList',
      'Serializable' -> 'Serializable',
      'short' -> 'Short',
      'short[]' -> 'ShortArray',
      'SparseArray<? extends Parcelable>' -> 'SparseParcelableArray',
      'SparseArray<Parcelable>' -> 'SparseParcelableArray',
      'String' -> 'String',
      'String[]' -> 'StringArray',
      'ArrayList<String>' -> 'StringArrayList'
   }

   val mapTypeToNilValue = #{
      'Bundle' -> 'null', // 'All'-> 'Bundle, the difference, is that 'All' does not require a key.
      'IBinder' -> 'null',
      'boolean' -> 'false',
      'boolean[]' -> 'null',
      'byte' -> '0',
      'byte[]' -> 'null',
      'char' -> "'\\0'",
      'char[]' -> 'null',
      'CharSequence' -> 'special', // special case
      'CharSequence[]' -> 'null',
      'ArrayList<CharSequence>' -> 'null',
      'double' -> '0.0',
      'double[]' -> 'null',
      'float' -> '0.0f',
      'float[]' -> 'null',
      'int' -> '0',
      'int[]' -> 'null',
      'ArrayList<Integer>' -> 'null',
      'long' -> '0',
      'long[]' -> 'null',
      'Parcelable' -> 'null',
      'Parcelable[]' -> 'null',
      'ArrayList<Parcelable>' -> 'null',
      'Serializable' -> 'null',
      'short' -> '0',
      'short[]' -> 'null',
      'SparseArray<? extends Parcelable>' -> 'null',
      'SparseArray<Parcelable>' -> 'null',
      'String' -> 'null',
      'String[]' -> 'null',
      'ArrayList<String>' -> 'null'
   }

   override doTransform(MutableFieldDeclaration field, extension TransformationContext context) {

      val clazz = field.declaringType

      if (field.type.inferred) {
         field.addError(
            'You must explicitly declare the type of this field, for this annotation to function correctly.')
      }
            
      val isDataSourceActivity = Activity.findTypeGlobally.isAssignableFrom(clazz)
      val isDataSourceFragment = Fragment.findTypeGlobally.isAssignableFrom(clazz) ||
         android.support.v4.app.Fragment.findTypeGlobally.isAssignableFrom(clazz)

      //		val bundleField = clazz.declaredFields.findFirst[f|f.type.equals(Bundle.newTypeReference)
      //			&& (f.annotations.findFirst[a|a.equals(BundleProperty.newAnnotationReference)] == null)
      //		]
      val intentField = clazz.declaredFields.findFirst[type == Intent.newTypeReference]

      val prefix = context.determinePrefix(field, isDataSourceActivity, isDataSourceFragment, intentField)

      val alias = field.findAnnotation(BundleProperty.findTypeGlobally)?.getStringValue('value')

      val fieldName = field.simpleName.santizedName

      if (!clazz.declaredFields.exists[f|
         f.simpleName.equalsIgnoreCase('_bundleHolder') && f.type == Bundle.newTypeReference]) {
         clazz.addField('_bundleHolder') [
            visibility = Visibility.PRIVATE
            type = Bundle.newTypeReference
         ]
      }

      if (intentField == null && !isDataSourceFragment &&
         !clazz.declaredFields.exists[f|
            f.simpleName.equalsIgnoreCase('_intentHolder') && f.type == Intent.newTypeReference]) {
         clazz.addField('_intentHolder') [
            visibility = Visibility.PRIVATE
            type = Intent.newTypeReference
         ]
      }

      val getterMethodDefaultName = "get" + fieldName.toFirstUpper + 'Default'
      val fieldInitializer = field.initializer

      // add get method
      val getterMethodName = "get" + fieldName.toFirstUpper
      val keyValue = if(alias.nullOrEmpty) fieldName else alias
      if (!clazz.declaredMethods.exists[m|m.simpleName.equalsIgnoreCase(getterMethodName)]) {
         field.markAsRead
         clazz.addMethod(getterMethodName) [
            visibility = Visibility.PUBLIC
            returnType = field.type
            body = '''
               «IF isDataSourceFragment»
                  «IF field.type.primitive || fieldInitializer != null»
                     «field.type.name» «field.simpleName» = «prefix».get«mapTypeToMethodName.get(field.type.simpleName)»("«keyValue»"«IF mapTypeToNilValue.get(field.type.simpleName) != 'null'», «getterMethodDefaultName»()«ENDIF»);
                     «IF mapTypeToNilValue.get(field.type.simpleName) == 'null'»
                     	return «field.simpleName» == «mapTypeToNilValue.get(field.type.simpleName)» ? «field.simpleName» : «getterMethodDefaultName»();
                     «ELSE»
                     	return «field.simpleName»;
                     «ENDIF»
                  «ELSEIF field.isParcelable(context)»
                  	 return «prefix».get«field.parcelableSuffix»("«keyValue»"); 
                  «ELSE»
                     return «prefix».get«mapTypeToMethodName.get(field.type.simpleName)»("«keyValue»");
                  «ENDIF»
				««« /* if activity or pojo */
               «ELSE»
				  «IF field.isParcelable(context)»
				     return «prefix».get«field.parcelableSuffix»Extra("«keyValue»"); 
                  «ELSEIF field.type.primitive»
                     return «prefix».get«mapTypeToMethodName.get(field.type.simpleName)»Extra("«keyValue»", «getterMethodDefaultName»());
                  «ELSEIF fieldInitializer != null»
                     «field.type.name» «fieldName» = «prefix».get«mapTypeToMethodName.get(field.type.simpleName)»Extra("«keyValue»");
                     return «field.simpleName» == null ? «getterMethodDefaultName»() : «field.simpleName»;
                  «ELSE»
                     return «prefix».get«mapTypeToMethodName.get(field.type.simpleName)»Extra("«keyValue»");
                  «ENDIF»
               «ENDIF»
            '''
         ]
      }

      if (!clazz.declaredMethods.exists[m|m.simpleName.equalsIgnoreCase(getterMethodDefaultName)] &&
         fieldInitializer != null) {
         field.markAsRead
         clazz.addMethod(getterMethodDefaultName) [
            visibility = Visibility.PUBLIC
            returnType = field.type
            body = fieldInitializer
         ]
      } else if (field.type.primitive && isDataSourceActivity) {
         field.addError(
            'You must provide a default value for this primitive type. Or declare a function that provides this default value.')
      }

      // add put method, with chainable invocation
      clazz.addMethod("put" + field.simpleName.toFirstUpper) [
         visibility = Visibility.PUBLIC
         returnType = clazz.newTypeReference
         addParameter("value", if (field.isParcelable(context)) field.getParcelableType(context) else field.type)
         body = '''
			«IF field.isParcelable(context)»
				«IF isDataSourceFragment»
					«prefix».put«field.parcelableSuffix»("«keyValue»", value);
				«ELSE»
					«prefix».put«IF field.type.simpleName.contains("ArrayList")»ParcelableArrayList«ENDIF»Extra("«keyValue»", value);
				«ENDIF»
            «ELSEIF mapTypeToIntentPutInFix.containsKey(field.type.simpleName) && !isDataSourceFragment»
				«prefix».put«mapTypeToIntentPutInFix.get(field.type.simpleName)»Extra("«keyValue»", value);
			«ELSEIF isDataSourceFragment»
           		«prefix».put«mapTypeToMethodName.get(field.type.simpleName)»("«keyValue»", value);
           	«ELSE»
           		«prefix».putExtra("«keyValue»", value);
           	«ENDIF»
			return this;
         '''
      ]

      // add static put method for adding to Intent
      clazz.addMethod("put" + field.simpleName.toFirstUpper) [
         visibility = Visibility.PUBLIC
         static = true
         addParameter("intent", Intent.newTypeReference())
         addParameter("value", if (field.isParcelable(context)) field.getParcelableType(context) else field.type)
         body = [
            '''
				«IF field.isParcelable(context)»
					intent.put«IF field.type.simpleName.contains("ArrayList")»ParcelableArrayList«ENDIF»Extra("«keyValue»", value);
            	«ELSEIF mapTypeToIntentPutInFix.containsKey(field.type.simpleName)»
            		intent.put«mapTypeToIntentPutInFix.get(field.type.simpleName)»Extra("«keyValue»", value);
				«ELSE»
               		intent.putExtra("«keyValue»", value);
               «ENDIF»
            ''']
      ]

      // add static put method for adding to Bundle
      clazz.addMethod("put" + field.simpleName.toFirstUpper) [
         visibility = Visibility.PUBLIC
         static = true
         addParameter("bundle", Bundle.newTypeReference())
         addParameter("value", if (field.isParcelable(context)) field.getParcelableType(context) else field.type)
         body = [
            '''
«««				«IF field.isParcelable(context)»
«««					bundle.put«field.parcelableSuffix»("«keyValue»", value);
«««				«ELSE»             	
					bundle.put«mapTypeToMethodName.get(field.type.simpleName)»("«keyValue»", value);
«««				«ENDIF»
            ''']
      ]

      // remove this field so that code calls getters instead
      field.remove
   }

   def determinePrefix(extension TransformationContext context, MutableFieldDeclaration field,
      boolean isDataSourceActivity, boolean isDataSourceFragment, MutableFieldDeclaration intentField) {
      var _prefix = ''
      if (isDataSourceActivity) {
         return 'getIntent()'
      } else if (isDataSourceFragment) {
         return 'getArguments()'
      } else if (intentField != null) {
         return intentField.simpleName
      } else {
         field.declaringType.addError(
            'You must provide an instantiated member of type Intent, if the declaring type of this field is not an Activity or Fragment.')
      }
      return _prefix
   }

   def santizedName(String name) {
      return name.replaceFirst("^_+", '')
   }
   
   def boolean isParcelable(MutableFieldDeclaration field, extension TransformationContext context)
   {
   	    // it could be a ArrayList<? extends Parcelable> // TODO test
   		val fieldType = if (field.type.simpleName.contains("ArrayList") && !field.type.actualTypeArguments.empty) field.type.actualTypeArguments.head else field.type  
   		var type = if (fieldType.array) fieldType.arrayComponentType else fieldType
		return Parcelable.newTypeReference.isAssignableFrom(type) &&
			// a bundle is a sub type of Parcelable
			!Bundle.newTypeReference.isAssignableFrom(type)
   }
   
   def CharSequence getParcelableSuffix(MutableFieldDeclaration field)
   {
      if (field.type.simpleName.contains("ArrayList")) return "ParcelableArrayList"
      if (field.type.array) return "ParcelableArray"
      return "Parcelable"
   }
   
   def TypeReference getParcelableType(MutableFieldDeclaration field, extension TransformationContext context) {
		val parcelableTypeRef = Parcelable.newTypeReference
      if (field.type.simpleName.contains("ArrayList")) return field.type
      if (field.type.array) {
      	return parcelableTypeRef.newArrayTypeReference
      }
      return parcelableTypeRef
   }
}
