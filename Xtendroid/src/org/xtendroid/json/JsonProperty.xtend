package org.xtendroid.json

import org.eclipse.xtend.lib.macro.AbstractFieldProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.json.JSONObject
import org.json.JSONException

@Active(JsonPropertyProcessor)
annotation JsonProperty {
}

/**
 * @JsonProperty annotation creates a "Json bean" that accepts a JSONObject
 * and then parses it on-demand with getters.
 */
class JsonPropertyProcessor extends AbstractFieldProcessor {
   // types supported by JSONObject
   val static supportedTypes = #[
      "java.lang.Boolean", "java.lang.Double", "java.lang.Int",
      "java.lang.Long", "java.lang.String", "org.json.JSONObject",
      "org.json.JSONArray" 
   ]

   override doTransform(MutableFieldDeclaration field, extension TransformationContext context) {
      // if there isn't yet a constructor that takes a JSONObject, add it
		if (!field.declaringType.declaredFields.exists[ it.simpleName == "_jsonObj"]) {
		   // make a field for storing the JSONObject
			var f = field.declaringType.addField("_jsonObj") []
			f.setType(JSONObject.newTypeReference)
			f.setFinal(true)
			f.setVisibility(Visibility::PROTECTED)

         // create the constructor						
			var c = field.declaringType.addConstructor []
			c.addParameter("jsonObj", JSONObject.newTypeReference)
			c.body = [
				'''
					this._jsonObj = jsonObj;
				'''
			]
		}

      // rename the property to _property
      val orgName = field.simpleName
      field.simpleName = "_" + field.simpleName

      // make a flag for each property to indicate if it's been parsed
      // so that we can cache the result of parsing
      val f = field.declaringType.addField(field.simpleName + "Loaded") []
      f.setType(Boolean.newTypeReference)
      f.setInitializer(["false"])
      f.setVisibility(Visibility::PROTECTED)

      // create a getter method for the property
      var getter = if(field.type.simpleName.equalsIgnoreCase("Boolean")) "is" else "get"
      field.declaringType.addMethod(getter + orgName.upperCaseFirst) [
         visibility = Visibility::PUBLIC
         returnType = field.type
         exceptions = #[ JSONException.newTypeReference ]
         
         if (supportedTypes.contains(field.type.wrapperIfPrimitive.name)) {
            // parse the value if it hasn't already been, then return the stored result
            body = [
               '''
                  if (!«field.simpleName»Loaded) {
                     «field.simpleName» = _jsonObj.get«field.type.simpleName.upperCaseFirst»("«orgName»");
                     «field.simpleName»Loaded = true;
                  }
                  return «field.simpleName»;
               '''
            ]
         } else {
            // TODO: if it's SomeObject with a JSONObject constructor, create it
            // if it's a List<SomeObject>, then make an ArrayList (or lazy list) of those objects
            field.addError(field.type + " is not supported for @JsonProperty.")
         }
      ]
   }
   
   def upperCaseFirst(String s) {
      s.toFirstUpper
   }
}