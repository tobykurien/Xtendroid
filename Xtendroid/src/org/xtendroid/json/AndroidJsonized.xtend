package org.xtendroid.json

/**
 * Created by jasmsison on 02/02/16.
 */

import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy.CompilationContext;

import org.json.JSONObject
import org.json.JSONArray
import org.json.JSONException

import java.util.ArrayList

import static extension org.xtendroid.json.JsonObjectEntry.*
import static extension org.xtendroid.parcel.ParcelableProcessor.*
import android.os.Parcel
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import android.util.SparseBooleanArray

/**
 * Structure by example.
 *
 * You have a JSON snippet - I build your classes.
 */
@Active(AndroidJsonizedProcessor)
annotation AndroidJsonized {
    /**
     * value could be a url or a valid json object, e.g. '{"a" : "string", "b" : true, "c" : 48}'
     */
    String value
}

@Active(AndroidJsonizedParcelableProcessor)
annotation AndroidJsonizedParcelable {
    /**
     * value could be a url or a valid json object, e.g. '{"a" : "string", "b" : true, "c" : 48}'
     * then Parcelable types will be generated
     */
    String value
}

class AndroidJsonizedProcessor extends AbstractClassProcessor {

    protected val reservedKeywords = #{
        'abstract',     'continue',     'for',          'new',          'switch',
        'assert',       'default',      'goto',         'package',      'synchronized',
        'boolean',      'do',           'if',           'private',      'this',
        'break',        'double',       'implements',   'protected',    'throw',
        'byte',         'else',         'import',       'public',       'throws',
        'case',         'enum',         'instanceof',   'return',       'transient',
        'catch',        'extends',      'int',          'short',        'try',
        'char',         'final',        'interface',    'static',       'void',
        'class',        'finally',      'long',         'strictfp',     'volatile',
        'const',        'float',        'native',       'super',        'while'
    }

    /**
     * Called first. Only register any new types you want to generate here.
     */
    override doRegisterGlobals(ClassDeclaration clazz, RegisterGlobalsContext context) {
        // visit the whole JSON tree and register any nested classes
        registerClassNamesRecursively(clazz.jsonEntries, context)
    }

    // placeholder for dynamic transpiler warnings / errors
    protected val delayedErrorMessages = #{ '' -> '' }

    private def void registerClassNamesRecursively(Iterable<JsonObjectEntry> json, RegisterGlobalsContext context) {
        for (jsonEntry : json) {
            if (jsonEntry.isJsonObject) {
                try {
                    context.registerClass(jsonEntry.className)
                    registerClassNamesRecursively(jsonEntry.childEntries, context)
                }catch (java.lang.IllegalArgumentException e)
                {
                    delayedErrorMessages.put(jsonEntry.className, String.format("There was a collision between %s and another registered type.\n%s", jsonEntry.key, e.stackTrace))
                }
            }
        }
    }

    /**
     * Called secondly. Modify the types.
     *
     */
    override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {
        clazz.addWarning(delayedErrorMessages.get(clazz.simpleName))
        clazz.enhanceClassesRecursively(clazz.jsonEntries, context)
        clazz.removeAnnotation(clazz.annotations.findFirst[annotationTypeDeclaration == AndroidJsonized.newTypeReference.type])
    }

    protected static def addJsonPlaceholderAndDirtyFlag(MutableClassDeclaration clazz, extension TransformationContext context) {
        clazz.addConstructor [
            addParameter('jsonObject', JSONObject.newTypeReference)
            // TODO refactor out the name 'mJsonObject'
            body = '''
                mJsonObject = jsonObject;
            '''
        ]

        clazz.addField("mDirty") [
            type = typeof(boolean).newTypeReference
            visibility = Visibility.PRIVATE
        ]

        // do not add fields, directly modify the json object
        clazz.addField("mJsonObject") [
            type = JSONObject.newTypeReference
            visibility = Visibility.PRIVATE
        ]

        clazz.addMethod("toJSONObject") [
            returnType = JSONObject.newTypeReference
            body = '''
                return mJsonObject;
            '''
        ]

        clazz.addMethod("isDirty") [
            returnType = typeof(boolean).newTypeReference
            body = '''
                return mDirty;
            '''
        ]
    }

    protected static def String scrubName(String name) {
        name.replaceAll("[^\\x00-\\x7F]", "").replaceAll("[^A-Za-z0-9]", "").replaceAll("\\s+","")
    }

    protected static def boolean isNotJSONObject(TypeReference basicType, extension TransformationContext context) {
        return basicType.isPrimitive || basicType.isWrapper || basicType.isAssignableFrom(String.newTypeReference)
    }

    protected def void enhanceClassesRecursively(MutableClassDeclaration clazz, Iterable<? extends JsonObjectEntry> entries, extension TransformationContext context) {
        clazz.addJsonPlaceholderAndDirtyFlag(context)

        // add accessors for the entries
        for (entry : entries) {
            val basicType = entry.getComponentType(context)
            val realType = if(entry.isArray) getList(basicType) else basicType
            val memberName = entry.key.scrubName
            val _memberName = '_' + memberName

            // add object field for lazy-loading JSON field
            clazz.addField(_memberName) [
                type = realType
                visibility = Visibility.PROTECTED
            ]

            clazz.addMethod("opt" + memberName.toFirstUpper + if (reservedKeywords.contains(memberName)) '_'  else '') [
                returnType = realType
                if (entry.isArray)
                {
                    // populate List
                    body = ['''
                        if («_memberName» == null) {
                            «toJavaCode(JSONArray.newTypeReference)» arr = mJsonObject.optJSONArray("«entry.key»");
                            if(arr == null) { return null; }
                            «_memberName» = new «toJavaCode(ArrayList.newTypeReference)»<«basicType.simpleName.toFirstUpper»>();
                            for (int i=0; i<«_memberName».size(); i++) {
                                «IF basicType.isNotJSONObject(context)»
                                    «_memberName».add((«basicType.simpleName.toFirstUpper») arr.opt(i));
                                «ELSE»
                                    «_memberName».add(new «basicType.simpleName.toFirstUpper»(arr.optJSONObject(i)));
                                «ENDIF»
                            }
                        }
                        return «_memberName»;
                    ''']
                }else if (entry.isJsonObject)
                {
                    body = ['''
                        if («_memberName» == null) {
                            if (mJsonObject.optJSONObject("«entry.key»") == null) { return null; }
                            «_memberName» = new «basicType.simpleName»(mJsonObject.optJSONObject("«entry.key»"));
                        }
                        return «_memberName»;
				    ''']
                }else { // is primitive (e.g. String, Number, Boolean)
                    body = ['''
                        «_memberName» = mJsonObject.opt«basicType.simpleName.toFirstUpper»("«entry.key»");
                        return «_memberName»;
                    ''']
                }
            ]

            // Hopefully sets have logarithmic costs, not linear (although the cost in our case is constant)
            clazz.addMethod("get" + memberName.toFirstUpper + if (reservedKeywords.contains(memberName)) '_'  else '') [
                returnType = realType
                exceptions = JSONException.newTypeReference
                if (entry.isArray) {
                    // populate List
                    body = ['''
                            if («_memberName» == null) {
                                «_memberName» = new «toJavaCode(ArrayList.newTypeReference)»<«basicType.simpleName.toFirstUpper»>();
                                JSONArray vals = mJsonObject.getJSONArray("«entry.key»");
                                for (int i=0; i < vals.length(); i++) {
                                    «IF basicType.isNotJSONObject(context)»
                                        «_memberName».add((«basicType.simpleName.toFirstUpper») vals.get(i));
                                    «ELSE»
                                        «_memberName».add(new «basicType.simpleName.toFirstUpper»(vals.getJSONObject(i)));
                                    «ENDIF»
                                }
                            }
                            return «_memberName»;
                            ''']
                }else if (entry.isJsonObject) {
                    body = ['''
                        if («_memberName» == null) {
                            «_memberName» = new «basicType.simpleName»(mJsonObject.getJSONObject("«entry.key»"));
                        }
                        return «_memberName»;
				    ''']
                }else { // is primitive (e.g. String, Number, Boolean)
                    body = ['''
                        «_memberName» = mJsonObject.get«basicType.simpleName.toFirstUpper»("«entry.key»");
                        return «_memberName»;
                    ''']
                }
            ]

            // chainable
            clazz.addMethod("set" + memberName.toFirstUpper + if (reservedKeywords.contains(memberName)) '_'  else '') [
                addParameter(_memberName, realType)
                returnType = clazz.newTypeReference
                exceptions = JSONException.newTypeReference
                if (entry.isArray)
                {
                    // ArrayList<T> === Collection<T>
                    body = ['''
                        mDirty = true;
                        mJsonObject.put("«entry.key»", new «toJavaCode(JSONArray.newTypeReference)»(«_memberName»));
                        return this;
                    ''']
                }else if (entry.isJsonObject)
                {
                    body = ['''
                        mDirty = true;
                        mJsonObject.put("«entry.key»", «_memberName».toJSONObject());
                        return this;
				    ''']
                }else {
                    body = ['''
                        mDirty = true;
                        mJsonObject.put("«entry.key»", «_memberName»);
                        return this;
                    ''']
                }
            ]

            if (entry.isJsonObject)
                enhanceClassesRecursively(findClass(entry.className), entry.childEntries, context)
        }
    }
}

/**
 * The current implementation only Parcels the mJsonObject
 * as a String to JSONObject, and JSONObject to String
 */
class AndroidJsonizedParcelableProcessor extends AndroidJsonizedProcessor {

    // TODO determine doRegisterGlobals and registerClassNamesRecursively are called

    override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {
        clazz.addWarning(delayedErrorMessages.get(clazz.simpleName))
        clazz.enhanceClassesRecursively(clazz.jsonEntries, context)
        clazz.enhanceClassesRecursivelyAsParcelable(clazz.jsonEntries, context)
        clazz.removeAnnotation(clazz.annotations.findFirst[annotationTypeDeclaration == AndroidJsonizedParcelable.newTypeReference.type])
    }

    protected static def boolean isTypeOf(TypeReference basicType, String... typeNames) {
        for (name : typeNames) {
            if (basicType.simpleName.toLowerCase.contains(name)) { return true }
        }
        false
    }

    protected static val primitiveArrayTypes = #{
        'long' -> 'LongArray'
        , 'double' -> 'DoubleArray'
        , 'String' -> 'StringArray'
    }

    static def String mapReadParcelableExpression(JsonObjectEntry entry, extension TransformationContext context, extension CompilationContext compilationContext, extension MutableClassDeclaration clazz) {
        val basicType = entry.getComponentType(context)
        val realType = if(entry.isArray) getList(basicType) else basicType // context.getList(basicType)
        val memberName = entry.key.scrubName
        val _memberName = '_' + memberName

        if (entry.isArray) {
            return if (basicType.isTypeOf("bool")) {
                '''
                «toJavaCode(SparseBooleanArray.newTypeReference)» «_memberName»SparseBoolean = in.readSparseBooleanArray();
                if («_memberName»SparseBoolean != null) {
                    «_memberName» = new ArrayList<Boolean>(«_memberName»SparseBoolean.size());
                    for (int i = 0; i < «_memberName»SparseBoolean.size(); i++) {
                        «_memberName».add(«_memberName»SparseBoolean.valueAt(i));
                    }
                }
                '''
            }else if (basicType.isTypeOf("string", "long", "double")) {
                '''
                    // debug: «toJavaCode(basicType)»
                    // debug: «toJavaCode(realType)»
                    «_memberName» = in.create«supportedPrimitiveArrayType.get(basicType.simpleName + '[]')»();'''
            } else {
                '''
                    // debug: «toJavaCode(basicType)»
                    // debug: «toJavaCode(realType)»
                    «_memberName» = in.createTypedArrayList(«toJavaCode(basicType)».CREATOR);
                '''
            } // else TODO the thing is a JSONObject in a JSONArray [ {}, {}, ... ]
        }else if (entry.isJsonObject) {
            // TODO determine we are using the correct CREATOR object
            // TODO remove debug line
            return '''
                // debug: «toJavaCode(basicType)»
                // debug: «toJavaCode(realType)»
                «_memberName» = («toJavaCode(basicType)») «toJavaCode(basicType)».CREATOR.createFromParcel(in);
            '''
        }

        return if (!basicType.isTypeOf("bool")) {
            // TODO string
            // TODO integer (convert to long)
            // TODO double  (convert to double)
            // TODO remove debug line
            '''
                // debug: «toJavaCode(basicType)»
                «_memberName» = in.read«supportedPrimitiveScalarType.get(basicType.simpleName)»();
            '''
        }else /* if boolean */ {
            '''«_memberName» = in.readInt() > 0;''' // 0 == false
        }
    }

    static def String mapWriteParcelableExpression(JsonObjectEntry entry, extension TransformationContext context, extension CompilationContext compilationContext) {
        '''

        '''
    }

    def enhanceClassesRecursivelyAsParcelable(extension MutableClassDeclaration clazz, Iterable<? extends JsonObjectEntry> entries, extension TransformationContext context) {

        clazz.addImplementsParcelable(context)

        clazz.addEmptyCtor(context)

        clazz.addConstructor[
            addParameter('in', Parcel.newTypeReference)
            body = ['''
                readFromParcel(in);
			''']
        ]

        clazz.addMethodDescribeContents(context)

        addMethod("writeToParcel")  [
            returnType = void.newTypeReference
            addParameter('out', Parcel.newTypeReference)
            addParameter('flags', int.newTypeReference)
            addAnnotation(Override.newAnnotationReference)
            // cc == CompilationContext
            body = ['''out.writeString(mJsonObject.toString());'''] // simple Parcelable version just Parcels the original JSONObject
            //body = [ cc | entries.map[entry | entry.mapWriteParcelableExpression(context, cc) ].join("\n") ] // TODO finish complicated version
        ]

        clazz.addParcelableCreatorObject(context)

        addMethod('readFromParcel') [
            addParameter('in', Parcel.newTypeReference)
            body = ['''
                try {
                    mJsonObject = new «toJavaCode(JSONObject.newTypeReference)»(in.readString());
                } catch («toJavaCode(JSONException.newTypeReference)» e) {
                    throw new «toJavaCode(RuntimeException.newTypeReference)»(e);
                }
            ''']
            //body = [ cc | entries.map[entry | entry.mapReadParcelableExpression(context, cc, clazz) ].join("\n") ] // TODO finish complicated version
            returnType = void.newTypeReference
        ]

        for (entry : entries) {
            if(entry.isJsonObject)
                enhanceClassesRecursivelyAsParcelable(findClass(entry.className), entry.childEntries, context)
        }
    }
}
