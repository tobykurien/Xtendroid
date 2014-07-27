package org.xtendroid.annotations

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static extension org.xtendroid.utils.AnnotationLayoutUtils.*

@Active(typeof(FragmentProcessor))
annotation AndroidFragment {
	int layout = 0
}

class FragmentProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {

		// add #findViewById just like the Activity
		var exists = clazz.declaredMethods.exists[m|m.simpleName == "findViewById"]
		if (!exists)
			clazz.addMethod("findViewById") [
				visibility = Visibility::PUBLIC
				addParameter("resId", primitiveInt)
				returnType = typeof(View).newTypeReference
				body = [
					'''
						return getView().findViewById(resId);
					'''
				]
			]

		// add ctor, orientation changes cause crashes without it
		if (!clazz.declaredConstructors.exists[ctor|ctor.parameters.empty]) {
			clazz.addConstructor [
				visibility = Visibility::PUBLIC
				body = [
					'''
						// empty ctor prevents crashes
					''']
			]
		}

		// See if a layout is defined, then create accessors for them, if they actually exist
		// TODO I suspect that @CustomViewGroup in AndroidAdapter can reuse the layout parameter getter method
		val String layoutResId = clazz.annotations.findFirst [
			AndroidFragment.newTypeReference.type.equals(annotationTypeDeclaration)
		]?.getExpression("layout")?.toString

		if (layoutResId == null || "0".equals(layoutResId) || !layoutResId.contains('R.layout')) {
			clazz.addWarning('You may add a layout resource id to the annotation, like this: @AndroidFragment(layout=R.layout...).')
			return;
		}

		val viewFileName = layoutResId?.substring(layoutResId.lastIndexOf('.') + 1)
		if (viewFileName == null) {
			return;
		}

		val pathToCU = clazz.compilationUnit.filePath
		// TODO support res/layout-{suffix} 
		val xmlFile = pathToCU.projectFolder.append("res/layout/" + viewFileName + ".xml")

		// error handling, there is no file
		if (!xmlFile.exists) {
			clazz.annotations.head.addError("There is no file in '" + xmlFile + "'.")
			return;
		}

		// if the user supplied a layout, inflate it
		if (!clazz.declaredMethods.exists[simpleName.equals("onCreateView")])
			clazz.addMethod("onCreateView") [
				addAnnotation(Override.newAnnotationReference)
				returnType = View.newTypeReference
				addParameter("inflater", LayoutInflater.newTypeReference)
				addParameter("container", ViewGroup.newTypeReference)
				addParameter("savedInstanceState", Bundle.newTypeReference)
				body = [
					'''
						View view = inflater.inflate(«layoutResId», container, false);
						return view;
					''']
			]

		context.createViewGetters(xmlFile, clazz)
	}
}
