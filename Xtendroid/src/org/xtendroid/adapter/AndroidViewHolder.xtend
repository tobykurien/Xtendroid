package org.xtendroid.adapter

import android.content.Context
import android.view.View
import android.view.ViewGroup
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.xtendroid.utils.AnnotationLayoutUtils

import static extension org.xtendroid.utils.AnnotationLayoutUtils.*

@Active(typeof(AndroidViewHolderProcessor))
annotation AndroidViewHolder {
	int layout = -1
	int value = -1
}

class AndroidViewHolderProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {
		// See if a layout is defined, then create accessors for them, if they actually exist
		val String layoutResId = AnnotationLayoutUtils
		    .getLayoutValue(clazz, context, AndroidViewHolder.newTypeReference)
		if (layoutResId == null || "-1".equals(layoutResId) || !layoutResId.contains('R.layout')) {
			clazz.addWarning('You may add a layout resource id to the annotation, like this: @AndroidViewHolder(R.layout...).')
			return;
		}

      // add 'extends RecyclerView.ViewHolder' if necessary
      if (clazz.extendedClass == Object.newTypeReference()) {
         //clazz.extendedClass = newTypeReference(RecyclerView.ViewHolder);
      }

		val layoutFileName = layoutResId?.substring(layoutResId.lastIndexOf('.') + 1)
		if (layoutFileName == null) {
			return;
		}

      clazz.addField("view") [f|
         f.type = View.newTypeReference
      ]

      if (clazz.extendedClass.name.equals("android.support.v7.widget.RecyclerView$ViewHolder")) {
          // create constructor for RecyclerView.ViewHolder
          clazz.addConstructor [
              addParameter("view", View.newTypeReference)
              body = [
                  '''
                    super(view);
                    this.view = view;
                  ''']
          ]
      } else {
          // create constructor
          clazz.addConstructor [
              addParameter("view", View.newTypeReference)
              body = [
                  '''
                    this.view = view;
                  ''']
          ]
      }

      // add #findViewById just like in an Activity
      var exists = clazz.declaredMethods.exists[m|m.simpleName == "findViewById"]
      if (!exists)
         clazz.addMethod("findViewById") [
            visibility = Visibility::PUBLIC
            addParameter("resId", primitiveInt)
            returnType = typeof(View).newTypeReference
            body = [
               '''
                  return view.findViewById(resId);
               '''
            ]
         ]

      // add getter for the view object
      exists = clazz.declaredMethods.exists[m|m.simpleName == "getView"]
      if (!exists)
         clazz.addMethod("getView") [
            visibility = Visibility::PUBLIC
            returnType = typeof(View).newTypeReference
            body = [
               '''
                  return view;
               '''
            ]
         ]

      // add getOrCreate method to handle layout inflation and saving/restoring view holder
      exists = clazz.declaredMethods.exists[m|m.simpleName == "getOrCreate"]
      if (!exists)
         clazz.addMethod("getOrCreate") [
            visibility = Visibility::PUBLIC
            static = true
            addParameter("context", Context.newTypeReference)
            addParameter("convertView", View.newTypeReference)
            addParameter("parent", ViewGroup.newTypeReference)
            returnType = clazz.newTypeReference
            body = [
               '''
                  View cv = convertView;
                  if (convertView == null) {
                     cv = android.view.LayoutInflater.from(context).inflate(«layoutResId», parent, false);
                     cv.setTag(new «clazz.simpleName»(cv));
                  }
                  
                  return («clazz.simpleName») cv.getTag();
               '''
            ]
         ]

		context.createViewGetters(layoutFileName, clazz)
	}
}
