package org.xtendroid.json

import org.eclipse.xtend.lib.macro.AbstractFieldProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.json.JSONObject
import org.json.JSONException
import org.json.JSONArray

@Active(JsonPropertyProcessor)
annotation JsonProperty {
	// Use this to explicitly state the key value (String) of the JSON Object
	String value = ""
}

// TODO either a JsonEnumProperty or add a parameter 'enums' to the existing @JsonProperty

/**
 * @JsonProperty annotation creates a "Json bean" that accepts a JSONObject
 * and then parses it on-demand with getters.
 * 
 * #getBoolean
 * #getDouble
 * #getInt
 * #getLong
 * #getString
 * #getJsonArray
 * #getJsonObject
 * 
 */
class JsonPropertyProcessor extends AbstractFieldProcessor {
   // types supported by JSONObject
   val static supportedTypes = #{
      "java.lang.Boolean" -> 'Boolean'
      , "java.lang.Double" -> 'Double'
      , "java.lang.Integer" -> 'Int'
      , "java.lang.Long" -> 'Long'
      , "java.lang.String" -> 'String'
      , "org.json.JSONObject" -> 'JSONObject'
      , "org.json.JSONArray" -> 'JSONArray'
      , "boolean" -> 'Boolean'
      , "double" -> 'Double'
      , "int" -> 'Int'
      , "long" -> 'Long'
   }
   
   val static unsupportedTypes = #[
		"float", "java.lang.Float"
   ]

   override doTransform(MutableFieldDeclaration field, extension TransformationContext context) {
	   	// startsWith because float[] and Float[] are also disallowed
		if (unsupportedTypes.exists[t | field.type.name.startsWith(t)])
            field.addError(field.type + " is not supported for @JsonProperty.")
   	
	    // if there isn't yet a constructor that takes a JSONObject, add it
		if (!field.declaringType.declaredFields.exists[ it.simpleName == "_jsonObj"]) {
		   // make a field for storing the JSONObject
			field.declaringType.addField("_jsonObj") [
				type = JSONObject.newTypeReference
				final = false
				visibility = Visibility::PROTECTED
				initializer = '''null'''
			]
	
	     // create the constructor						
			field.declaringType.addConstructor [
				addParameter("jsonObj", JSONObject.newTypeReference)
				body = ['''
					this._jsonObj = jsonObj;
				''']
			]
			
		}

	  // attempt to use the explicitly stated JSON member key, if stated
	  val annotationValue = field.findAnnotation(JsonProperty.findTypeGlobally).getValue('value') as String
      val jsonKey =  if (!annotationValue.nullOrEmpty) annotationValue else field.simpleName

      // rename the property to _property if necessary
      // Another active annotation may want to do the same...
      if (!field.simpleName.startsWith("_"))
      {
      	field.simpleName = "_" + field.simpleName
      }

      // make a flag for each property to indicate if it's been parsed
      // so that we can cache the result of parsing
      field.declaringType.addField(field.simpleName + "Loaded") [
	      type = Boolean.newTypeReference
	      initializer = ["false"]
	      visibility = Visibility::PROTECTED
      ]

      // create a getter method for the property
      var getter = if(field.type.simpleName.equalsIgnoreCase("Boolean")) "is" else "get"
      field.declaringType.addMethod(getter + field.simpleName.replaceAll('_', '').toFirstUpper) [
         visibility = Visibility::PUBLIC
         returnType = field.type
         exceptions = #[ JSONException.newTypeReference ]
         
         if (supportedTypes.containsKey(field.type.name)) {
            // parse the value if it hasn't already been, then return the stored result
            body = ['''
              if (!«field.simpleName»Loaded) {
                 «field.simpleName» = _jsonObj.get«supportedTypes.get(field.type.name)»("«jsonKey»");
                 «field.simpleName»Loaded = true;
              }
              return «field.simpleName»;
			''']
         } else if (field.type.array)
		 {
		 	val baseType = field.type.arrayComponentType
		 	if (supportedTypes.containsKey(baseType.name))
		 	{
		 		body = [
		 		'''
				if (!«field.simpleName»Loaded) {
					final «JSONArray.findTypeGlobally.qualifiedName» «field.simpleName»JsonArray = _jsonObj.getJSONArray("«jsonKey»");
					this.«field.simpleName» = new «baseType»[«field.simpleName»JsonArray.length()];
					for (int i=0; i<«field.simpleName»JsonArray.length(); i++)
					{
						this.«field.simpleName»[i] = «field.simpleName»JsonArray.get«supportedTypes.get(baseType.name)»(i);
					}
					«field.simpleName»Loaded = true;
				}
				return «field.simpleName»;
		 		'''
		 		]
		 	}
	        // TODO interrogate base type for the JSONObject param in the ctor (no -ing clue how) -> found out how: field.addError(field.type.arrayComponentType.name)... I need a MutableFieldDefinition... not a TypeReference... damn
	         
         } else if (field.type.name.startsWith('java.util.List') && field.type.actualTypeArguments.length == 1) {
         	
			if (field.type.actualTypeArguments.exists[a | supportedTypes.containsKey(a.name)])
			{
				val baseTypeName = field.type.actualTypeArguments.map[a | a.name].join()
		 		body = [
		 		'''
				if (!«field.simpleName»Loaded) {
					final «JSONArray.findTypeGlobally.qualifiedName» «field.simpleName»JsonArray = _jsonObj.getJSONArray("«jsonKey»");
					this.«field.simpleName» = new java.util.ArrayList<«baseTypeName»>();
					for (int i=0; i<«field.simpleName»JsonArray.length(); i++)
					{
						this.«field.simpleName».add(«field.simpleName»JsonArray.get«supportedTypes.get(baseTypeName)»(i));
					}
					«field.simpleName»Loaded = true;
				}
				return «field.simpleName»;
		 		'''
		 		]
			}
			// TODO interrogate base type for the List generics param for a JSONObject param in the ctor
//			else
//			{
//	         	// custom type
//				
//			}
         	
         } else if (field.declaringType.declaredConstructors.exists[ctor | ctor.parameters.exists[p | p.type.equals(JSONObject.findTypeGlobally) && ctor.parameters.length == 1]])
		 {
            // if it's single POJO that has a single ctor with a single JSONObject parameter, create it
        	body = ['''
              if (!«field.simpleName»Loaded) {
                 «field.simpleName» = new «field.declaringType.simpleName»(_jsonObj.getJSONObject("«jsonKey»"));
                 «field.simpleName»Loaded = true;
              }
              return «field.simpleName»;
        	''']
        	
        	// if (!field.declaringType.declaredConstructors.exists[ctor | ctor.parameters.exists[p | p.type.equals(JSONArray.findTypeGlobally)]])
//				 JSONArray «field.simpleName»JsonArray = _jsonObj.getJSONArray("«orgName»");
//                 for (int i=0; i<«field.simpleName»JsonArray.length(); i++);
//                 {
//                 	«field.simpleName» = 
//                 }
         }else {
            field.addError(field.type + " is not supported for @JsonProperty")
         }
      ]
   }
}