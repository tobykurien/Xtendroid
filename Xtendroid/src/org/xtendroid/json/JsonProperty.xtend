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

class JsonPropertyProcessor extends AbstractFieldProcessor {

   override doTransform(MutableFieldDeclaration field, extension TransformationContext context) {
// if (field.initializer == null)
// field.addError("A Preference field must have an initializer.")

		if (!field.declaringType.declaredFields.exists[ it.simpleName == "_jsonObj"]) {
			var f = field.declaringType.addField("_jsonObj") []
			f.setType(JSONObject.newTypeReference)
			f.setFinal(true)
			f.setVisibility(Visibility::PROTECTED)
						
			var c = field.declaringType.addConstructor [
			]
			c.addParameter("jsonObj", JSONObject.newTypeReference)
			c.body = [
				'''
					this._jsonObj = jsonObj;
				'''
			]
		}

      // add synthetic init-method
      var getter = if(field.type.simpleName.equalsIgnoreCase("Boolean")) "is" else "get"
      field.declaringType.addMethod(getter + field.simpleName.upperCaseFirst) [
         visibility = Visibility::PUBLIC
         returnType = field.type
         exceptions = #[ JSONException.newTypeReference ]
         
         // reassign the initializer expression to be the init method’s body
         // this automatically removes the expression as the field’s initializer
         body = [
            '''
return _jsonObj.get«field.type»("«field.simpleName»");
'''
         ]
      ]
   }
   
   def upperCaseFirst(String s) {
      s.toFirstUpper
   }
}