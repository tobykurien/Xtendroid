package org.xtendroid.annotations

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static extension org.xtendroid.utils.AnnotationLayoutUtils.*
import static extension org.xtendroid.utils.NamingUtils.*
import org.xtendroid.utils.AnnotationLayoutUtils

@Active(typeof(CustomViewGroupProcessor))
@Target(ElementType.TYPE)
annotation CustomViewGroup {
	int layout = -1
	int value = -1
}

class CustomViewGroupProcessor extends AbstractClassProcessor {
	override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {

		// determine if clazz extends ViewGroup
		val androidViewGroupType = ViewGroup.newTypeReference
		if (!androidViewGroupType.isAssignableFrom(clazz.extendedClass)) {
			clazz.addError(
				String.format("%s must extend an extending type of %s.", clazz.simpleName, androidViewGroupType.name))
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

		val viewGroupInitMethods = clazz.declaredMethods.filter[m|
			m.parameters.exists[p|p.type.equals(Context.newTypeReference)] && m.parameters.size == 1]
		val hasViewGroupInitMethods = !viewGroupInitMethods.nullOrEmpty

		// in case you prefer to set it up yourself
		val hasInitMethod = clazz.declaredMethods.exists[m|
			m.simpleName.equalsIgnoreCase("init") && m.parameters.size == 1 &&
				m.parameters?.head.type.equals(Context.newTypeReference)]
		
		// See if a layout is defined, then create accessors for them, if they actually exist
		val String layoutResId = AnnotationLayoutUtils.getLayoutValue(clazz, context, CustomViewGroup.newTypeReference)
		if (layoutResId == null || "0".equals(layoutResId) || !layoutResId.contains('R.layout')) {
			clazz.addWarning('You may add a layout resource id to the annotation, like this: @AndroidFragment(layout=R.layout...).')
			return;
		}
				
		// add fields and lazy getters for the nested views
		val viewFileName = layoutResId?.substring(layoutResId.lastIndexOf('.') + 1)
		if (viewFileName == null) {
			return;
		}

		val pathToCU = clazz.compilationUnit.filePath
		val xmlFile = pathToCU.projectFolder.append("res/layout/" + viewFileName + ".xml")
		
		context.createViewGetters(xmlFile, clazz)

		// determine there is at least one View type (e.g. ImageView or TextView) field that is contained within the custom layout
		val androidViewFields = clazz.declaredFields.filter[f|View.newTypeReference.isAssignableFrom(f.type)]
		if (androidViewFields.nullOrEmpty) {
			clazz.addError(
				"You must have at least one field of the type TextView or ImageView type or some customized type of those.")
		}

		if (!hasInitMethod) // I know: the name is very ObjC-ish.
		{
			clazz.addMethod("init") [
				visibility = Visibility.PRIVATE
				returnType = void.newTypeReference
				addParameter("context", Context.newTypeReference)
				body = [
					'''
						«IF !layoutResId.nullOrEmpty»
							«LayoutInflater.newTypeReference.name».from(context).inflate(«layoutResId», this, true);
						«ENDIF»
						«androidViewFields.map[f|
							String.format("this.%s = (%s) findViewById(R.id.%s);", f.simpleName, f.type.name,
								f.simpleName.toResourceName)].join("\n")»
						«IF hasViewGroupInitMethods»
							«viewGroupInitMethods.map[m|m.simpleName + '(context);'].join("\n")»
						«ENDIF»
					''']
			]
		}

		/**
		 * 
		 * The previous way to generate a "show" method for the adapter was too fragile.
		 * New approach with temporarily abstract method (and temporarily abstract class)
		 * 
		 */
		val abstractMethod = clazz.declaredMethods.filter[m|m.abstract]?.head
		if (abstractMethod != null) {
			clazz.abstract = false // unabstract declaring class
			abstractMethod.visibility = Visibility.PUBLIC
			abstractMethod.abstract = false
			if (abstractMethod.parameters.length == 1) {
				val paramName = abstractMethod.parameters.head.simpleName
				abstractMethod.body = [
					'''
						try
						{
							«androidViewFields.filter[f|f.type.isAssignableFrom(TextView.newTypeReference)].map[f|
								String.format("this.%s.setText(%s.get%s());", f.simpleName, paramName,
									f.simpleName.sanitizeName.toFirstUpper)].join("\n")»
							«androidViewFields.filter[f|f.type.isAssignableFrom(ImageView.newTypeReference)].map[f|
								String.format("this.%s.setBackgroundResource(%s.get%s());", f.simpleName, paramName,
									f.simpleName.sanitizeName.toFirstUpper)].join("\n")»
«««						// JSONException forced my hand, so I respond with my own sneaky throw
						}catch (Throwable e)
						{
							throw new RuntimeException(e);
						}
					''']
			}
		}
	}

	// TODO we should really stop renaming fields and get rid of stuff like this...
	def String sanitizeName(String s) {
		return s.replaceFirst("^_+", "")
	}
}