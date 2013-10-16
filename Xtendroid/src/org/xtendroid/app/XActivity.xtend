package org.xtendroid.app

import android.app.Activity
import android.os.Bundle
import android.view.View
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.w3c.dom.Element
import org.xtendroid.utils.NamingUtils

import static extension org.xtendroid.utils.XmlUtils.*

/**
 * An active annotation for Android activities.
 * 
 * It takes one argument value, which is the simple name of the associated view file.
 * e.g. for layout/main_view.xml, the simple name would be "main_view".
 * 
 * It automatically declares typed local fields for all members declared within that XML layout, that is each member
 * with an @id/name attribute will be accessible from within the annotated classes without further ado.
 * 
 * It also derives a synthetic interfaces containing all 'onclick' methods declared in the XML file. Users will get feedback by the compiler
 * and help by the IDE to implement the needed methods.
 */
@Active(XActivityProcessor)
annotation XActivity {
   String value
}

class XActivityProcessor extends AbstractClassProcessor {
   
   override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
      context.registerInterface(annotatedClass.qualifiedName+"_CallBacks")
   }
   
   override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
      val callBacksType = findInterface(annotatedClass.qualifiedName+"_CallBacks")
      val viewFileName = getValue(annotatedClass, context)
      if (viewFileName == null) {
         return;
      }
      val pathToCU = annotatedClass.compilationUnit.filePath
      val xmlFile = pathToCU.projectFolder.append("res/layout/"+viewFileName+".xml")
      if (!xmlFile.exists) {
         annotatedClass.annotations.head.addError("There is no file in '"+xmlFile+"'.")
         return;
      }
      
      // add 'extends Activity' if necessary
      if (annotatedClass.extendedClass == Object.newTypeReference()) {
         annotatedClass.extendedClass = Activity.newTypeReference
      }
      //TODO check for Activity super type
      annotatedClass.implementedInterfaces = annotatedClass.implementedInterfaces + #[callBacksType.newTypeReference]
      
      // create onCreate if not present
      if (annotatedClass.findDeclaredMethod("onCreate", Bundle.newTypeReference()) == null) {
         annotatedClass.addMethod("onCreate") [
            addParameter("savedInstanceState", Bundle.newTypeReference)
            body = ['''
               super.onCreate(savedInstanceState);
               setContentView(R.layout.«viewFileName»);
            ''']
         ]
      }
      
      
      // read the XML
      val viewType = View.newTypeReference
      xmlFile.contentsAsStream.getDocument.traverseAllNodes[
         // check for ids
         val id = getId(it)
         val name = getFieldName(it)
         val fieldType = getFieldType(it)?.newTypeReference
         if (name != null && fieldType != null) {
            annotatedClass.addMethod('get'+name.toFirstUpper) [
               returnType = fieldType
               body = ['''
                  return («toJavaCode(fieldType)») findViewById(R.id.«id»);
               ''']
            ]
         }
         
         // check for strings
         val onClick  = getAttribute("android:onClick")
         if (!onClick.nullOrEmpty && fieldType != null) {
            callBacksType.addMethod(NamingUtils.toJavaIdentifier(onClick)) [
               addParameter("element", viewType)
            ]
         }
      ]
   }
   
   def String getValue(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
      val value = annotatedClass.annotations.findFirst[
         annotationTypeDeclaration==XActivity.newTypeReference.type
      ].getValue("value") as String
      return value
   }
     
   def getFieldType(Element e) {
      val clazz = try {
         Class.forName("android.widget."+e.nodeName)
      } catch (ClassNotFoundException exception) {
         try {
            Class.forName("android.view."+e.nodeName)
         } catch (ClassNotFoundException exception1) {
            null
         }
      }
      if (View.isAssignableFrom(clazz)) {
         return clazz
      }
      return null
   }
   
   def getFieldName(Element e) {
      val id = getId(e)
      if (id != null) {
         return NamingUtils.toJavaIdentifier(id)
      }
      return null
   }
   
   def getId(Element e) {
      val id = e.getAttribute("android:id")
      if (id.startsWith("@+id/")) {
         return id.substring(5)
      }
      return null
   }
}
