package org.xtendroid.annotations

import org.eclipse.xtend.lib.macro.AbstractFieldProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static extension org.xtendroid.utils.Utils.*

@Active(typeof(AndroidViewProcessor))
annotation AndroidView {
}

class AndroidViewProcessor extends AbstractFieldProcessor {

   override doTransform(MutableFieldDeclaration field, extension TransformationContext context) {
      val fieldName = field.simpleName
      field.simpleName = "_" + fieldName
      
      // add synthetic init-method
      field.declaringType.addMethod('_init_' + fieldName) [
         visibility = Visibility::PRIVATE
         returnType = field.type
         val rclass = "R"
         // reassign the initializer expression to be the init method’s body
         // this automatically removes the expression as the field’s initializer
         body = [
            '''
               return («field.type») findViewById(«rclass».id.«fieldName.toResourceName»);
            '''
         ]
      ]

      // add a getter method which lazily initializes the field
      field.declaringType.addMethod('get' + fieldName.upperCaseFirst) [
         returnType = field.type
         body = [
            '''
               if («field.simpleName»==null)
               «field.simpleName» = _init_«fieldName»();
               return «field.simpleName»;
            ''']
      ]
      
      field.declaringType.addField(field.simpleName) [
         visibility = Visibility::PRIVATE
         type = field.type
      ]
      field.remove
   }

}
