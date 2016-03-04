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

// for some reason I can't import from a different package within the same -ing module
//import static extension de.itemis.jsonized.JsonObjectEntry.*
import static extension org.xtendroid.json.JsonObjectEntry.*

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

class AndroidJsonizedProcessor extends AbstractClassProcessor {

    val reservedKeywords = #[
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
    ]

    /**
     * Called first. Only register any new types you want to generate here.
     */
    override doRegisterGlobals(ClassDeclaration clazz, RegisterGlobalsContext context) {
        // visit the whole JSON tree and register any nested classes
        registerClassNamesRecursively(clazz.jsonEntries, context)
    }

    val delayedErrorMessages = #{ '' -> '' }

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
     */
    override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {
        clazz.addWarning(delayedErrorMessages.get(clazz.simpleName))
        enhanceClassesRecursively(clazz, clazz.jsonEntries, context)
    }

    def void enhanceClassesRecursively(MutableClassDeclaration clazz, Iterable<? extends JsonObjectEntry> entries, extension TransformationContext context) {
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

        // add accessors for the entries
        for (entry : entries) {
            val basicType = entry.getComponentType(context)
            val realType = if(entry.isArray) getList(basicType) else basicType
            val memberName = if (reservedKeywords.iterator.exists[ equals(entry.key) ]) '_' + entry.key else entry.key.replaceAll("[^\\x00-\\x7F]", "")

            // add JSONObject container for lazy-getting
            if (entry.isJsonObject || entry.isArray)
            {
                clazz.addField(memberName) [
                    type = realType
                    visibility = Visibility.PROTECTED
                ]
            }

            clazz.addMethod("get" + memberName.toFirstUpper) [
                returnType = realType
                exceptions = JSONException.newTypeReference
                if (entry.isArray)
                {
                    // populate List
                    body = ['''
                        if («memberName» == null) {
                            «memberName» = new «toJavaCode(ArrayList.newTypeReference)»<«basicType.simpleName.toFirstUpper»>();
                            for (int i=0; i<«memberName».size(); i++) {
                                «memberName».add((«basicType.simpleName.toFirstUpper») mJsonObject.getJSONArray("«memberName»").get(i));
                            }
                        }
                        return «memberName»;
                    ''']
                }else if (entry.isJsonObject)
                {
                    body = ['''
                        if («memberName» == null) {
                            «memberName» = new «basicType.simpleName»(mJsonObject.getJSONObject("«memberName»"));
                        }
                        return «memberName»;
				    ''']
                }else { // is primitive (e.g. String, Number, Boolean)
                    body = ['''
                        return mJsonObject.get«basicType.simpleName.toFirstUpper»("«memberName»");
                    ''']
                }
            ]

            // chainable
            clazz.addMethod("set" + memberName.toFirstUpper) [
                addParameter(memberName, realType)
                returnType = clazz.newTypeReference
                exceptions = JSONException.newTypeReference
                if (entry.isArray)
                {
                    // ArrayList<T> === Collection<T>
                    body = ['''
                        mDirty = true;
                        mJsonObject.put("«memberName»", new «toJavaCode(JSONArray.newTypeReference)»(«memberName»));
                        return this;
                    ''']
                }else if (entry.isJsonObject)
                {
                    body = ['''
                        mDirty = true;
                        mJsonObject.put("«memberName»", «memberName».toJSONObject());
                        return this;
				    ''']
                }else {
                    body = ['''
                        mDirty = true;
                        mJsonObject.put("«memberName»", «memberName»);
                        return this;
                    ''']
                }
            ]

            if (entry.isJsonObject)
                enhanceClassesRecursively(findClass(entry.className), entry.childEntries, context)
        }
    }
}
