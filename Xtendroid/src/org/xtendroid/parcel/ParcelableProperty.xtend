package org.xtendroid.parcel

import android.os.Parcel
import android.os.Parcelable
import android.os.Parcelable.Creator
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.List
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.json.JSONException
import org.json.JSONObject
import org.xtendroid.json.JsonPropertyProcessor

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
	 * TODO static fields should be exempt from Parcelization
	 * 
	 */
	def mapTypeToWriteMethodBody(MutableFieldDeclaration f) '''
		«IF supportedPrimitiveScalarType.containsKey(f.type.name)»
			in.write«supportedPrimitiveScalarType.get(f.type.name)»(this.«f.simpleName»);
		«ELSEIF supportedPrimitiveArrayType.keySet.exists[ k | k.endsWith(f.type.name)]»
			in.write«supportedPrimitiveArrayType.get(f.type.name)»(this.«f.simpleName»);
		«ELSEIF "boolean".equals(f.type.name)»
			in.writeInt(this.«f.simpleName» ? 1 : 0);
		«ELSEIF "java.util.Date".equals(f.type.name)»
			if (this.«f.simpleName» != null)
				in.writeLong(this.«f.simpleName».getTime());
		«ELSEIF f.type.name.startsWith("org.json.JSON")»
			if (this.«f.simpleName» != null)
				in.writeString(this.«f.simpleName».toString());
		«ELSEIF f.type.name.startsWith('java.util.List')»
			«IF f.type.actualTypeArguments.head.name.equals('java.util.Date')»
				if («f.simpleName» != null)
				{
					long[] «f.simpleName»LongArray = new long[«f.simpleName».size()];
					for (int i=0; i<«f.simpleName».size(); i++)
					{
						«f.simpleName»LongArray[i] = ((java.util.Date) «f.simpleName».toArray()[i]).getTime();
					}
					in.writeLongArray(«f.simpleName»LongArray);
				}
			«ELSEIF f.type.actualTypeArguments.head.name.equals('java.lang.String')»
				in.writeStringList(this.«f.simpleName»);
			«ELSE»
				in.writeTypedList(this.«f.simpleName»);
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
					in.writeLongArray(«f.simpleName»LongArray);
				}
			«ELSE»
				in.writeParcelableArray(this.«f.simpleName», flags);
			«ENDIF»
		«ELSE»
			in.writeParcelable(this.«f.simpleName», flags);
		«ENDIF»
	'''
	
	/**
	 * 
	 * Demarshalling code for common types
	 * 
	 */
	def mapTypeToReadMethodBody(MutableFieldDeclaration f) '''
		«IF supportedPrimitiveScalarType.containsKey(f.type.name)»
			this.«f.simpleName» = in.read«supportedPrimitiveScalarType.get(f.type.name)»();
		«ELSEIF supportedPrimitiveArrayType.containsKey(f.type.name)»
			this.«f.simpleName» = in.create«supportedPrimitiveArrayType.get(f.type.name)»();
		«ELSEIF "boolean".equals(f.type.name)»
			this.«f.simpleName» = in.readInt() > 0;
		«ELSEIF "java.util.Date".equals(f.type.name)»
			this.«f.simpleName» = new Date(in.readLong());
		«ELSEIF "org.json.JSONObject".equals(f.type.name)»
			this.«f.simpleName» = new JSONObject(in.readString());
		«ELSEIF "org.json.JSONArray".equals(f.type.name)»
			this.«f.simpleName» = new JSONArray(in.readString());
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
				in.readStringList(this.«f.simpleName»);
			«ELSE»
				in.readTypedList(this.«f.simpleName», «f.type.actualTypeArguments.head.name».CREATOR);
			«ENDIF»
		«ELSE»
			this.«f.simpleName» = («f.type.name») «f.type.name».CREATOR.createFromParcel(in);
		«ENDIF»
	'''
	
	override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {
		if (!clazz.implementedInterfaces.exists[i | "android.os.Parcelable".endsWith(i.name) ])
		{
		   var List<TypeReference> implemented = clazz.declaredInterfaces.toList as List<TypeReference>
		   implemented.add(Parcelable.newTypeReference)
		   clazz.setImplementedInterfaces(implemented)
//			val interfaces = clazz.implementedInterfaces.join(', ')
//			clazz.addError (String.format("To use @AndroidParcelable, %s must implement android.os.Parcelable, currently it implements: %s.", clazz.simpleName, if (interfaces.empty) 'nothing.' else interfaces))
		}
		
		val fields = clazz.declaredFields
		val jsonPropertyFieldDeclared = fields.exists[f | f.simpleName.equalsIgnoreCase(JsonPropertyProcessor.jsonObjectFieldName) && f.type.name.equalsIgnoreCase('org.json.JSONObject')]
		for (f : fields)
		{
			if (unsupportedAbstractTypesAndSuggestedTypes.keySet.contains(f.type.name))
			{
				f.addError (String.format("%s has the type %s, it may not be used with @AndroidParcelable. Use %s instead.", f.simpleName, f.type.name, ParcelableProcessor.unsupportedAbstractTypesAndSuggestedTypes.get(f.type.name)))
			}
		}
		
		// @Override public int describeContents() { return 0; }
		clazz.addMethod("describeContents")  [
			returnType = int.newTypeReference
			addAnnotation(Override.newAnnotationReference)
			body = '''
				return 0;
			'''
		]

		clazz.addMethod("writeToParcel")  [
			returnType = void.newTypeReference
			addParameter('in', Parcel.newTypeReference)
			addParameter('flags', int.newTypeReference)
			addAnnotation(Override.newAnnotationReference)
			body = [ '''
				«fields.filter[f|!f.static].map[f | f.mapTypeToWriteMethodBody ].join()»
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
		
		clazz.addConstructor[
			body = ['''
				// empty ctor
			''']
		]

		val exceptionsTypeRef = if (fields.exists[f|f.type.name.startsWith("org.json.JSONObject")])  #[ JSONException.newTypeReference() ] else #[]
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
		if (clazz.declaredFields.exists[f|f.simpleName.equals(JsonPropertyProcessor.jsonObjectFieldName)])
		{
			clazz.addConstructor[
				addParameter('jsonObj', JSONObject.newTypeReference)
				body = ['''
					this.«JsonPropertyProcessor.jsonObjectFieldName» = jsonObj;
				''']
			]
		}
		
		clazz.addMethod('readFromParcel') [
			addParameter('in', Parcel.newTypeReference)
			body = ['''
				«fields.filter[f|!f.static].map[f | f.mapTypeToReadMethodBody ].join()»
			''']
			exceptions = exceptionsTypeRef
			returnType = void.newTypeReference				
		]
	}
}