package org.xtendroid.db

import android.app.Fragment
import android.content.Context
import java.util.List
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMemberDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

@Active(typeof(AndroidDatabaseProcessor))
annotation AndroidDatabase {
}

class AndroidDatabaseProcessor implements TransformationParticipant<MutableMemberDeclaration> {

	override doTransform(List<? extends MutableMemberDeclaration> elements, TransformationContext context) {
		elements.forEach[e|e.transform(context)]
	}

	def dispatch void transform(MutableClassDeclaration clazz, extension TransformationContext context) {
      
		// extend BaseDbService
      if (clazz.extendedClass == Object.newTypeReference()) {
         clazz.extendedClass = BaseDbService.newTypeReference
      }    

		// add singleton instance getter
      clazz.addMethod("getDb") [
         addParameter("activity", Context.newTypeReference)
         setReturnType(clazz.newTypeReference())
         setStatic(true)
         body = ['''
            return new «clazz.simpleName»(activity);
         ''']
      ]
		
		// add a getter for fragments too
      clazz.addMethod("getDb") [
         addParameter("fragment", Fragment.newTypeReference)
         setReturnType(clazz.newTypeReference())
         setStatic(true)
         body = ['''
            return new «clazz.simpleName»(fragment.getActivity());
         ''']
      ]
      
      // make constructors protected, use the getDb() methods above
      clazz.declaredConstructors.forEach[c|
      	c.visibility = Visibility.PROTECTED
      ]
 	}

	def dispatch void transform(MutableFieldDeclaration it, extension TransformationContext context) {
		it.doTransform(context)
	}

	def doTransform(MutableFieldDeclaration field, extension TransformationContext context) {
   }
}
