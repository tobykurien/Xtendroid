package org.xtendroid.annotations

import android.app.Dialog
import android.app.DialogFragment
import android.os.Bundle
import android.view.View
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.xtendroid.app.OnCreate
import org.xtendroid.utils.AnnotationLayoutUtils

import static extension org.xtendroid.utils.AnnotationLayoutUtils.*

/**
 * @AndroidDialogFragment is an annotation to allow DialogFragment classes to be based on
 * AlertDialog.Builder and other such dialog builders. The default implementation will create 
 * a dialog with the specified layout and an Ok button. Override the onCreateDialog() to 
 * create your own dialog using AlertDialog.Builder or other.
 */
@Active(typeof(DialogFragmentProcessor))
annotation AndroidDialogFragment {
   int layout = -1
   int value = -1
}

class DialogFragmentProcessor extends AbstractClassProcessor {

   override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {
      // add ctor, orientation changes cause crashes without it
      if (!clazz.declaredConstructors.exists[ctor|ctor.parameters.empty]) {
         clazz.addConstructor [
            visibility = Visibility::PUBLIC
            body = [
               '''
                  // empty ctor prevents crashes
                  setArguments(new Bundle());
               ''']
         ]
      }

      // See if a layout is defined, then create accessors for them, if they actually exist
      val String layoutResId = AnnotationLayoutUtils.getLayoutValue(clazz, context, AndroidDialogFragment.newTypeReference)
      if (layoutResId == null || "-1".equals(layoutResId) || !layoutResId.contains('R.layout')) {
         clazz.addWarning(
            'You may add a layout resource id to the annotation, like this: @AndroidDialogFragment(layout=R.layout...).')
         return;
      }

      // add 'extends Fragment' if necessary
      if (clazz.extendedClass == Object.newTypeReference()) {
         clazz.extendedClass = DialogFragment.newTypeReference
      }

      val layoutFileName = layoutResId?.substring(layoutResId.lastIndexOf('.') + 1)
      if (layoutFileName == null) {
         return;
      }

      // prepare @OnCreate methods
      val onCreateAnnotation = OnCreate.newTypeReference.type
      val onCreateMethods = clazz.declaredMethods.filter[
         annotations.exists[annotationTypeDeclaration == onCreateAnnotation]]
      for (m : onCreateMethods) {
         if (m.parameters.empty) {
            m.addParameter("savedInstanceState", Bundle.newTypeReference)
         } else if (m.parameters.size > 1) {
            m.parameters.get(1).addError("Methods annotated with @OnCreate might only have zero or one parameter.")
         } else if (m.parameters.head.type != Bundle.newTypeReference) {
            m.parameters.head.addError("The single parameter type must be of type Bundle.")
         }
      }

      if (!onCreateMethods.nullOrEmpty) {

         // create onActivityCreated if not present
         if (!clazz.declaredMethods.exists[simpleName == "onActivityCreated"]) {
            clazz.addMethod("onActivityCreated") [
               addAnnotation(Override.newAnnotationReference)
               addParameter("savedInstanceState", Bundle.newTypeReference)
               body = [
                  '''
                     super.onActivityCreated(savedInstanceState);
                     «FOR method : onCreateMethods»
                        «method.simpleName»(savedInstanceState);
                     «ENDFOR»
                  ''']
            ]
         // last chance
         } else if (!clazz.declaredMethods.exists[simpleName == "onStart"]) {
            clazz.addMethod("onStart") [
               addAnnotation(Override.newAnnotationReference)
               body = [
                  '''
                     super.onStart();
                     «FOR method : onCreateMethods»
                        «method.simpleName»(savedInstanceState);
                     «ENDFOR»
                  ''']
            ]
         } else {
            clazz.addWarning('Call the @OnCreate method from inside onActivityCreated() or onStart()')
         }
      }

      // The getView() method must return null to prevent this view overwriting the actual dialog
      // This took me half a frustrating day to figure out *grrrr*
      clazz.addMethod("getView") [
         addAnnotation(Override.newAnnotationReference)
         returnType = View.newTypeReference
         body = [
            '''
               return null;
            ''']
      ]

      // The getContentView() method will inflate and return the specified layout
      clazz.addMethod("getContentView") [
         returnType = View.newTypeReference
         body = [
            '''
               if (rootView == null) { 
                  rootView = android.view.LayoutInflater.from(getActivity()).inflate(«layoutResId», null);
               }
               
               return rootView;
            ''']
      ]


      clazz.addField("rootView") [f|
         f.type = View.newTypeReference
      ]

      // create onCreateDialog method to create the dialog, if method is not defined
      if (!clazz.declaredMethods.exists[simpleName == "onCreateDialog"]) {
         clazz.addMethod("onCreateDialog") [
            addAnnotation(Override.newAnnotationReference)
            returnType = Dialog.newTypeReference
            addParameter("savedInstanceState", Bundle.newTypeReference)
            body = [
               '''
                  Dialog dlg = new android.app.AlertDialog.Builder(getActivity())
                     .setView(getContentView())
                     .setPositiveButton(android.R.string.ok, null)
                     .create();                  
                  dlg.show();
                  
                  return dlg;
               ''']
         ]
      }

      // add #findViewById just like the Activity
      if (!clazz.declaredMethods.exists[simpleName == "findViewById"])
         clazz.addMethod("findViewById") [
            visibility = Visibility::PUBLIC
            addParameter("resId", primitiveInt)
            returnType = typeof(View).newTypeReference
            body = [
               '''
                  return getContentView().findViewById(resId);
               '''
            ]
         ]

      context.createViewGetters(layoutFileName, clazz)
   }
}
