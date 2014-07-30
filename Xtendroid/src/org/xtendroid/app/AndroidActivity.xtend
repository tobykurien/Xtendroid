package org.xtendroid.app

import android.app.Activity
import android.os.Bundle
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

import static extension org.xtendroid.utils.AnnotationLayoutUtils.*

/**
 * An active annotation for Android activities.
 * 
 * It takes one argument layout, which is the resource identifier of the associated view file.
 * e.g. for layout/main_view.xml, the simple name would be "R.id.main_view".
 * 
 * It automatically declares typed local fields for all members declared within that XML layout, that is each member
 * with an @id/name attribute will be accessible from within the annotated classes without further ado.
 * 
 * It also derives a synthetic interfaces containing all 'onclick' methods declared in the XML file. Users will get feedback by the compiler
 * and help by the IDE to implement the needed methods.
 */
@Active(AndroidActivityProcessor)
@Target(ElementType.TYPE)
annotation AndroidActivity {
	int value = -1
   int layout = -1
}

class AndroidActivityProcessor extends AbstractClassProcessor {
   
   override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
      context.registerInterface(annotatedClass.qualifiedName+"_CallBacks")
   }
   
   override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
      val callBacksType = findInterface(annotatedClass.qualifiedName+"_CallBacks")
      val layoutResourceID = getValue(annotatedClass, context)
       
      val viewFileName = layoutResourceID?.substring(layoutResourceID.lastIndexOf('.') + 1)
      if (viewFileName == null) {
         return;
      }
      val pathToCU = annotatedClass.compilationUnit.filePath
      
      // TODO support res/layout-{suffix} 
      val xmlFile = pathToCU.projectFolder.append("res/layout/"+viewFileName+".xml")
      if (!xmlFile.exists) {
         annotatedClass.annotations.head.addError("There is no file in '"+xmlFile+"'.")
         return;
      }
      
      // add 'extends Activity' if necessary
      if (annotatedClass.extendedClass == Object.newTypeReference()) {
         annotatedClass.extendedClass = Activity.newTypeReference
      }
      
      // is extendedClass the same or the super type of "android.app.Activity"
	  if (Activity.newTypeReference.isAssignableFrom(annotatedClass.extendedClass))
	  {
        annotatedClass.implementedInterfaces = annotatedClass.implementedInterfaces + #[callBacksType.newTypeReference]
	  }else
	  {
	  	annotatedClass.addWarning("This class is not an Android Activity.")
	  	return;
	  }
      
      // create onCreate if not present
      if (annotatedClass.findDeclaredMethod("onCreate", Bundle.newTypeReference()) == null) {
         // prepare @OnCreate methods
         val onCreateAnnotation = OnCreate.newTypeReference.type
         val onCreateMethods = annotatedClass.declaredMethods.filter[annotations.exists[annotationTypeDeclaration==onCreateAnnotation]]
         for (m : onCreateMethods) {
            if (m.parameters.empty) {
               m.addParameter("savedInstanceState", Bundle.newTypeReference)
            } else {
               if (m.parameters.size > 1) {
                  m.parameters.get(1).addError("Methods annotated with @OnCreate might only have zero or one parameter.")
               } else {
                  if (m.parameters.head.type != Bundle.newTypeReference) {
                     m.parameters.head.addError("The single parameter type must be of type Bundle.")
                  }
               }
            }
         }
         annotatedClass.addMethod("onCreate") [
            addParameter("savedInstanceState", Bundle.newTypeReference)
            body = ['''
               super.onCreate(savedInstanceState);
               setContentView(«layoutResourceID»);
               «FOR method : onCreateMethods»
                  «method.simpleName»(savedInstanceState);
               «ENDFOR»
            ''']
         ]
      }
      
      context.createViewGettersWithCallBack(xmlFile, annotatedClass, callBacksType)
   }
   
   // TODO unify and refactor out with @CustomViewGroup, @AndroidFragment 
   def String getValue(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
      var value = annotatedClass.annotations.findFirst[
         annotationTypeDeclaration==AndroidActivity.newTypeReference.type
      ].getExpression("layout")
      
      if (value == null || value.toString.trim == "-1") {
      	value = annotatedClass.annotations.findFirst[
            annotationTypeDeclaration==AndroidActivity.newTypeReference.type
         ].getExpression("value")
         
         if (value == null) {
            return null
         }
      }
      return value.toString
   }
}
