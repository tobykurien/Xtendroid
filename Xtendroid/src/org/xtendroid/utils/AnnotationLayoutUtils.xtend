package org.xtendroid.utils

import android.view.View
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableInterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.file.Path
import org.w3c.dom.Element

import static extension org.xtendroid.utils.NamingUtils.*
import static extension org.xtendroid.utils.XmlUtils.*

class AnnotationLayoutUtils {
	def static getFieldType(Element e) {
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

	def static getFieldName(Element e) {
		return e?.id?.toJavaIdentifier
	}

	def static getId(Element e) {
		val id = e.getAttribute("android:id")
		if (id.startsWith("@+id/")) {
			return id.substring(5)
		}
		return null
	}

	def static addLazyGetter(extension TransformationContext context, extension Element element,
		MutableClassDeclaration clazz) {

		// determine android:id
		val id = element?.id
		val name = element?.fieldName
		val fieldType = element?.fieldType?.newTypeReference
		if (name != null && fieldType != null) {
			val fieldName = '_' + name.toFirstLower
			if (clazz.findDeclaredField(fieldName) == null) {
				clazz.addField('_' + name.toFirstLower) [
					final = false
					static = false
					type = fieldType
					initializer = [
						'''
							null
						''']
				]
			}

			// lazy getter
			val methodName = 'get' + name.toFirstUpper
			if (clazz.findDeclaredMethod(methodName) == null) {
				clazz.addMethod(methodName) [
					returnType = fieldType
					body = [
						'''
							if (_«name.toFirstLower» ==  null)
								_«name.toFirstLower» = («toJavaCode(fieldType)») findViewById(R.id.«id»);
							return _«name.toFirstLower»;
						''']
				]
			}
		}
	}

	def static void createViewGettersWithCallBack(extension TransformationContext context, Path xmlFilePath,
		MutableClassDeclaration clazz, MutableInterfaceDeclaration callbacksType) {

		val viewType = View.newTypeReference
		xmlFilePath.contentsAsStream.getDocument.traverseAllNodes [
			// recursively read includes
			if (it.nodeName.equals('include') && it.hasAttribute('layout')) {

				//  <include layout="@layout/titlebar"/>
				val layoutFileName = it.getAttribute('layout')?.substring(8)

				val pathToCU = clazz.compilationUnit.filePath

				// TODO support res/layout-{suffix} 
				val xmlFile = pathToCU.projectFolder.append("res/layout/" + layoutFileName + ".xml")

				// error handling, there is no file
				if (!xmlFile.exists) {
					clazz.annotations.head.addError("There is no file in '" + xmlFile + "'.")
					return;
				}
				context.createViewGettersWithCallBack(xmlFile, clazz, callbacksType)
			}
			context.addLazyGetter(it, clazz)
			// check for strings
			val onClick = getAttribute("android:onClick")
			if (!onClick.nullOrEmpty && fieldType != null) {
				callbacksType.addMethod(NamingUtils.toJavaIdentifier(onClick)) [
					addParameter("element", viewType)
				]
			}
		]

	}

	def static void createViewGetters(
		extension TransformationContext context,
		Path xmlFilePath,
		MutableClassDeclaration clazz
	) {
		xmlFilePath.contentsAsStream.getDocument.traverseAllNodes [

			// recursively read includes
			if (it.nodeName.equals('include') && it.hasAttribute('layout')) {

				//  <include layout="@layout/titlebar"/>
				val layoutFileName = it.getAttribute('layout')?.substring(8)

				val pathToCU = clazz.compilationUnit.filePath

				// TODO support res/layout-{suffix} 
				val xmlFile = pathToCU.projectFolder.append("res/layout/" + layoutFileName + ".xml")

				// error handling, there is no file
				if (!xmlFile.exists) {
					clazz.annotations.head.addError("There is no file in '" + xmlFile + "'.")
					return;
				}
				context.createViewGetters(xmlFile, clazz)
			}
			context.addLazyGetter(it, clazz)
		]
	}

   // TODO unify and refactor out with @CustomViewGroup, @AndroidFragment 
   def public static String getLayoutValue(MutableClassDeclaration annotatedClass, extension TransformationContext context, TypeReference typeRef) {
      var value = annotatedClass.annotations.findFirst[
         annotationTypeDeclaration==typeRef.type
      ].getExpression("layout")
      
      if (value == null || value.toString.trim == "-1") {
      	value = annotatedClass.annotations.findFirst[
            annotationTypeDeclaration==typeRef.type
         ].getExpression("value")
         
         if (value == null) {
            return null
         }
      }
      return value.toString
   }
}
