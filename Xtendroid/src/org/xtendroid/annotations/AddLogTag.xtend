package org.xtendroid.annotations

import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.TransformationContext
import java.lang.annotation.Target
import java.lang.annotation.ElementType

@Active(typeof(LogTagProcessor))
@Target(ElementType.TYPE)
annotation AddLogTag {
	String value = ""
}

class LogTagProcessor extends AbstractClassProcessor {
	override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {
		
		val annotationValue = clazz.annotations.filter[a| "AddLogTag".equals(a.annotationTypeDeclaration.simpleName)].head.getStringValue("value")
		val String tag = if( annotationValue.nullOrEmpty ) clazz.simpleName else annotationValue
		
		clazz.addField("TAG") [
			final = true
			static = true
			type=String.newTypeReference()
			initializer = ['''"«tag»"''']
		]
	}
}