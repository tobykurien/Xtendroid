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

@Active(BundlePropertyProcessor)
@Target(ElementType.FIELD)
annotation BundleProperty {
   String value = ''
}

class BundlePropertyProcessor extends AbstractFieldProcessor {

   val mapTypeToMethodName = #{
      'Bundle' -> 'Bundle' // 'All'-> 'Bundle, the difference, is that 'All' does not require a key.
      ,
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
      'Bundle' -> 'null' // 'All'-> 'Bundle, the difference, is that 'All' does not require a key.
      ,
      'IBinder' -> 'null',
      'boolean' -> 'false',
      'boolean[]' -> 'null',
      'byte' -> '0',
      'byte[]' -> 'null',
      'char' -> "'\\0'",
      'char[]' -> 'null',
      'CharSequence' -> 'null',
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
                     «field.type.name» «field.simpleName» = «prefix».get«mapTypeToMethodName.get(field.type.simpleName)»("«keyValue»");
                     return «field.simpleName» == «mapTypeToNilValue.get(field.type.simpleName)» ? «field.simpleName» : «getterMethodDefaultName»();
                  «ELSE»
                     return «prefix».get«mapTypeToMethodName.get(field.type.simpleName)»("«keyValue»");
                  «ENDIF»
               «ELSE»
                  «IF field.type.primitive»
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
         addParameter("value", field.type)
         body = '''
            «IF isDataSourceFragment»
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
         addParameter("value", field.type)
         body = [
            '''
               intent.putExtra("«keyValue»", value);
            ''']
      ]

      // add static put method for adding to Bundle
      clazz.addMethod("put" + field.simpleName.toFirstUpper) [
         visibility = Visibility.PUBLIC
         static = true
         addParameter("bundle", Bundle.newTypeReference())
         addParameter("value", field.type)
         body = [
            '''
               bundle.put«mapTypeToMethodName.get(field.type.simpleName)»("«keyValue»", value);
            ''']
      ]

      // remove this field so that code calls getters instead
      field.remove
   }

   def determinePrefix(extension TransformationContext context, MutableFieldDeclaration field,
      boolean isDataSourceActivity, boolean isDataSourceFragment, MutableFieldDeclaration intentField/*, MutableFieldDeclaration bundleField*/) {
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
}
