package org.xtendroid.content.res

import android.content.res.Resources
import java.text.DateFormat
import java.text.MessageFormat
import java.text.NumberFormat
import java.util.Date
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.xtendroid.utils.NamingUtils

import static extension org.xtendroid.utils.XmlUtils.*

/**
 * An annotation that generates accessor methods to Android string resources.
 * 
 * <p>It uses java's @link{java.text.MessageFormat} in the values and the accessor methods will sport typed parameters according to the placeholders.
 * For example, given a strings.xml like this : </p>
 * <code>
 *    &lt;string name="my_key"&gt;Hello {0}, today is {1,date}&lt;/string&gt;
 * </code>
 * <p>Will result in a method signature:</p>
 * <code>
 *   def String getMyKey(String arg1, Date arg2) {...} 
 * </code>
 */
@Active(AndroidResourcesProcessor)
annotation AndroidResources {}

class AndroidResourcesProcessor extends AbstractClassProcessor {

   override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
      val resourcesType = Resources.newTypeReference
      if (annotatedClass.findDeclaredMethod("getResources", resourcesType) == null) {
         annotatedClass.addMethod('getResources') [
            returnType = resourcesType
            visibility = Visibility.PROTECTED
            abstract = true
         ]
         annotatedClass.abstract = true
      }

      val stringsPath = annotatedClass.compilationUnit.filePath.projectFolder.append("res/values/strings.xml")
      if (stringsPath.exists) {
         stringsPath.contentsAsStream.document.traverseAllNodes [
            if (nodeName == 'string') {
               val name = getAttribute('name')
               val value = firstChild.nodeValue
               val msgFormat = try {
                  new MessageFormat(value)
               } catch (IllegalArgumentException e) {
                  annotatedClass.annotations.head.addError(
                     "Invalid message format in '" + stringsPath + "'. Value for '" + name + "' is invalid.: " +
                        e.message)
                  new MessageFormat("")
               }
               val formats = msgFormat.formatsByArgumentIndex

               annotatedClass.addMethod("get" + NamingUtils.toJavaIdentifier(name).toFirstUpper) [
                  returnType = string
                  formats.forEach [ format, idx |
                     addParameter("arg" + idx,
                        switch format {
                           NumberFormat: primitiveInt
                           DateFormat: Date.newTypeReference()
                           default: string
                        })
                  ]
                  docComment = value+"-"+formats.size+"-"+formats
                  if (formats.empty) {
                     body = [
                        '''
                           return this.getResources().getString(R.string.«name»);
                        ''']
                  } else {
                     val params = parameters
                     body = [
                        '''
                           return String.format(this.getResources().getString(R.string.«name»),«params.map[simpleName].join(',')»);
                        ''']
                  }
               ]
            }
         ]
      }

   }

}
