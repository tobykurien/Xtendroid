package org.xtendroid.json

import org.eclipse.xtend.lib.macro.AbstractFieldProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.json.JSONObject
import org.json.JSONException
import org.json.JSONArray
import java.util.concurrent.ConcurrentHashMap
import java.text.DateFormat
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.Date

@Active(JsonPropertyProcessor)
annotation JsonProperty {
	// Use this to explicitly state the key value (String) of the JSON Object
	// and define the expected String for DateFormat for Date fields
	String value = ""
}

// TODO either a JsonEnumProperty or add a parameter 'enums' to the existing @JsonProperty
/**
 * 
 * Future work:
 * annotation JsonEnumProperty
 * {
 *   String... value
 * }
 * 
 * should transpile to
 * 
 * public @interface JsonEnumProperty {
 *   String[] value() default “all”;
 * }
 * 
 * So I can just define which enum values I expect from a JSON String.
 * A switch statement in getter method that returns a enum object (from a generated enum type)
 * will be generated accordingly.
 */

/**
 * @JsonProperty annotation creates a "Json bean" that accepts a JSONObject
 * and then parses it on-demand with getters.
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
   
   val public static jsonObjectFieldName = "_jsonObj"

   override doTransform(MutableFieldDeclaration field, extension TransformationContext context) {
	   	// startsWith because float[] and Float[] are also disallowed
		if (unsupportedTypes.exists[t | field.type.name.startsWith(t)])
            field.addError(field.type + " is not supported for @JsonProperty.")
   	
	    // if there isn't yet a constructor that takes a JSONObject, add it
		if (!field.declaringType.declaredFields.exists[ it.simpleName == jsonObjectFieldName]) {
		   // make a field for storing the JSONObject
			field.declaringType.addField(jsonObjectFieldName) [
				type = JSONObject.newTypeReference
				final = false
				visibility = Visibility::PROTECTED
				initializer = '''null'''
			]
	
	     // create the constructor						
			field.declaringType.addConstructor [
				addParameter("jsonObj", JSONObject.newTypeReference)
				body = ['''
					this.«jsonObjectFieldName» = jsonObj;
				''']
			]
			
		}

	  // attempt to use the explicitly stated JSON member key, if stated
	  val annotationValue = field.findAnnotation(JsonProperty.findTypeGlobally).getValue('value') as String
      val jsonKey =  if (!annotationValue.nullOrEmpty && !field.type.name.startsWith('java.util.Date')) annotationValue else field.simpleName

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
                 «field.simpleName» = «jsonObjectFieldName».get«supportedTypes.get(field.type.name)»("«jsonKey»");
                 «field.simpleName»Loaded = true;
              }
              return «field.simpleName»;
			''']
         } else if (field.type.name.startsWith('java.util.Date'))
		 {
		 	val dateFormat = annotationValue
			exceptions = #[ java.text.ParseException.newTypeReference, org.json.JSONException.newTypeReference ]
		 	if (field.type.array)
		 	{
		 		body = [
		 		'''
				if (!«field.simpleName»Loaded) {
					final «JSONArray.findTypeGlobally.qualifiedName» «field.simpleName»JsonArray = «jsonObjectFieldName».getJSONArray("«jsonKey»");
					this.«field.simpleName» = new «java.util.Date.findTypeGlobally.simpleName»[«field.simpleName»JsonArray.length()];
					for (int i=0; i<«field.simpleName»JsonArray.length(); i++)
					{
						this.«field.simpleName»[i] = «ConcurrentDateFormatHashMap.newTypeReference.name».convertStringToDate("«dateFormat»", «field.simpleName»JsonArray.getString(i));
					}
					«field.simpleName»Loaded = true;
				}
				return «field.simpleName»;
		 		'''
		 		]
		 		
		 	}else // single object
		 	{
	            body = ['''
	              if (!«field.simpleName»Loaded) {
	                 «field.simpleName» = «ConcurrentDateFormatHashMap.newTypeReference.name».convertStringToDate("«dateFormat»", «jsonObjectFieldName».getString("«jsonKey»"));
	                 «field.simpleName»Loaded = true;
	              }
	              return «field.simpleName»;
				''']
		 	}
         } else if (field.type.array)
		 {
		 	val baseType = field.type.arrayComponentType
		 	if (supportedTypes.containsKey(baseType.name))
		 	{
		 		body = [
		 		'''
				if (!«field.simpleName»Loaded) {
					final «JSONArray.findTypeGlobally.qualifiedName» «field.simpleName»JsonArray = «jsonObjectFieldName».getJSONArray("«jsonKey»");
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
		 	}else
		 	{
		 		body = [
		 		'''
				if (!«field.simpleName»Loaded) {
					final «JSONArray.findTypeGlobally.qualifiedName» «field.simpleName»JsonArray = «jsonObjectFieldName».getJSONArray("«jsonKey»");
					this.«field.simpleName» = new «baseType»[«field.simpleName»JsonArray.length()];
					for (int i=0; i<«field.simpleName»JsonArray.length(); i++)
					{
						this.«field.simpleName»[i] = new «baseType.name»(«field.simpleName»JsonArray.getJSONObject(i));
					}
					«field.simpleName»Loaded = true;
				}
				return «field.simpleName»;
		 		'''
		 		]
		 		
		 	}
	        // TODO interrogate base type for the JSONObject param in the ctor (no -ing clue how) -> found out how: field.addError(field.type.arrayComponentType.name)... I need a MutableFieldDefinition... not a TypeReference... damn
	         
         } else if (field.type.name.startsWith('java.util.List')) {
         	if (field.type.name.endsWith('Date>'))
         	{
		 		val dateFormat = annotationValue
				val baseTypeName = field.type.actualTypeArguments.head.name
				body = ['''
				if (!«field.simpleName»Loaded) {
					final «JSONArray.findTypeGlobally.qualifiedName» «field.simpleName»JsonArray = «jsonObjectFieldName».getJSONArray("«jsonKey»");
					this.«field.simpleName» = new java.util.ArrayList<«baseTypeName»>();
					for (int i=0; i<«field.simpleName»JsonArray.length(); i++)
					{
						((java.util.ArrayList<«baseTypeName»>) this.«field.simpleName»).add(«ConcurrentDateFormatHashMap.newTypeReference.name».convertStringToDate("«dateFormat»", «field.simpleName»JsonArray.getString(i)));
					}
					«field.simpleName»Loaded = true;
				}
				return «field.simpleName»;
				''']
				exceptions = #[ java.text.ParseException.newTypeReference, org.json.JSONException.newTypeReference ]
         	}else if (field.type.actualTypeArguments.exists[a | supportedTypes.containsKey(a.name)])
			{
				val baseTypeName = field.type.actualTypeArguments.map[a | a.name].join()
		 		body = [
		 		'''
				if (!«field.simpleName»Loaded) {
					final «JSONArray.findTypeGlobally.qualifiedName» «field.simpleName»JsonArray = «jsonObjectFieldName».getJSONArray("«jsonKey»");
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
			// TODO interrogate base type for the List generics param for a JSONObject param in the ctor, f.type.actualTypeArguments
			// in this current implementation, it is over-optimistically assumed that there is a ctor that takes a JSONObject for this generic type type
			else
			{
//				field.type.actualTypeArguments.head.type. // no way to interrogate yet
	         	// custom type
				val baseTypeName = field.type.actualTypeArguments.head.name
				body = ['''
				if (!«field.simpleName»Loaded) {
					final «JSONArray.findTypeGlobally.qualifiedName» «field.simpleName»JsonArray = «jsonObjectFieldName».getJSONArray("«jsonKey»");
					this.«field.simpleName» = new java.util.ArrayList<«baseTypeName»>();
					for (int i=0; i<«field.simpleName»JsonArray.length(); i++)
					{
						((java.util.ArrayList<«baseTypeName»>) this.«field.simpleName»).add(new «baseTypeName»(«field.simpleName»JsonArray.getJSONObject(i)));
					}
					«field.simpleName»Loaded = true;
				}
				return «field.simpleName»;
				''']
			}
         	
         } else if (field.declaringType.findDeclaredConstructor(JSONObject.newTypeReference()) != null)
		 {
            // if it's single POJO that has a single ctor with a single JSONObject parameter, create it
        	body = ['''
              if (!«field.simpleName»Loaded) {
                 «field.simpleName» = new «field.type.simpleName»(«jsonObjectFieldName».getJSONObject("«jsonKey»"));
                 «field.simpleName»Loaded = true;
              }
              return «field.simpleName»;
        	''']
         }else {
            field.addError(field.type + " is not supported for @JsonProperty")
         }
      ]
   }
}

class ThreadLocalDateFormatter extends ThreadLocal<DateFormat>
{
	String dateFormat
	
	public new(String dateFormat)
	{
		this.dateFormat = dateFormat
	}
	
	public override get()
	{
		return super.get
	}
	
	protected override def DateFormat initialValue()
	{
		return new SimpleDateFormat(dateFormat)
	}
	
	public override def void set(DateFormat value)
	{
		super.set(value)
	}
}

/**
 * 
 * Every Thread gets a different DateFormat object, to prevent unsafe multi-threaded use
 * 
 */
class ConcurrentDateFormatHashMap
{
	public val static concurrentMap = new ConcurrentHashMap<String, ThreadLocal<DateFormat>>();
	private new() {}
	public def static convertStringToDate(String dateFormat, String dateRaw) throws ParseException
	{
		if (!concurrentMap.containsKey(dateFormat))
		{
			concurrentMap.put(dateFormat, new ThreadLocalDateFormatter(dateFormat))
		}
		return concurrentMap.get(dateFormat).get().parse(dateRaw);
	}
	
	public def static convertDateToString(String dateFormat, Date date) throws ParseException
	{
		if (!concurrentMap.containsKey(dateFormat))
		{
			concurrentMap.put(dateFormat, new ThreadLocalDateFormatter(dateFormat))
		}
		return concurrentMap.get(dateFormat).get().format(date);
	}
}