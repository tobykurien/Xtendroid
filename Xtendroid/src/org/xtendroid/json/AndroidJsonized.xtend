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

// for some reason I can't import from a different package within the same -ing module
//import static extension de.itemis.jsonized.JsonObjectEntry.*
import static extension org.xtendroid.json.JsonObjectEntry.*
import org.json.JSONException

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

    /**
     * Called first. Only register any new types you want to generate here.
     */
    override doRegisterGlobals(ClassDeclaration clazz, RegisterGlobalsContext context) {
        // visit the whole JSON tree and register any nested classes
        registerClassNamesRecursively(clazz.jsonEntries, context)
    }

    private def void registerClassNamesRecursively(Iterable<JsonObjectEntry> json, RegisterGlobalsContext context) {
        for (jsonEntry : json) {
            if (jsonEntry.isJsonObject) {
                context.registerClass(jsonEntry.className)
                registerClassNamesRecursively(jsonEntry.childEntries, context)
            }
        }
    }

    /**
     * Called secondly. Modify the types.
     */
    override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {
        clazz.addWarning("className: " + clazz.simpleName)
        enhanceClassesRecursively(clazz, clazz.jsonEntries, context)
        clazz.addConstructor [
            addParameter('jsonObject', JSONObject.newTypeReference)
            body = '''
                mJsonObject = jsonObject;
            '''
        ]
    }

    def void enhanceClassesRecursively(MutableClassDeclaration clazz, Iterable<? extends JsonObjectEntry> entries, extension TransformationContext context) {

        clazz.addField("mDirty") [
            type = typeof(boolean).newTypeReference
            visibility = Visibility.PRIVATE
        ]

        // do not add fields, directly modify the json object
        clazz.addField("mJsonObject") [
            type = JSONObject.newTypeReference
            visibility = Visibility.PRIVATE
        ]

        // TODO deterimine the (generated) difference between this and typeof(boolean).newTypeReference
        clazz.addMethod("isDirty") [
            returnType = Boolean.newTypeReference
            body = '''
                return mDirty;
            '''
        ]

        // TODO remove
        val string = clazz.annotations.head.getValue('value').toString
        clazz.addWarning(String.format('value = %s', string))

        // add accessors for the entries
        for (entry : entries) {
            val type = entry.getComponentType(context)
            val realType = if(entry.isArray) getList(type) else type

            // TODO remove
            clazz.addWarning(String.format('property = %s, type = %s, realType = %s', entry.propertyName, type, realType))

            // TODO map realType to real getter
            clazz.addMethod("get" + entry.key.toFirstUpper) [
                // TODO throws JSONException
                returnType = realType
                body = ['''
                    return mJsonObject.get«realType.simpleName.toFirstUpper»("«entry.key»");
				''']
                exceptions = JSONException.newTypeReference
            ]

            // chainable
            clazz.addMethod("set" + entry.key.toFirstUpper) [
                addParameter(entry.key, realType)
                returnType = clazz.newTypeReference
                body = ['''
                    mDirty = true;
                    mJsonObject.put("«entry.key»", «entry.key»);
                    return this;
				''']
                exceptions = JSONException.newTypeReference
            ]

            // TODO determine array types are correct
            // if it's a JSON Object call enhanceClass recursively
            /*
            // TODO for some reason this is fuxxored, this only applies
            // to org.json.JSONObject and org.json.JSONArray
            if (entry.isJsonObject)
                enhanceClassesRecursively(findClass(entry.className), entry.childEntries, context)
            */
        }
    }
}
