package org.xtendroid.annotations

import android.content.Context
import android.util.AttributeSet
import android.view.View
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

@Active(typeof(CustomViewProcessor))
@Target(ElementType.TYPE)
annotation CustomView {}

/**
 * 
 * @CustomView is an undressed version of @CustomViewGroup
 * 
 */
class CustomViewProcessor extends AbstractClassProcessor {
	override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {

		// determine if clazz extends View
		// TODO make a utility function for this 
		val androidViewType = View.newTypeReference
		if (!androidViewType.isAssignableFrom(clazz.extendedClass)) {
			clazz.addError(
				String.format("%s must extend an extending type of %s.", clazz.simpleName, androidViewType.name))
		}

		clazz.addConstructor [
			visibility = Visibility.PUBLIC
			addParameter("context", Context.newTypeReference)
			body = [
				'''
					super(context);
					init(context);
				''']
		]

		clazz.addConstructor [
			visibility = Visibility.PUBLIC
			addParameter("context", Context.newTypeReference)
			addParameter("attrs", AttributeSet.newTypeReference)
			body = [
				'''
					super(context, attrs);
					init(context);
				''']
		]

		clazz.addConstructor [
			visibility = Visibility.PUBLIC
			addParameter("context", Context.newTypeReference)
			addParameter("attrs", AttributeSet.newTypeReference)
			addParameter("defStyle", int.newTypeReference)
			body = [
				'''
					super(context, attrs, defStyle);
					init(context);
				''']
		]

		// collect all the init methods and call them together
		val initMethods = clazz.declaredMethods.filter[m|
			m.parameters.exists[p|p.type.equals(Context.newTypeReference)] && m.parameters.size == 1]

		// in case you prefer to set it up yourself
		val hasMainInitMethod = clazz.declaredMethods.exists[m|
			m.simpleName.equalsIgnoreCase("init") && m.parameters.size == 1 &&
				m.parameters?.head.type.equals(Context.newTypeReference)]

		if (!hasMainInitMethod) {
			clazz.addMethod("init") [
				visibility = Visibility.PRIVATE
				returnType = void.newTypeReference
				addParameter("context", Context.newTypeReference)
				body = [
					'''
						«initMethods.map[m|m.simpleName + '(context);'].join("\n")»
					''']
			]
		}

	}

}

