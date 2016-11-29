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

    protected def void enhanceClassesRecursively(MutableClassDeclaration clazz, Iterable<? extends JsonObjectEntry> entries, extension TransformationContext context) {
        clazz.addJsonPlaceholderAndDirtyFlag(context)

        // add accessors for the entries
        for (entry : entries) {
            val basicType = entry.getComponentType(context)
            val realType = if(entry.isArray) getList(basicType) else basicType
            val memberName = entry.key.replaceAll("[^\\x00-\\x7F]", "").replaceAll("[^A-Za-z0-9]", "").replaceAll("\\s+","")
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
                                «_memberName».add((«basicType.simpleName.toFirstUpper») arr.opt(i));
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
                if (entry.isArray)
                {
                    // populate List
                    body = ['''
                        if («_memberName» == null) {
                            «_memberName» = new «toJavaCode(ArrayList.newTypeReference)»<«basicType.simpleName.toFirstUpper»>();
                            for (int i=0; i<«_memberName».size(); i++) {
                                «_memberName».add((«basicType.simpleName.toFirstUpper») mJsonObject.getJSONArray("«entry.key»").get(i));
                            }
                        }
                        return «_memberName»;
                    ''']
                }else if (entry.isJsonObject)
                {
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

    static def String mapReadParcelableExpression(JsonObjectEntry entry, extension TransformationContext context, MutableClassDeclaration clazz) {
        val basicType = entry.getComponentType(context)
        val realType = if(entry.isArray) getList(basicType) else basicType // context.getList(basicType)
        val memberName = entry.key.replaceAll("[^\\x00-\\x7F]", "").replaceAll("[^A-Za-z0-9]", "").replaceAll("\\s+","")
        val _memberName = '_' + memberName

        if (entry.isArray) {
            return if (basicType.isTypeOf("bool")) {
                '''
                «SparseBooleanArray.newTypeReference» «_memberName»SparseBoolean = in.readSparseBooleanArray();
                if («_memberName»SparseBoolean != null) {
                    List<Boolean> arrayList = new ArrayList<Boolean>(«_memberName»SparseBoolean.size());
                    for (int i = 0; i < sparseArray.size(); i++) {
                        «_memberName».add(«_memberName»SparseBoolean.valueAt(i));
                    }
                }
                '''
            }else if (basicType.isTypeOf("string", "long", "double")) {
                '''«_memberName» = in.create«supportedPrimitiveArrayType.get(realType.simpleName)»();'''
            } else {
                '''«_memberName» = in.createTypedArrayList(«realType.simpleName».CREATOR);'''
            }
        }else if (entry.isJsonObject) {
            // TODO determine we are using the correct CREATOR object
            return '''
            «_memberName» = («basicType.simpleName») «basicType.simpleName».CREATOR.createFromParcel(in);
            '''
        }

        return if (!basicType.isTypeOf("bool")) {
            // TODO string
            // TODO integer (convert to long)
            // TODO double  (convert to double)
            '''«_memberName» = in.read«supportedPrimitiveScalarType.get(basicType.simpleName)»();'''
        }else /* if boolean */ {
            '''«_memberName» = in.readInt() > 0;''' // 0 == false
        }
    }

    static def mapWriteParcelableExpression(JsonObjectEntry entry, extension TransformationContext context) {
        '''

        '''
    }

    def enhanceClassesRecursivelyAsParcelable(extension MutableClassDeclaration clazz, Iterable<? extends JsonObjectEntry> entries, extension TransformationContext context) {

        clazz.addImplementsParcelable(context)

        clazz.addMethodDescribeContents(context)

        addMethod("writeToParcel")  [
            returnType = void.newTypeReference
            addParameter('out', Parcel.newTypeReference)
            addParameter('flags', int.newTypeReference)
            addAnnotation(Override.newAnnotationReference)
            body = [ entries.map[entry | entry.mapWriteParcelableExpression(context) ].join ]
        ]

        clazz.addParcelableCreatorObject(context)

        clazz.addParcelableCtor(context)

        addMethod('readFromParcel') [
            addParameter('in', Parcel.newTypeReference)
            body = [ entries.map[entry | entry.mapReadParcelableExpression(context, clazz) ].join ]
            returnType = void.newTypeReference
        ]

        for (entry : entries) {
            if(entry.isJsonObject)
                enhanceClassesRecursivelyAsParcelable(findClass(entry.className), entry.childEntries, context)
        }
    }
}
