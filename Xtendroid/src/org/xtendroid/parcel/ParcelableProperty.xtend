package org.xtendroid.parcel

import android.os.Parcel
import android.os.Parcelable.Creator
import java.util.List
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.xtendroid.json.JsonProperty

//import org.eclipse.xtend.lib.macro.declaration.MutableEnumerationTypeDeclaration

@Active(ParcelableProcessor)
annotation AndroidParcelable {}

//@Active(ParcelableEnumProcessor)
//annotation AndroidParcelableEnum {}

/**
 *  resources:
 * http://mobile.dzone.com/articles/using-android-parcel
 * http://blog.efftinge.de/2013/03/fun-with-active-annotations-my-little.html
 */

/**
 * 
 * Theoretically composable with @Property and probably @JSONProperty
 * 
 */

/**
 * TODO special concerns: parcelable enums
 * TODO true goal: thru composition and active annotations raw json to generate lazy-json-parsing pacelable types.
 * The problem with generating a lazy-json-parsing parcelable is that one also has to parcelize the original raw json input.
 */
 
 /**
  * TODO on a separate project: turn on logging, @AndroidLog android.os.Log
  */

class ParcelableProcessor implements TransformationParticipant<MutableClassDeclaration>
{
	val static supportedPrimitiveScalarType= #{
		'java.lang.String' -> 'String'
		, 'byte' -> 'Byte' // writeByte, readByte
		, 'double' -> 'Double'
		, 'float' -> 'Float'
		, 'int' -> 'Int'
		, 'long' -> 'Long'
		, 'String' -> 'String'
	}
	
	val static supportedPrimitiveArrayType = #{
		'java.lang.String[]' -> 'StringArray'
		, 'boolean[]' -> 'BooleanArray'
		, 'byte[]' -> 'ByteArray' // writeByte, readByte
		, 'double[]' -> 'DoubleArray'
		, 'float[]' -> 'FloatArray'
		, 'int[]' -> 'IntArray'
		, 'long[]' -> 'LongArray'
		, 'String[]' -> 'StringArray'
		, 'android.util.SparseBooleanArray' -> 'SparseBooleanArray'
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
	
	def mapTypeToWriteMethodBody(MutableFieldDeclaration f) '''
		«IF supportedPrimitiveScalarType.containsKey(f.type.name)»
			in.write«supportedPrimitiveScalarType.get(f.type.name)»(this.«f.simpleName»);
		«ELSEIF supportedPrimitiveArrayType.keySet.exists[ k | k.endsWith(f.type.name)]»
			in.write«supportedPrimitiveArrayType.get(f.type.name)»(this.«f.simpleName»);
		«ELSEIF "boolean".equals(f.type.name)»
			in.writeInt(this.«f.simpleName» ? 1 : 0);
		«ELSEIF "java.util.Date".equals(f.type.name)»
			in.writeLong(this.«f.simpleName».getTime());
		«ELSEIF "org.json.JSONObject".equals(f.type.name)»
			in.writeString(this.«f.simpleName».toString());
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
			try
			{
				this.«f.simpleName» = new JSONObject(in.readString());
			}catch(JSONException e)
			{
				// TODO handle your exception here
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
				this.«f.simpleName» = («f.type.name») in.createTypedArray(«f.type.name».CREATOR);
			«ENDIF»
		«ELSE»
			this.«f.simpleName» = («f.type.name») «f.type.name».CREATOR.createFromParcel(in);
		«ENDIF»
	'''
	

	override doTransform(List<? extends MutableClassDeclaration> annotatedTargetElements, extension TransformationContext context) {
		for (clazz : annotatedTargetElements)
		{
			if (!clazz.implementedInterfaces.exists[i | "android.os.Parcelable".endsWith(i.name) ])
			{
				val interfaces = clazz.implementedInterfaces.join(', ')
				clazz.addError (String.format("%s must implement android.os.Parcelable, currently it implements %s", clazz.simpleName, if (interfaces.empty) 'nothing.' else interfaces))
			}
			
			val fields = clazz.declaredFields // .filter[findAnnotation(xtendPropertyAnnotation) != null]
			for (f : fields)
			{
				if (unsupportedAbstractTypesAndSuggestedTypes.keySet.contains(f.type.name))
				{
					f.addError (String.format("%s has the type %s, it may not be used. Use this type instead: %s", f.simpleName, f.type.name, org.xtendroid.parcel.ParcelableProcessor.unsupportedAbstractTypesAndSuggestedTypes.get(f.type.name)))
				}
				
				// TODO fix broken warning 
				if (f.annotations.exists[a | a.equals(JsonProperty.newAnnotationReference)])
				{
					// the gist of the story is to explicitly declare a type like this
					/**
						@AndroidParcelable
						class C implements Parcelable
						{
							JSONObject _jsonObject
							
							@JsonProperty
							String meh
						}
					 */
					f.addWarning (String.format("%s has certain fields that are annotated with @JsonProperty, you have to parcelize the _jsonObject, initialized in the ctor as well to prevent data loss when passing the data object between intents.", f.simpleName))
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
					«fields.map[f | f.mapTypeToWriteMethodBody ].join()»
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

			clazz.addConstructor[
				addParameter('in', Parcel.newTypeReference)
				body = ['''
					readFromParcel(in);
				''']
			]
			
			clazz.addMethod('readFromParcel') [
				addParameter('in', Parcel.newTypeReference)
				body = ['''
					«fields.map[f | f.mapTypeToReadMethodBody ].join()»
				''']
				returnType = void.newTypeReference				
			]
		}
	}
}

// TODO convert enum values to int, implements Parcelable
//class ParcelableEnumProcessor implements TransformationParticipant<MutableEnumerationTypeDeclaration>
//{
//	
//	override doTransform(List<? extends MutableEnumerationTypeDeclaration> annotatedTargetElements, extension TransformationContext context) {
//		val xtendPropertyAnnotationType = typeof(Property).findTypeGlobally
//		for (clazz : annotatedTargetElements)
//		{
//		}
//	}
//}