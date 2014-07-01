package org.xtendroid.annotations

import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.TransformationContext

@Active(typeof(LogTagProcessor))
annotation AddLogTag {
}

class LogTagProcessor extends AbstractClassProcessor {
	override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {
		clazz.addField("TAG") [
			final = true
			static = true
			type=String.newTypeReference()
			initializer = ['''"«clazz.simpleName»"''']
		]
	}
}