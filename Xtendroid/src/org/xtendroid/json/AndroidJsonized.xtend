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

    val reservedKeywords = #{
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
     *
     */
    override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {
        clazz.addWarning(delayedErrorMessages.get(clazz.simpleName))
        enhanceClassesRecursively(clazz, clazz.jsonEntries, context)
        clazz.removeAnnotation(clazz.annotations.findFirst[annotationTypeDeclaration == AndroidJsonized.newTypeReference.type])
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
            val memberName = entry.key.replaceAll("[^\\x00-\\x7F]", "").replaceAll("[^A-Za-z0-9]", "").replaceAll("\\s+","")

            // add JSONObject container for lazy-getting
            if (entry.isJsonObject || entry.isArray)
            {
                clazz.addField('_' + memberName) [
                    type = realType
                    visibility = Visibility.PROTECTED
                ]
            }

            clazz.addMethod("opt" + memberName.toFirstUpper + if (reservedKeywords.contains(memberName)) '_'  else '') [
                returnType = realType
                if (entry.isArray)
                {
                    // populate List
                    body = ['''
                        if (_«memberName» == null) {
                            «toJavaCode(JSONArray.newTypeReference)» arr = mJsonObject.optJSONArray("«entry.key»");
                            if(arr == null) return null;
                            _«memberName» = new «toJavaCode(ArrayList.newTypeReference)»<«basicType.simpleName.toFirstUpper»>();
                            for (int i=0; i<_«memberName».size(); i++) {
                                _«memberName».add((«basicType.simpleName.toFirstUpper») arr.opt(i));
                            }
                        }
                        return _«memberName»;
                    ''']
                }else if (entry.isJsonObject)
                {
                    body = ['''
                        if (_«memberName» == null) {
                            if (mJsonObject.optJSONObject("«entry.key»") == null) return null;
                            _«memberName» = new «basicType.simpleName»(mJsonObject.optJSONObject("«entry.key»"));
                        }
                        return _«memberName»;
				    ''']
                }else { // is primitive (e.g. String, Number, Boolean)
                    body = ['''
                        return mJsonObject.opt«basicType.simpleName.toFirstUpper»("«entry.key»");
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
                        if (_«memberName» == null) {
                            _«memberName» = new «toJavaCode(ArrayList.newTypeReference)»<«basicType.simpleName.toFirstUpper»>();
                            JSONArray vals = mJsonObject.getJSONArray("«entry.key»");
                            for (int i=0; i < vals.length(); i++) {
                                _«memberName».add((«basicType.simpleName.toFirstUpper») vals.get(i)); 
                            }
                        }
                        return _«memberName»;
                    ''']
                }else if (entry.isJsonObject)
                {
                    body = ['''
                        if (_«memberName» == null) {
                            _«memberName» = new «basicType.simpleName»(mJsonObject.getJSONObject("«entry.key»"));
                        }
                        return _«memberName»;
				    ''']
                }else { // is primitive (e.g. String, Number, Boolean)
                    body = ['''
                        return mJsonObject.get«basicType.simpleName.toFirstUpper»("«entry.key»");
                    ''']
                }
            ]

            // chainable
            clazz.addMethod("set" + memberName.toFirstUpper + if (reservedKeywords.contains(memberName)) '_'  else '') [
                addParameter('_' + memberName, realType)
                returnType = clazz.newTypeReference
                exceptions = JSONException.newTypeReference
                if (entry.isArray)
                {
                    // ArrayList<T> === Collection<T>
                    body = ['''
                        mDirty = true;
                        mJsonObject.put("«entry.key»", new «toJavaCode(JSONArray.newTypeReference)»(_«memberName»));
                        return this;
                    ''']
                }else if (entry.isJsonObject)
                {
                    body = ['''
                        mDirty = true;
                        mJsonObject.put("«entry.key»", _«memberName».toJSONObject());
                        return this;
				    ''']
                }else {
                    body = ['''
                        mDirty = true;
                        mJsonObject.put("«entry.key»", _«memberName»);
                        return this;
                    ''']
                }
            ]

            if (entry.isJsonObject)
                enhanceClassesRecursively(findClass(entry.className), entry.childEntries, context)
        }
    }
}
