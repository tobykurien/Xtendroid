package org.xtendroid.annotations

import android.view.View
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.w3c.dom.Element
import static extension org.xtendroid.utils.NamingUtils.*

import static extension org.xtendroid.utils.XmlUtils.*
import android.os.Bundle
import android.view.LayoutInflater
import android.view.ViewGroup

import java.lang.Override

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
		val String layoutResId = clazz.annotations.findFirst [
			AndroidFragment.newTypeReference.type.equals(annotationTypeDeclaration)
		]?.getExpression("layout")?.toString

		if ("0".equals(layoutResId)) {
			return;
		}

		val viewFileName = layoutResId?.substring(layoutResId.lastIndexOf('.') + 1)
		if (viewFileName == null) {
			return;
		}
		val pathToCU = clazz.compilationUnit.filePath
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

		// TODO also read the includes (recursively) for deeper structures
		// read the XML
		xmlFile.contentsAsStream.getDocument.traverseAllNodes [
			// check for ids
			val id = getId(it)
			val name = getFieldName(it)
			val fieldType = getFieldType(it)?.newTypeReference
			if (name != null && fieldType != null) {
				clazz.addField('m' + name.toFirstUpper) [
					final = false
					static = false
					type = fieldType
					initializer = [
						'''
							null
						''']
				]
				// lazy getter
				clazz.addMethod('get' + name.toFirstUpper) [
					returnType = fieldType
					body = [
						'''
							if (m«name.toFirstUpper» ==  null)
								m«name.toFirstUpper» = («toJavaCode(fieldType)») findViewById(R.id.«id»);
							return m«name.toFirstUpper»;
						''']
				]
			}
		]
	}

	def getFieldType(Element e) {
		val clazz = try {
			Class.forName("android.widget." + e.nodeName)
		} catch (ClassNotFoundException exception) {
			try {
				Class.forName("android.view." + e.nodeName)
			} catch (ClassNotFoundException exception1) {
				try {
					Class.forName(e.nodeName)
				} catch (ClassNotFoundException exception2) {
					null
				}
			}
		}

		if (clazz != null && View.isAssignableFrom(clazz)) {
			return clazz
		}
		return null
	}

	def getFieldName(Element e) {
		return e?.id?.toJavaIdentifier
	}

	def getId(Element e) {
		val id = e.getAttribute("android:id")
		if (id.startsWith("@+id/")) {
			return id.substring(5)
		}
		return null
	}

}
