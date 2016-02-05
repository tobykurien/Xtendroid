package org.xtendroid.json
//package de.itemis.jsonized // for some reason
// the annotation refuses to import from a different package
// NOTE: the IDE plugin gives a false impression.

import com.google.common.base.CaseFormat
import com.google.gson.JsonArray
import com.google.gson.JsonElement
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import com.google.gson.JsonPrimitive
import java.io.InputStreamReader
import java.net.URL
import java.util.Map
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.CompilationUnit
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.annotations.Data

/**
    The IDE is probably going to show false positives, like java.lang.NoClassDefFoundError
    but when running the tests, just run ./gradlew :XtendroidTest:cAT
 */
@Data class JsonObjectEntry {
	
	/**
	 * Parses the value of the first annotation as JSON and turns it into an iterable of JsonObjectEntries.
	 */
	def static Iterable<JsonObjectEntry> getJsonEntries(ClassDeclaration clazz) throws NoClassDefFoundError {
		val string = clazz.annotations.head.getValue('value').toString

		// open a url instead
		if (!string.trim.startsWith("{")) {
			val in = new URL(string).openStream;
			try {
				val jsonElement = new JsonParser().parse(new InputStreamReader(in))
				val jsonObject = if(jsonElement.jsonArray) {
					jsonElement.asJsonArray.get(0) as JsonObject
				} else {
					jsonElement.asJsonObject
				}
				return jsonObject.getEntries(clazz.compilationUnit)
			}catch (NoClassDefFoundError e) {
				throw e // pass on to addError
			} finally {
				in.close
			}
		}

		// json
		return (new JsonParser().parse(string) as JsonObject).getEntries(clazz.compilationUnit)
	}
	
	/**
	 * @return an iterable of JsonObjectEntries
	 */
	private static def Iterable<JsonObjectEntry> getEntries(JsonElement e, CompilationUnit unit) {
		switch e {
			JsonObject : {
				e.entrySet.map[new JsonObjectEntry(unit, it)]
			}
			default : #[]
		}
	}
	
	CompilationUnit unit
	Map.Entry<String, JsonElement> entry
	
	/**
	 * @return the entry key, i.e. the Json name
	 */
	def String getKey() {
		return entry.key
	}
	
	/**
	 * @return the value of this entry
	 */
	def JsonElement getValue() {
		return entry.value
	}
	
	/**
	 * @return whether this entry contains an array
	 */
	def boolean isArray() {
		entry.value instanceof JsonArray
	}
	
	/**
	 * @return whether this entry contains a nested JsonObject (directly or indirectly through a JsonArray)
	 */
	def boolean isJsonObject() {
		return getJsonObject != null
	}
	
	private def getJsonObject() {
		var value = entry.value
		if (isArray)
			value = (value as JsonArray).head
		if (value instanceof JsonObject) {
			return value
		}
		return null
	}
	
	/**
	 * @return the property name. It's the JSON entry key turned into a Java identifer.
	 */
	def getPropertyName() {
		val result = CaseFormat::UPPER_UNDERSCORE.to(CaseFormat::LOWER_CAMEL, entry.key.replace(' ', '_'))
        //val result = entry.key.replace(' ', '_') // simplify
		if (isArray)
			return if (result.endsWith('s')) result else result + 's' // TODO WTF plural is with an 's'?
		return if (result=='class') {
			'clazz'
		} else {
			result
		}
	}
	
	/**
	 * @return the fully qualified class name to use if this is entry contains a JsonObject
	 */
	def getClassName() {
		if (isJsonObject) {
			val simpleName = CaseFormat::UPPER_UNDERSCORE.to(CaseFormat::UPPER_CAMEL, entry.key.replace(' ', '_'))
            //val simpleName = CaseFormat::UPPER_CAMEL.to(CaseFormat::UPPER_UNDERSCORE, entry.key.replace(' ', '_')) // 2nd try
            //val simpleName = entry.key.replace(' ', '_').toFirstUpper // simplify
			return if (unit.packageName != null)
						unit.packageName + "." + simpleName
					else
						simpleName
		}
		return null
	}
	
	/**
	 * @return the component type, i.e. the type of the value or the type of the first entry if value is a JsonArray 
	 */
	def TypeReference getComponentType(extension TransformationContext ctx) {
		val v = if (entry.value instanceof JsonArray) {
			(entry.value as JsonArray).head
		} else {
			entry.value
		}
		switch v {
			JsonPrimitive: {
				if (v.isBoolean)
					typeof(boolean).newTypeReference
				else if (v.isNumber) {
                    if (v.asString.contains('.')) {
                        typeof(double).newTypeReference
                    }else {
                        typeof(long).newTypeReference
                    }
                }else if (v.isString)
					String.newTypeReference
			}
			JsonObject: {
				findClass(className).newTypeReference
			}
		}
	}
	
	/**
	 * @return the JsonObjectEntrys or <code>null</code> if the value is not a JsonObject
	 */
	def Iterable<JsonObjectEntry> getChildEntries() {
		if (isJsonObject) {
			return getEntries(getJsonObject, unit)
		}
		return #[]
	}

}