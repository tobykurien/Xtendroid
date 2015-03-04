package org.xtendroid.annotations

import android.app.Dialog
import android.app.DialogFragment
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.xtendroid.app.OnCreate
import org.xtendroid.utils.AnnotationLayoutUtils

import static extension org.xtendroid.utils.AnnotationLayoutUtils.*

@Active(typeof(DialogFragmentProcessor))
annotation AndroidDialogFragment {
   int layout = -1
   int value = -1
}

class DialogFragmentProcessor extends AbstractClassProcessor {

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
                  return getDialog().findViewById(resId);
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
         if (!clazz.declaredMethods.exists[m|m.simpleName == "onActivityCreated"]) {
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
         } else if (!clazz.declaredMethods.exists[m|m.simpleName == "onStart"]) {
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

      // create onCreateView method to load the layout, if method is not defined
      exists = clazz.declaredMethods.exists[m|m.simpleName == "onCreateView"]
      if (!exists) {
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
      }


      // create onCreateView method to load the layout, if method is not defined
      exists = clazz.declaredMethods.exists[m|m.simpleName == "onCreateDialog"]
      if (!exists) {
         clazz.addMethod("onCreateDialog") [
            addAnnotation(Override.newAnnotationReference)
            returnType = Dialog.newTypeReference
            addParameter("savedInstanceState", Bundle.newTypeReference)
            body = [
               '''
                  Dialog dlg = new android.app.AlertDialog.Builder(getActivity())
                     .setView(getView())
                     .create();                  
                  dlg.show();
                  
                  return dlg;
               ''']
         ]
      }

      context.createViewGetters(layoutFileName, clazz)
   }
}
