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
					Class.forName(e.nodeName, false, Class.classLoader)
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

	def static void createViewGettersWithCallBack(
	   extension TransformationContext context,
	   String layoutFilename, 
		MutableClassDeclaration clazz, 
		MutableInterfaceDeclaration callbacksType) {

		val viewType = View.newTypeReference
      val xmlFile = AnnotationLayoutUtils.getLayoutPath(context, layoutFilename, clazz)
      if (xmlFile == null) return;
             
		xmlFile.contentsAsStream.getDocument.traverseAllNodes [
			// recursively read includes
			if (it.nodeName.equals('include') && it.hasAttribute('layout')) {
				//  <include layout="@layout/titlebar"/>
				val layoutFileName = it.getAttribute('layout')?.substring(8)
				context.createViewGettersWithCallBack(layoutFileName, clazz, callbacksType)
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
   
   /**
    * Work out the path to a specified layout. Must support Eclipse
    * and Android Studio/gradle project structures.
    */
   def static getLayoutPath(
      extension TransformationContext context, 
      String layoutFilename, 
      MutableClassDeclaration clazz) {
      val pathToCU = clazz.compilationUnit.filePath
      
      // TODO support res/layout-{suffix} 
      var Path xmlFile = pathToCU.projectFolder.append("res/layout/" + layoutFilename + ".xml")
      if (!xmlFile.exists) {
         // TODO remove hardcoded "src/main" path
         xmlFile = pathToCU.projectFolder.append("src/main/res/layout/" + layoutFilename + ".xml")
         if (!xmlFile.exists) {
            clazz.annotations.head.addError("Unable to find layout '"+xmlFile+"'.")
            return null;
         }
      }
      
      return xmlFile
   }

	def static void createViewGetters(
		extension TransformationContext context,
		String layoutFilename,
		MutableClassDeclaration clazz) {
      val xmlFile = AnnotationLayoutUtils.getLayoutPath(context, layoutFilename, clazz)
      if (xmlFile == null) return;

		xmlFile.contentsAsStream.getDocument.traverseAllNodes [

			// recursively read includes
			if (it.nodeName.equals('include') && it.hasAttribute('layout')) {
				//  <include layout="@layout/titlebar"/>
				val layoutFileName = it.getAttribute('layout')?.substring(8)
				context.createViewGetters(layoutFileName, clazz)
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
