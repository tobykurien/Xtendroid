
package org.xtendroid.annotations

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.List
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static extension org.xtendroid.utils.NamingUtils.*
import android.widget.TextView
import android.widget.ImageView

/**
 * 
 * These active annotations combine ideas from the original @AndroidView, BeanAdapter type and Barend Garvelink's idea here:
 * http://blog.xebia.com/2013/07/30/a-better-custom-viewgroup/
 * 
 * sources:
 * * http://stackoverflow.com/questions/2316465/how-to-get-relativelayout-working-with-merge-and-include
 * * http://stackoverflow.com/questions/8834898/what-is-the-purpose-of-androids-merge-tag-in-xml-layouts
 * * https://github.com/xebia/xebicon-2013__cc-in-aa/blob/4-_better_custom_ViewGroup/src/com/xebia/xebicon2013/cciaa/ContactListAdapter.java
 * * https://github.com/xebia/xebicon-2013__cc-in-aa/blob/4-_better_custom_ViewGroup/src/com/xebia/xebicon2013/cciaa/ContactView.java
 * 
 * My aim is to pave the way from @JsonProperty and @AndroidParcelable to @Adapterize and @CustomViewGroup
 * 
 */

@Active(typeof(AdapterizeProcessor))
@Target(ElementType.TYPE)
annotation AndroidAdapter {
}

class AdapterizeProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {

		// TODO support other types of Adapters
		// determine if clazz extends BaseAdapter
		if (!clazz.extendedClass.equals(BaseAdapter.newTypeReference())) {
			clazz.addError(String.format("%s must extend %s.", clazz.simpleName, BaseAdapter.newTypeReference.name))
		}

		// determine data container
		val dataContainerFields = clazz.declaredFields.filter[f|
			(f.type.name.startsWith(List.newTypeReference.name) || f.type.array) && !f.final]

		// determine if it provides an aggregate data object
		if (dataContainerFields.empty) {
			clazz.addError(
				clazz.simpleName +
					" must contain at least one (non-final) array or java.util.List type object to store the data.\nThe first one will be used.")
		}

		// where to get the inflater
		clazz.addField("mContext") [
			visibility = Visibility.PRIVATE
			type = Context.newTypeReference
			final = true
		]

		val dataContainerField = dataContainerFields.head
		clazz.addConstructor [
			visibility = Visibility::PUBLIC
			body = [
				'''
					this.«dataContainerField.simpleName» = data;
					this.mContext = context;
				''']
			addParameter("data", dataContainerField.type)
			addParameter("context", Context.newTypeReference)
		]

		// if one dummy (custom) View (Group) type is provided, then use it
		val androidViewGroupType = ViewGroup.newTypeReference
		val dummyViews = clazz.declaredFields.filter[f| androidViewGroupType.isAssignableFrom(f.type)]
		if (!dummyViews.nullOrEmpty) {
			dummyViews.forEach[dummyView |
				val dummyType = dummyView.type
				clazz.addMethod("getView") [
					visibility = Visibility::PUBLIC
					returnType = dummyType
					addAnnotation(Override.newAnnotationReference)
					addParameter("position", int.newTypeReference)
					addParameter("convertView", View.newTypeReference)
					addParameter("parent", ViewGroup.newTypeReference)
					body = [
						'''
							«dummyType» view;
							if (convertView == null) {
							    view = new «dummyType»(mContext);
							} else {
							    view = («dummyType») convertView;
							}
							«IF dataContainerField.type.array»
								«dataContainerField.type.arrayComponentType» item = getItem(position);
							«ELSEIF !dataContainerField.type.actualTypeArguments.empty»
								«dataContainerField.type.actualTypeArguments.get(0).name» item = getItem(position);
							«ENDIF»
							view.«dummyView.simpleName»(item);
							return view;
						''']
					]
			]
		}
		
		clazz.addMethod("getCount") [
			addAnnotation(Override.newAnnotationReference)
			body = ['''
				«IF dataContainerField.type.array»
					return «dataContainerField.simpleName».length;
				«ELSE»
					return «dataContainerField.simpleName».size();
				«ENDIF»
			''']
			returnType = int.newTypeReference
			visibility = Visibility.PUBLIC
		]

		clazz.addMethod("getItem") [
			addParameter("position", int.newTypeReference)
			addAnnotation(Override.newAnnotationReference)
			body = ['''
				«IF dataContainerField.type.array»
					return «dataContainerField.simpleName»[position];
				«ELSE»
					return «dataContainerField.simpleName».get(position);
				«ENDIF»
			''']
			if (dataContainerField.type.array)
				returnType = dataContainerField.type.arrayComponentType
			else
				returnType = dataContainerField.type.actualTypeArguments.head
			visibility = Visibility.PUBLIC
		]
		
		clazz.addMethod("getItemId") [
			addAnnotation(Override.newAnnotationReference)
			addParameter("position", int.newTypeReference)
			body = ['''
				return position;
			''']
			returnType = long.newTypeReference
			visibility = Visibility.PUBLIC
		]
		
		clazz.addMethod("hasStableIds") [
			addAnnotation(Override.newAnnotationReference)
			body = ['''
				return false;
			''']
			returnType = boolean.newTypeReference
			visibility = Visibility.PUBLIC
		]
	}

}


@Active(typeof(CustomViewGroupProcessor))
@Target(ElementType.TYPE)
annotation CustomViewGroup {
	int layout = 0 // -1 could theoretically be an existing layout
}

class CustomViewGroupProcessor extends AbstractClassProcessor {
	
	// blatantly stolen from @AndroidActivity
	// Caveat: This -ing thing cost me an hour of my life, apparently you need @Target(ElementType.TYPE) to get to the expression
	def String getValue(MutableClassDeclaration clazz, extension TransformationContext context) {
      var value = clazz.annotations.findFirst[
         annotationTypeDeclaration.equals(CustomViewGroup.newTypeReference.type)
      ]?.getExpression("layout")
      
      if (value == null)
      {
      	clazz.addError("You must enter the layout resource id like this: " + CustomViewGroup.newTypeReference.name + ("(layout = R.layout.something)"))
      }

      return value?.toString
   }

	override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {
		
		// determine if clazz extends BaseAdapter
		val androidViewGroupType = ViewGroup.newTypeReference
		if (!androidViewGroupType.isAssignableFrom(clazz.extendedClass)) {
			clazz.addError(String.format("%s must extend an extending type of %s.", clazz.simpleName, androidViewGroupType.name))
		}
		
		// determine there is at least one View type (e.g. ImageView or TextView) field that is contained within the custom layout
		val androidViewFields = clazz.declaredFields.filter[f | View.newTypeReference.isAssignableFrom(f.type) ]
		if (androidViewFields.nullOrEmpty)
		{
			clazz.addError("You must have at least one field of the type TextView or ImageView type or some customized type of those.")
		}
		
				clazz.addConstructor[
			visibility = Visibility.PUBLIC
			addParameter("context", Context.newTypeReference)
			body = ['''
				super(context);
				init(context);
			''']
		]
		
		clazz.addConstructor[
			visibility = Visibility.PUBLIC
			addParameter("context", Context.newTypeReference)
			addParameter("attrs", AttributeSet.newTypeReference)
			body = ['''
				super(context, attrs);
				init(context);
			''']
		]
		
		clazz.addConstructor[
			visibility = Visibility.PUBLIC
			addParameter("context", Context.newTypeReference)
			addParameter("attrs", AttributeSet.newTypeReference)
			addParameter("defStyle", int.newTypeReference)
			body = ['''
				super(context, attrs, defStyle);
				init(context);
			''']
		]
		
		/**
		 * Generates an init method to grab all the TextViews and ImageViews and ViewGroup#findViewById them.
		 * 
		 * Also, checks whether there is a method for the ViewGroup itself, it determines this by checking the method signature.
		 * 
		 * I only go by the signature, I don't care how it's called, it might be a pre-defined "init" method.
		 */
		val viewGroupInitMethods = clazz.declaredMethods.filter[m | m.parameters.exists[p | p.type.equals(Context.newTypeReference)] && m.parameters.size == 1]
		val hasViewGroupInitMethods = !viewGroupInitMethods.nullOrEmpty

//		// in case you prefer to set it up yourself
		val hasInitMethod = clazz.declaredMethods.exists[m | m.simpleName.equalsIgnoreCase("init") && m.parameters.size == 1 &&  m.parameters?.head.type.equals(Context.newTypeReference)]
		val layoutResourceID = getValue(clazz, context)

		if (!hasInitMethod) // I know: the name is very ObjC-ish.
		{
			clazz.addMethod("init") [
				visibility = Visibility.PRIVATE
				returnType = void.newTypeReference
				addParameter("context", Context.newTypeReference)
				body = ['''
					«IF hasViewGroupInitMethods»
						«viewGroupInitMethods.map[m | m.simpleName + '(context);'].join("\n")»
					«ENDIF»
«««					// This check is pointless, but it might not be if addError is moved out of the function
					«IF !layoutResourceID.nullOrEmpty»
						«LayoutInflater.newTypeReference.name».from(context).inflate(«layoutResourceID», this, true);
					«ENDIF»
					«androidViewFields.map[f | String.format("this.%s = (%s) findViewById(R.id.%s);", f.simpleName, f.type.name, f.simpleName.toResourceName)].join("\n")»
				''']
			]
		}
		
		/**
		 * 
		 * The previous way to generate a "show" method for the adapter was too fragile.
		 * New approach with temporarily abstract method (and temporarily abstract class)
		 * 
		 */
		 val abstractMethod = clazz.declaredMethods.filter[m | m.abstract]?.head
		 if (abstractMethod != null)
		 {
		 	clazz.abstract = false // unabstract declaring class
		 	abstractMethod.visibility = Visibility.PUBLIC
		 	abstractMethod.abstract = false
		 	if (abstractMethod.parameters.length == 1)
		 	{
		 		val paramName = abstractMethod.parameters.head.simpleName
			 	abstractMethod.body = ['''
					«androidViewFields.filter[f | f.type.isAssignableFrom(TextView.newTypeReference) ].map[f | String.format("this.%s.setText(%s.get%s());", f.simpleName, paramName, f.simpleName.sanitizeName.toFirstUpper)].join("\n")»
					«androidViewFields.filter[f | f.type.isAssignableFrom(ImageView.newTypeReference) ].map[f | String.format("this.%s.setBackgroundResource(%s.get%s());", f.simpleName, paramName, f.simpleName.sanitizeName.toFirstUpper)].join("\n")»
			 	''']
		 	}
		 }
	}
	
	def String sanitizeName(String s)
	{
		return s.replaceFirst("^_+", "")
	}
}
