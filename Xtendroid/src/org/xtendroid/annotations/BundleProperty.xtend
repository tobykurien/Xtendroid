package org.xtendroid.annotations

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractFieldProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import android.text.TextUtils

@Active(BundlePropertyProcessor)
@Target(ElementType.FIELD)
annotation BundleProperty {}

class BundlePropertyProcessor extends AbstractFieldProcessor {
	
	val mapTypeToMethodName = #{
		'Bundle' -> 'Bundle' // 'All'-> 'Bundle, the difference, is that 'All' does not require a key.
		, 'IBinder' -> 'Binder'
		, 'boolean' -> 'Boolean'
		, 'boolean[]' -> 'BooleanArray'
		, 'byte' -> 'Byte'
		, 'byte[]' -> 'ByteArray'
		, 'char' -> 'Char'
		, 'char[]' -> 'CharArray'
		, 'CharSequence' -> 'CharSequence'
		, 'CharSequence[]' -> 'CharSequenceArray'
		, 'ArrayList<CharSequence>' -> 'CharSequenceArrayList'
		, 'double' -> 'Double'
		, 'double[]' -> 'DoubleArray'
		, 'float' -> 'Float'
		, 'float[]' -> 'FloatArray'
		, 'int' -> 'Int'
		, 'int[]' -> 'IntArray'
		, 'ArrayList<Integer>' -> 'IntegerArrayList'
		, 'long' -> 'Long' 
		, 'long[]' -> 'LongArray' 
		, 'Parcelable' -> 'Parcelable' 
		, 'Parcelable[]' -> 'ParcelableArray' 
		, 'ArrayList<Parcelable>' -> 'ParcelableArrayList' 
		, 'Serializable' -> 'Serializable' 
		, 'short' -> 'Short'
		, 'short[]' -> 'ShortArray'
		, 'short' -> 'Short'
		, 'SparseArray<? extends Parcelable>' -> 'SparseParcelableArray'
		, 'SparseArray<Parcelable>' -> 'SparseParcelableArray'
		, 'String' -> 'String'
		, 'String[]' -> 'StringArray'
		, 'ArrayList<String>' -> 'StringArrayList'
	}
	
	val mapTypeToNilValue = #{
		'Bundle' -> 'null' // 'All'-> 'Bundle, the difference, is that 'All' does not require a key.
		, 'IBinder' -> 'null'
		, 'boolean' -> 'false'
		, 'boolean[]' -> 'null'
		, 'byte' -> '0'
		, 'byte[]' -> 'null'
		, 'char' -> "'\\0'"
		, 'char[]' -> 'null'
		, 'CharSequence' -> 'null'
		, 'CharSequence[]' -> 'null'
		, 'ArrayList<CharSequence>' -> 'null'
		, 'double' -> '0.0'
		, 'double[]' -> 'null'
		, 'float' -> '0.0f'
		, 'float[]' -> 'null'
		, 'int' -> '0'
		, 'int[]' -> 'null'
		, 'ArrayList<Integer>' -> 'null'
		, 'long' -> '0' 
		, 'long[]' -> 'null' 
		, 'Parcelable' -> 'null' 
		, 'Parcelable[]' -> 'null' 
		, 'ArrayList<Parcelable>' -> 'null' 
		, 'Serializable' -> 'null' 
		, 'short' -> '0'
		, 'short[]' -> 'null'
		, 'short' -> '0'
		, 'SparseArray<? extends Parcelable>' -> 'null'
		, 'SparseArray<Parcelable>' -> 'null'
		, 'String' -> 'null'
		, 'String[]' -> 'null'
		, 'ArrayList<String>' -> 'null'
	}
	
    override doTransform(MutableFieldDeclaration field, extension TransformationContext context) {
    	
    	val clazz = field.declaringType
    	
    	if (field.type.inferred)
    	{
    		field.addError('You must explicitly declare the type of this field, for this annotation to function correctly.')
    	}

		val isDataSourceActivity = Activity.findTypeGlobally.isAssignableFrom(clazz)
		val isDataSourceFragment = android.app.Fragment.findTypeGlobally.isAssignableFrom(clazz) ||
			 android.support.v4.app.Fragment.findTypeGlobally.isAssignableFrom(clazz)
//		val bundleField = clazz.declaredFields.findFirst[f|f.type.equals(Bundle.newTypeReference)
//			&& (f.annotations.findFirst[a|a.equals(BundleProperty.newAnnotationReference)] == null)
//		]
		val intentField = clazz.declaredFields.findFirst[f|f.type.equals(Intent.newTypeReference)]
		
		var _prefix = context.determinePrefix(field, isDataSourceActivity, isDataSourceFragment, intentField/*, bundleField*/)
		
		val prefix = _prefix
		
//		val extraAnnotation = field.findAnnotation(BundleProperty.findTypeGlobally) // TODO use this for the default value

		val fieldName = field.simpleName.santizedName
    	
    	if (!clazz.declaredFields.exists[f| f.simpleName.equalsIgnoreCase('_bundleHolder') && f.type.equals(Bundle.newTypeReference)])
    	{
    		clazz.addField('_bundleHolder') [
	    		visibility = Visibility.PRIVATE
    			type = Bundle.newTypeReference
    		]
    	}

    	if (!isDataSourceFragment && !clazz.declaredFields.exists[f| f.simpleName.equalsIgnoreCase('_intentHolder') && f.type.equals(Intent.newTypeReference)])
    	{
    		clazz.addField('_intentHolder') [
	    		visibility = Visibility.PRIVATE
    			type = Intent.newTypeReference
    		]
    	}
    	
    	val getterMethodDefaultName = "get" + fieldName.toFirstUpper + 'Default'
    	val fieldInitializer = field.initializer
    	
    	// add get method
    	val getterMethodName = "get" + fieldName.toFirstUpper
    	if (!clazz.declaredMethods.exists[m|m.simpleName.equalsIgnoreCase(getterMethodName)])
    	{
	    	clazz.addMethod(getterMethodName) [
	    		visibility = Visibility.PUBLIC
	    		returnType = field.type
				body =['''
					«IF isDataSourceActivity»
						if (_intentHolder == null)
						{
							_intentHolder = getIntent();
						}
«««						// TODO primitives require default value
						return _intentHolder.get«mapTypeToMethodName.get(field.type.simpleName)»Extra("«fieldName»"«IF field.type.primitive», «getterMethodDefaultName»()«ENDIF»);
					«ELSEIF isDataSourceFragment»
							if (_bundleHolder == null)
							{
								_bundleHolder = «prefix»;
							}
						«IF !field.type.primitive»
							if («field.simpleName» == «mapTypeToNilValue.get(field.type.simpleName)»)
							{
								«field.simpleName» = _bundleHolder.get«mapTypeToMethodName.get(field.type.simpleName)»("«fieldName»");
								«IF fieldInitializer != null»
			«««						// this really looks fugly for primitive types..., so there's a specialized String/CharSequence clause
									«IF field.type.simpleName.endsWith('String') || field.type.simpleName.endsWith('CharSequence')»
										if («toJavaCode(TextUtils.newTypeReference)».isEmpty(«field.simpleName»))
										{
											«field.simpleName» = «getterMethodDefaultName»(); 
										}
									«ELSE»
										if («field.simpleName» == «mapTypeToNilValue.get(field.type.simpleName)»)
										{
											«field.simpleName» = «getterMethodDefaultName»(); 
										}
									«ENDIF»
								«ENDIF»
							}
							return «field.simpleName»;
						«ELSE»
							return _bundleHolder.get«mapTypeToMethodName.get(field.type.simpleName)»("«fieldName»");
						«ENDIF»
					«ELSE»						
						if (_intentHolder == null)
						{
							_intentHolder = «intentField.simpleName»;
						}
						return _intentHolder.get«mapTypeToMethodName.get(field.type.simpleName)»Extra("«fieldName»"«IF field.type.primitive», «getterMethodDefaultName»()«ENDIF»);
					«ENDIF»
				''']    		
	    	]
    	}
    	
		if (!clazz.declaredMethods.exists[m|m.simpleName.equalsIgnoreCase(getterMethodDefaultName)] && fieldInitializer != null)
    	{
    		clazz.addMethod(getterMethodDefaultName) [
	    		visibility = Visibility.PUBLIC
	    		returnType = field.type
    			body = fieldInitializer
    		]
    	}else if (field.type.primitive && isDataSourceActivity)
    	{
    		field.addError('You must provide a default value for this primitive type. Or declare a function that provides this default value.')
    	}

		// add put method, with chainable invocation
    	clazz.addMethod("put" + field.simpleName.toFirstUpper) [
    		visibility = Visibility.PUBLIC
    		returnType = clazz.newTypeReference
    		addParameter("value", field.type)
			body =['''
				«IF isDataSourceActivity»
					if (_intentHolder == null)
					{
						_intentHolder = getIntent();
					}
					_intentHolder.putExtra("«fieldName»", value);
				«ELSEIF isDataSourceFragment»
					if (_bundleHolder == null)
					{
						_bundleHolder = «prefix»;
					}
					_bundleHolder.put«mapTypeToMethodName.get(field.type.simpleName)»("«fieldName»", value);
				«ELSE»
					«intentField.simpleName».putExtra("«fieldName»", value);
				«ENDIF»
				return this;
			''']    		
    	]
    }
				
	def determinePrefix(extension TransformationContext context, MutableFieldDeclaration field, boolean isDataSourceActivity, boolean isDataSourceFragment, MutableFieldDeclaration intentField/*, MutableFieldDeclaration bundleField*/) {
		var _prefix = ''
		if (isDataSourceActivity)
		{
			return 'getIntent().getExtras()'
		}else if(isDataSourceFragment)
		{
			return 'getArguments()'
		}/*if (bundleField != null)
		{
			return bundleField.simpleName 
		}*/ if (intentField != null)
		{
			return intentField.simpleName + '.getExtras()' 
		} else
		{
			field.declaringType.addError('You must provide an instantiated member of type Intent, if the declaring type of this field is not an Activity or Fragment.')
			// TODO change this to clazz
		}
		_prefix
	}
    
    def santizedName(String name)
    {
    	return name.replaceFirst("^_+", '')
    }
}