package org.xtendroid.parcel

import android.os.Parcel
import java.util.List
import org.eclipse.xtend.lib.macro.AbstractFieldProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration

//@Active(ParcelableEnumProcessor)
@Active(ParcelableProcessor)
annotation AndroidParcelable {}

annotation Parcelize {}

/**
 *  resources:
 * http://mobile.dzone.com/articles/using-android-parcel
 * http://blog.efftinge.de/2013/03/fun-with-active-annotations-my-little.html
 */


//@Active(ParcelPropertyProcessor) // because composability makes this redundant
//annotation ParcelProperty {}

/**
 * TODO baby steps: create @ParcelableProperty
 * TODO annotations @ParcelableType (to convert a whole "java bean" to a Parcelable)
 * TODO special concerns: string -> date types, scalar boolean values, parcelable enums
 * TODO true goal: thru composition and active annotations raw json to generate lazy-json-parsing pacelable types.
 * The problem with generating a lazy-json-parsing parcelable is that one also has to parcelize the original raw json input.
 */
 
 /**
  * TODO on a separate project: turn on logging, @AndroidLog android.os.Log.e.
  */

class ParcelableProcessor implements TransformationParticipant<MutableClassDeclaration>
{
	val static supportedPrimitiveScalarType= #{
		'java.lang.Byte' -> 'Byte' // writeByte, readByte
		, 'java.lang.Double' -> 'Double'
		, 'java.lang.Float' -> 'Float'
		, 'java.lang.Integer' -> 'Int'
		, 'java.lang.Long' -> 'Long'
		, 'java.lang.String' -> 'String'
		, 'byte' -> 'Byte' // writeByte, readByte
		, 'double' -> 'Double'
		, 'float' -> 'Float'
		, 'int' -> 'Int'
		, 'long' -> 'Long'
		, 'String' -> 'String'
	}
	
	val static supportedPrimitiveArrayType = #{
		'java.lang.Boolean[]' -> 'BooleanArray' // or: convert to SparseBooleanArray at the cost of more computational power
		, 'java.lang.Byte[]' -> 'ByteArray'
		, 'java.lang.Char[]' -> 'CharArray'
		, 'java.lang.Double[]' -> 'DoubleArray'
		, 'java.lang.Float[]' -> 'FloatArray'
		, 'java.lang.Integer[]' -> 'IntArray'
		, 'java.lang.Long[]' -> 'LongArray'
		, 'java.lang.String[]' -> 'StringArray'
		, 'android.util.SparseBooleanArray' -> 'SparseBooleanArray'
	}
	
	@Deprecated // pretty useless, both Xtend and Parcels accept abstract types...
	def isAbstractType(String simpleTypeName) '''
		«IF simpleTypeName.toFirstUpper.equals(simpleTypeName)».«simpleTypeName»Value();«ENDIF»
	'''
	
	def mapTypeToWriteMethodBody(MutableFieldDeclaration f) '''
		«IF supportedPrimitiveScalarType.containsKey(f.type.name)»
			in.write«supportedPrimitiveScalarType.get(f.type.name)»(this.«f.simpleName»);
		«ELSEIF supportedPrimitiveArrayType.containsKey(f.type.name)»
			in.writeInt(this.«f.simpleName».length);
			in.write«supportedPrimitiveArrayType.get(f.type.name)»(this.«f.simpleName»«f.type.simpleName.isAbstractType»);
		«ELSEIF "java.lang.Boolean".equals(f.type.name)»
			in.writeInt(this.«f.simpleName».booleanValue() ? 1 : 0);
		«ELSEIF "boolean".equals(f.type.simpleName)»
			in.writeInt(this.«f.simpleName» ? 1 : 0);
		«ELSEIF f.type.name.endsWith('[]')»
			// assume the object implements a Parcelable Array
			in.writeInt(this.«f.simpleName».length);
			in.writeParcelableArray(this.«f.simpleName», flags);
		«ELSE»
			// assume the object implements a Parcelable, this also applies to Parcelable enum types
			in.writeParcelable(this.«f.simpleName», flags);
		«ENDIF»
	'''
	

	override doTransform(List<? extends MutableClassDeclaration> annotatedTargetElements, extension TransformationContext context) {
		val xtendPropertyAnnotation = typeof(Property).findTypeGlobally
		for (clazz : annotatedTargetElements)
		{
			if (clazz.implementedInterfaces.exists[i | "android.os.Parcelable".equalsIgnoreCase(i.class.name) ])
				throw new IllegalArgumentException (String.format("This class must implement android.os.Parcelable, currently it implements %s", clazz.implementedInterfaces.join(', ')))
			
			// this approach is broken
//			val annotatedFieldsWithProperty = clazz.declaredFields.filter[f | f.annotations.exists[a|a.annotationTypeDeclaration.equals(typeof(Property))]]

			val annotatedFieldsWithProperty = clazz.declaredFields // .filter[findAnnotation(xtendPropertyAnnotation) != null]
			
			// @Override public int describeContents() { return 0; }
			clazz.addMethod("describeContents")  [
				returnType = int.newTypeReference
				addAnnotation(Override.newAnnotationReference)
				body = '''
					return 0;
				'''
			]
			
			
			// TODO @Override public void writeToParcel(Parcel in, int flags) { /* complicated stuff */ }
			clazz.addMethod("writeToParcel")  [
				returnType = void.newTypeReference
				addParameter('in', Parcel.newTypeReference)
				addParameter('flags', int.newTypeReference)
				addAnnotation(Override.newAnnotationReference)
				body = [ '''
					«annotatedFieldsWithProperty.map[f | f.mapTypeToWriteMethodBody ].join()»
				''']
			]

//			throw new Exception(clazz.declaredFields.map[ f | f.simpleName + "(" + f.type.name + "): " + f.annotations.map[s|s.toString].join(', ')].join('# '))
			throw new Exception(clazz.declaredFields.map[ f | f.simpleName + "(" + f.type.name + "): " + f.findAnnotation(org.eclipse.xtend.lib.Property.findTypeGlobally)].join('# '))
				
			// TODO read
//			clazz.addMethod() [
//				for (f : clazz.declaredFields)
//				{
//					
//				}
//			]

			// TODO
			/*
			public static final Parcelable.Creator<User> CREATOR = new Parcelable.Creator<User>() {
				public User createFromParcel(Parcel pc) {
					return new User(pc);
				}
				public User[] newArray(int size) {
					return new User[size];
				}
			};
			 */
			
			// TODO public Ctor() // no args
			// TODO public Ctor(Parcel in) { }
		}
	}
}

// TODO convert enum values to int
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

/**
 * @ParcelableProperty annotation creates a "Json bean" that accepts a JSONObject
 * and then parses it on-demand with getters.
 */
class ParcelPropertyProcessor extends AbstractFieldProcessor {

	/** 
	 * if a field of a certain non-primitive type is slapped with a @ParcelableProperty, assume that this object is Parcelable
	 * so #readParcelable, #writeParcelable, #readParcelableArray, #writeParcelableArray can be applied
	 * 
	 * TODO @ParcelDateProperty // defaults to UTC format -> "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'fff'Z'" 	
	 * TODO @ParcelDateProperty("mm-dd-YYYY") 	
	 * TODO @ParcelDateProperty("mmm-ddd-YYYY", Localization...) 	
	 * TODO @ParcelEnumProperty 	
	 * TODO @ParcelEnumArrayProperty 	
	 * TODO @ParcelEnumListProperty 	
	 */
	 
	 
	/*
	override doTransform(MutableFieldDeclaration field, extension TransformationContext context) {
		// rename the property to _property
		val orgName = field.simpleName
		field.simpleName = "_" + field.simpleName
		
        // create a getter method for the property
        var getterPrefix = if(field.type.name.equalsIgnoreCase('java.lang.Boolean')) "is" else "get"
	    field.declaringType.addMethod(getterPrefix + orgName.upperCaseFirst) [
	        visibility = Visibility::PUBLIC
	        returnType = field.type
	        body = ['''
	        	return «field.simpleName»;
	        ''']
        ]
        
		// create a setter method for the property
	    field.declaringType.addMethod('set' + orgName.upperCaseFirst) [
	        visibility = Visibility::PUBLIC
	        returnType = typeof(void).newTypeReference
	        addParameter(orgName, field.type)
	        body = ['''
	        	this.«field.simpleName» = «orgName»;
	        ''']
        ]            
		
		// TODO figure out how to add "implements Parcelable" to the type declaration if missing, or at least throw an error
		if (field.declaringType.declaredInterfaces.exists[m | m.declaringType.newTypeReference.equals(typeof(Parcelable).newTypeReference)]) // TODO fix this
			throw new IllegalArgumentException("This type must implement android.os.Parcelable")

				
	}*/
//      // if there isn't yet a constructor that takes a JSONObject, add it
//		if (!field.declaringType.declaredFields.exists[ it.simpleName == "_jsonObj"]) {
//		   // make a field for storing the JSONObject
//			var f = field.declaringType.addField("_jsonObj") []
//			f.setType(JSONObject.newTypeReference)
//			f.setFinal(true)
//			f.setVisibility(Visibility::PROTECTED)
//
//         // create the constructor						
//			var c = field.declaringType.addConstructor []
//			c.addParameter("jsonObj", JSONObject.newTypeReference)
//			c.body = [
//				'''
//					this._jsonObj = jsonObj;
//				'''
//			]
//		}
//
//      // rename the property to _property
//      val orgName = field.simpleName
//      field.simpleName = "_" + field.simpleName
//
//      // make a flag for each property to indicate if it's been parsed
//      // so that we can cache the result of parsing
//      val f = field.declaringType.addField(field.simpleName + "Loaded") []
//      f.setType(Boolean.newTypeReference)
//      f.setInitializer(["false"])
//      f.setVisibility(Visibility::PROTECTED)
//
//      // create a getter method for the property
//      var getter = if(field.type.simpleName.equalsIgnoreCase("Boolean")) "is" else "get"
//      field.declaringType.addMethod(getter + orgName.upperCaseFirst) [
//         visibility = Visibility::PUBLIC
//         returnType = field.type
//         exceptions = #[ JSONException.newTypeReference ]
//         
//         if (supportedTypes.contains(field.type.wrapperIfPrimitive.name)) {
//            // parse the value if it hasn't already been, then return the stored result
//            body = [
//               '''
//                  if (!«field.simpleName»Loaded) {
//                     «field.simpleName» = _jsonObj.get«field.type.simpleName.upperCaseFirst»("«orgName»");
//                     «field.simpleName»Loaded = true;
//                  }
//                  return «field.simpleName»;
//               '''
//            ]
//         } else {
//            // TODO: if it's SomeObject with a JSONObject constructor, create it
//            // if it's a List<SomeObject>, then make an ArrayList (or lazy list) of those objects
//            field.addError(field.type + " is not supported for @JsonProperty.")
//         }
//      ]
//   }
}