package org.xtendroid.parcel

import android.os.Parcel
import android.os.Parcelable
import android.os.Parcelable.Creator
import android.text.TextUtils
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy.CompilationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableInterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.json.JSONException
import org.json.JSONObject
import org.xtendroid.json.AndroidJsonProcessor
import org.xtendroid.json.AndroidJson

@Active(ParcelableProcessor)
@Target(ElementType.TYPE)
annotation AndroidParcelable {}

/**
 *  resources:
 * http://mobile.dzone.com/articles/using-android-parcel
 * http://blog.efftinge.de/2013/03/fun-with-active-annotations-my-little.html
 * http://probemonkey.wordpress.com/2011/05/21/annotations-with-varargs-parameters/ // currently not possible with xtend
 */

/**
 * 
 * Compatible with @Property and @JSONProperty
 * 
 */
 
 /**
  * 
  * Future work: Parcelable enum types
  * 
  */

class ParcelableProcessor extends AbstractClassProcessor
{
	val static supportedPrimitiveScalarType= #{
		'java.lang.String' -> 'String'
		, 'byte' -> 'Byte' // writeByte, readByte
		, 'double' -> 'Double'
		, 'float' -> 'Float'
		, 'int' -> 'Int'
		, 'long' -> 'Long'
		, 'String' -> 'String' // TODO determine if redundant
		, 'android.util.SparseBooleanArray' -> 'SparseBooleanArray'
	}
	
	val static supportedPrimitiveArrayType = #{
		'java.lang.String[]' -> 'StringArray'
		, 'boolean[]' -> 'BooleanArray'
		, 'byte[]' -> 'ByteArray'
		, 'double[]' -> 'DoubleArray'
		, 'float[]' -> 'FloatArray'
		, 'int[]' -> 'IntArray'
		, 'long[]' -> 'LongArray'
		, 'String[]' -> 'StringArray' // TODO determine if redundant
		, 'char[]' -> 'CharArray'
	}
	
	val static unsupportedAbstractTypesAndSuggestedTypes = #{
		'java.lang.Byte' -> 'byte'
		, 'java.lang.Double' -> 'double'
		, 'java.lang.Float' -> 'float'
		, 'java.lang.Integer' -> 'int'
		, 'java.lang.Long' -> 'long'
		, 'java.lang.Boolean[]' -> 'boolean[]' // or: convert to SparseBooleanArray at the cost of more computational power
		, 'java.lang.Byte[]' -> 'byte[]'
		, 'java.lang.Char[]' -> 'char[]'
		, 'java.lang.Double[]' -> 'double[]'
		, 'java.lang.Float[]' -> 'float[]'
		, 'java.lang.Integer[]' -> 'int[]'
		, 'java.lang.Long[]' -> 'long[]'
	}
	
	/**
	 * 
	 * Marshalling code generator for common types
	 * 
	 */
	def mapTypeToWriteMethodBody(MutableFieldDeclaration f) '''
		«IF supportedPrimitiveScalarType.containsKey(f.type.name)»
			out.write«supportedPrimitiveScalarType.get(f.type.name)»(this.«f.simpleName»);
		«ELSEIF supportedPrimitiveArrayType.keySet.exists[ k | k.endsWith(f.type.name)]»
			out.write«supportedPrimitiveArrayType.get(f.type.name)»(this.«f.simpleName»);
		«ELSEIF "boolean".equals(f.type.name)»
			out.writeInt(this.«f.simpleName» ? 1 : 0);
		«ELSEIF "java.util.Date".equals(f.type.name)»
			if (this.«f.simpleName» != null)
				out.writeLong(this.«f.simpleName».getTime());
		«ELSEIF f.type.name.startsWith("org.json.JSON")»
			if (this.«f.simpleName» != null)
				out.writeString(this.«f.simpleName».toString());
		«ELSEIF f.type.name.startsWith('java.util.List')»
			«IF f.type.actualTypeArguments.head.name.equals('java.util.Date')»
				if («f.simpleName» != null)
				{
					long[] «f.simpleName»LongArray = new long[«f.simpleName».size()];
					for (int i=0; i<«f.simpleName».size(); i++)
					{
						«f.simpleName»LongArray[i] = ((java.util.Date) «f.simpleName».toArray()[i]).getTime();
					}
					out.writeLongArray(«f.simpleName»LongArray);
				}
			«ELSEIF f.type.actualTypeArguments.head.name.equals('java.lang.String')»
				out.writeStringList(this.«f.simpleName»);
			«ELSE»
				out.writeTypedList(this.«f.simpleName»);
			«ENDIF»
		«ELSEIF f.type.name.endsWith('[]')»
			«IF f.type.name.startsWith("java.util.Date")»
				if (this.«f.simpleName» != null)
				{
					long[] «f.simpleName»LongArray = new long[this.«f.simpleName».length];
					for (int i=0; i < this.«f.simpleName».length; i++)
					{
						«f.simpleName»LongArray[i] = this.«f.simpleName»[i].getTime();
					}
					out.writeLongArray(«f.simpleName»LongArray);
				}
			«ELSE»
				out.writeParcelableArray(this.«f.simpleName», flags);
			«ENDIF»
		«ELSE»
			out.writeParcelable(this.«f.simpleName», flags);
		«ENDIF»
	'''
	
	/**
	 * 
	 * Demarshalling code for common types
	 * 
	 */
	def mapTypeToReadMethodBody(extension CompilationContext compContext, extension TransformationContext context, MutableFieldDeclaration f) '''
		«IF supportedPrimitiveScalarType.containsKey(f.type.name)»
			this.«f.simpleName» = in.read«supportedPrimitiveScalarType.get(f.type.name)»();
		«ELSEIF supportedPrimitiveArrayType.containsKey(f.type.name)»
			this.«f.simpleName» = in.create«supportedPrimitiveArrayType.get(f.type.name)»();
		«ELSEIF "boolean".equals(f.type.name)»
			this.«f.simpleName» = in.readInt() > 0;
		«ELSEIF "java.util.Date".equals(f.type.name)»
			this.«f.simpleName» = new Date(in.readLong());
		«ELSEIF "org.json.JSONObject".equals(f.type.name)»
			final String jsonObject«f.simpleName»String = in.readString();
			if (!«toJavaCode(TextUtils.newTypeReference)».isEmpty(jsonObject«f.simpleName»String))
			{
				this.«f.simpleName» = new JSONObject(jsonObject«f.simpleName»String);
			}
		«ELSEIF "org.json.JSONArray" == f.type.name»
			final String jsonArray«f.simpleName»String = in.readString();
			if (!«toJavaCode(TextUtils.newTypeReference)».isEmpty(jsonArray«f.simpleName»String))
			{		
				this.«f.simpleName» = new JSONArray(jsonArray«f.simpleName»String);
			}
		«ELSEIF f.type.name.endsWith('[]')»
			«IF f.type.name.startsWith("java.util.Date")»
				long[] «f.simpleName»LongArray = in.createLongArray();
				if («f.simpleName»LongArray != null)
				{
					«f.simpleName» = new Date[«f.simpleName»LongArray.length];
					for (int i=0; i < «f.simpleName»LongArray.length; i++)
					{
						this.«f.simpleName»[i] = new Date(«f.simpleName»LongArray[i]);
					}
				}
			«ELSE»
				this.«f.simpleName» = («f.type.name») in.createTypedArray(«f.type.arrayComponentType».CREATOR);
			«ENDIF»
		«ELSEIF f.type.name.startsWith('java.util.List')»
			«IF f.type.actualTypeArguments.head.name.equals('java.util.Date')»
				long[] «f.simpleName»LongArray = in.createLongArray();
				if («f.simpleName»LongArray != null)
				{
					java.util.Date[] «f.simpleName»DateArray = new Date[«f.simpleName»LongArray.length];
					for (int i=0; i<«f.simpleName»LongArray.length; i++)
					{
						«f.simpleName»DateArray[i] = new Date(«f.simpleName»LongArray[i]);
					}
					«f.simpleName» = java.util.Arrays.asList(«f.simpleName»DateArray);
				}
			«ELSEIF f.type.actualTypeArguments.head.name.equals('java.lang.String')»
				this.«f.simpleName» = in.createStringArrayList();
			«ELSE»
				this.«f.simpleName» = in.createTypedArrayList(«f.type.actualTypeArguments.head.name».CREATOR);
			«ENDIF»
		«ELSE»
			this.«f.simpleName» = («f.type.name») CREATOR.createFromParcel(in);
		«ENDIF»
	'''
	
	override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {
		if (!clazz.implementedInterfaces.exists[i | "android.os.Parcelable".endsWith(i.name) ])
		{
		   var List<? extends MutableInterfaceDeclaration> implemented = clazz.declaredInterfaces.toList
		   val implTypes = new ArrayList<TypeReference>
		   implemented.forEach[t| implTypes.add(t as TypeReference) ]
		   implTypes.add(Parcelable.newTypeReference)
		   clazz.setImplementedInterfaces(implTypes)
		}
		
		val fields = clazz.declaredFields
		for (f : fields)
		{
			if (unsupportedAbstractTypesAndSuggestedTypes.keySet.contains(f.type.name))
			{
				f.addError (String.format("%s has the type %s, it may not be used with @AndroidParcelable. Use %s instead.", f.simpleName, f.type.name, ParcelableProcessor.unsupportedAbstractTypesAndSuggestedTypes.get(f.type.name)))
			}
		}
		
		clazz.addMethod("describeContents")  [
			returnType = int.newTypeReference
			addAnnotation(Override.newAnnotationReference)
			body = '''
				return 0;
			'''
		]

		val hasJsonBeanDataField = fields.exists[f|f.simpleName.equals(AndroidJsonProcessor.jsonObjectFieldName)] ||
			fields.exists[f|f.annotations.exists[AndroidJson.newAnnotationReference.equals]] ||
			clazz.annotations.exists[AndroidJson.newAnnotationReference.equals]
			
		// TODO determine why the annotation scan isn't working
		// so I don't need to manually add the `JSONObject _jsonObj` field.
//		clazz.addWarning(String.format("%b;%b;%b|||%b;%b;%b|||%b|||%b;%b;%b||%s",
//			fields.exists[simpleName.equals(AndroidJsonProcessor.jsonObjectFieldName)],
//			fields.exists[annotations.exists[AndroidJson.newAnnotationReference.equals]],
//			clazz.annotations.exists[AndroidJson.newAnnotationReference.equals],
//			fields.exists[f|f.simpleName.equals(AndroidJsonProcessor.jsonObjectFieldName)],
//			fields.exists[f|f.annotations.exists[a|AndroidJson.newAnnotationReference.equals(a)]],
//			clazz.annotations.exists[a | AndroidJson.newAnnotationReference.equals(a)],
//			clazz.annotations.exists[a | JsonProperty.newAnnotationReference.equals(a)],
//			clazz.annotations.exists[a | JsonProperty.newAnnotationReference == a],
//			clazz.annotations.exists[a | AndroidJson.newAnnotationReference == a],
//			fields.exists[f|f.annotations.exists[a|AndroidJson.newAnnotationReference == a]],
//			fields.map[annotations.map[a|a.annotationTypeDeclaration.simpleName].join('')].join('')
//		))
		
		clazz.addMethod("writeToParcel")  [
			returnType = void.newTypeReference
			addParameter('out', Parcel.newTypeReference)
			addParameter('flags', int.newTypeReference)
			addAnnotation(Override.newAnnotationReference)
			body = [ '''
				«fields.filter[f|!f.static].map[f | f.mapTypeToWriteMethodBody ].join()»
				«IF hasJsonBeanDataField»
				if («AndroidJsonProcessor.jsonObjectFieldName» != null)
					out.writeString(«AndroidJsonProcessor.jsonObjectFieldName».toString());
				«ENDIF»
			''']
		]
		
		val parcelableCreatorTypeName = Creator.newTypeReference.simpleName
		clazz.addField("CREATOR") [
			static = true
			final = true
			type = Creator.newTypeReference
			visibility = Visibility.PUBLIC
			initializer = ['''
				new «parcelableCreatorTypeName»<«clazz.simpleName»>() {
					public «clazz.simpleName» createFromParcel(final Parcel in) {
						return new «clazz.simpleName»(in);
					} 
					
					public «clazz.simpleName»[] newArray(final int size) {
						return new «clazz.simpleName»[size];
					}
				}''']
		]

//		clazz.declaredConstructors.forEach[ /*body === null &&*/ clazz.addWarning(String.format('%s: %b', simpleName, parameters.empty)) ] // debug
		val isEmptyCtorProvidedByUser = clazz.declaredConstructors.exists[ /*body === null &&*/ parameters.empty ]
		if (!isEmptyCtorProvidedByUser)
		{
			clazz.addWarning('The user did not add an empty ctor. One will be generated.')
			clazz.addConstructor[
				visibility = Visibility::PUBLIC
				body = ['''
					// empty ctor
				''']
			]
		}

		val exceptionsTypeRef = if (fields.exists[type.name.startsWith("org.json.JSON")])  #[ JSONException.newTypeReference() ] else #[]
		clazz.addConstructor[
			addParameter('in', Parcel.newTypeReference)
			body = ['''
				«IF exceptionsTypeRef.empty»
					readFromParcel(in);
				«ELSE»
					try
					{
						readFromParcel(in);
					}catch(JSONException e)
					{
						// TODO do error handling
						/*
						if (BuildConfig.DEBUG)
						{
							Log.e("«clazz.simpleName»", e.getLocalizedMessage());
						}
						*/
					}
				«ENDIF»
			''']
		]
		
		// if the raw JSON container is explicitly declared
		// it needs to be declared in this @AndroidParcelable context or expect data loss during (de)marshalling
		if (hasJsonBeanDataField)
		{
			clazz.addConstructor[
				addParameter('jsonObj', JSONObject.newTypeReference)
				body = ['''
					this.«AndroidJsonProcessor.jsonObjectFieldName» = jsonObj;
				''']
			]
		}
		
		clazz.addMethod('readFromParcel') [
		   fields.forEach[markAsRead]
			addParameter('in', Parcel.newTypeReference)
			body = ['''
				«fields.filter[!static].map[f | mapTypeToReadMethodBody(context, f) ].join()»
				«IF hasJsonBeanDataField»
				final String jsonStringHolder = in.readString();
				if (!«toJavaCode(TextUtils.newTypeReference)».isEmpty(jsonStringHolder))
					this.«AndroidJsonProcessor.jsonObjectFieldName» = new JSONObject(jsonStringHolder);
				«ENDIF»
			''']
			exceptions = exceptionsTypeRef
			returnType = void.newTypeReference				
		]
	}
}