package org.xtendroid.adapter

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

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
 * My aim is to pave the way from @JsonProperty and @AndroidParcelable to @AndroidAdapter, @CustomViewGroup, @CustomView, or native android view widgets.
 * 
 */
@Active(AdapterizeProcessor)
@Target(ElementType.TYPE)
annotation AndroidAdapter {
}

class AdapterizeProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {
		// auto-extend BaseAdapter if necessary
		if (clazz.extendedClass.equals(Object.newTypeReference())) {
			clazz.extendedClass = BaseAdapter.newTypeReference()
		}

		// determine data container
		val dataContainerFields = clazz.declaredFields.filter[f|
			(f.type.name.contains(ArrayList.newTypeReference.name) || f.type.name.contains(List.newTypeReference.name) || f.type.array) && !f.final]

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
		dataContainerField.markAsRead
		val dataContainerFieldTypeConst = dataContainerField.type
		clazz.addConstructor [
			visibility = Visibility::PUBLIC
//			TODO active when 2.7 is used
//			dataContainerField.markAsInitializedBy(it)
			body = [
				'''
					this.mContext = context;
					this.«dataContainerField.simpleName» = data;
				''']
			addParameter("context", Context.newTypeReference)
			addParameter("data", dataContainerFieldTypeConst)
		]
		
		// ctor with empty data container
		clazz.addConstructor [
			visibility = Visibility::PUBLIC
			// TODO e.g. HashMaps etc. should all be supported; maybe later
			// when there's an overwhelming demand.		
			if (dataContainerFieldTypeConst.name.contains("ArrayList"))
			{
				body = [
					'''
						this(context, new «toJavaCode(dataContainerFieldTypeConst)»());
					''']
			}else
			{
				body = [
					// if the type is List, you also must initialize your own
					'''
						this(context, null); // allocate your own array
					'''
				]
			}
			addParameter("context", Context.newTypeReference)
		]

		// if one dummy (custom) View (Group) type is provided, then use it
		val androidViewGroupType = ViewGroup.newTypeReference
		val androidViewType = View.newTypeReference
		val dummyViews = clazz.declaredFields.filter[f|
			androidViewGroupType.isAssignableFrom(f.type) || androidViewType.isAssignableFrom(f.type)]
		if (!dummyViews.nullOrEmpty) {
			dummyViews.forEach [ dummyView |
			   dummyView.markAsRead
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
«««							// There is a strong bias for List type containers
							«ELSEIF !dataContainerField.type.actualTypeArguments.empty»
								«dataContainerField.type.actualTypeArguments.head.name» item = getItem(position);
							«ENDIF»
							«dummyView.simpleName»(view, item);
							return view;
						''']
				]
				
				// Determine type of data
				var TypeReference dataContainerFieldType;
				if (dataContainerField.type.array) {
					dataContainerFieldType = dataContainerField.type.arrayComponentType
				} else if (!dataContainerField.type.actualTypeArguments.empty) {
					dataContainerFieldType = dataContainerField.type.actualTypeArguments.head
				}
				
				// find the user-defined setup methods
				val finaldataContainerFieldType = dataContainerFieldType
				val setupMethods = clazz.declaredMethods.filter[m|m.parameters.length == 2].filter[m|
					m.parameters.head.type.equals(dummyType) &&
						m.parameters.get(1).type.equals(finaldataContainerFieldType)]
						
				// one method to rule them all
				clazz.addMethod(dummyView.simpleName) [
					visibility = Visibility.PRIVATE
					returnType = void.newTypeReference
					addParameter("view", dummyType)
					addParameter("data", finaldataContainerFieldType)
					body = [
						'''
							«IF setupMethods.nullOrEmpty»
								// add a method with two parameters, like this:
								/* def void doSomethingWith(«dummyType.simpleName» view, «finaldataContainerFieldType.simpleName» andData) { ... } */
							«ELSE»
								«setupMethods.map[m|m.simpleName + '(view, data);'].join("\n")»
							«ENDIF»
						''']
				]
			]
		}

		clazz.addMethod("getCount") [
			addAnnotation(Override.newAnnotationReference)
			body = [
				'''
«««					// this one is for the case that the data container has not been initialized
					if («dataContainerField.simpleName» == null) return 0;
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
			body = [
				'''
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
			body = [
				'''
					return position;
				''']
			returnType = long.newTypeReference
			visibility = Visibility.PUBLIC
		]

	/*
		clazz.addMethod("hasStableIds") [
			addAnnotation(Override.newAnnotationReference)
			body = [
				'''
					return false;
				''']
			returnType = boolean.newTypeReference
			visibility = Visibility.PUBLIC
		]
*/
	}

}

