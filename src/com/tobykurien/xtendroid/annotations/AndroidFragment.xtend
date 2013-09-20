package com.tobykurien.xtendroid.annotations

import android.view.View
import org.eclipse.xtend.lib.macro.AbstractFieldProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static extension com.tobykurien.xtendroid.utils.Utils.*
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.AbstractClassProcessor

@Active(typeof(FragmentProcessor))
annotation AndroidFragment {
}

class FragmentProcessor extends AbstractClassProcessor {

   override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {
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
   }

}
