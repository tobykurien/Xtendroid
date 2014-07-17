package org.xtendroid.annotations

import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import android.widget.EditText
import android.widget.ImageView
import android.widget.TextView
import java.lang.reflect.Method
import java.util.HashMap
import java.util.List
import org.xtendroid.utils.Utils

import android.view.View
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import android.widget.LinearLayout
import org.eclipse.xtend.lib.macro.AbstractFieldProcessor
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration

/**
 * 
 * These active annotations combine ideas from the original BeanAdapter and Barend Garvelink's idea here
 * http://blog.xebia.com/2013/07/30/a-better-custom-viewgroup/
 * 
 * sources:
 * * http://stackoverflow.com/questions/2316465/how-to-get-relativelayout-working-with-merge-and-include
 * * http://stackoverflow.com/questions/8834898/what-is-the-purpose-of-androids-merge-tag-in-xml-layouts
 * * https://github.com/xebia/xebicon-2013__cc-in-aa/blob/4-_better_custom_ViewGroup/src/com/xebia/xebicon2013/cciaa/ContactListAdapter.java
 * * https://github.com/xebia/xebicon-2013__cc-in-aa/blob/4-_better_custom_ViewGroup/src/com/xebia/xebicon2013/cciaa/ContactView.java
 * 
 */
/**
 * Generic adapter to take data in the form of Java beans and use the getters
 * to get the data and apply to appropriately named views in the row layout, e.g.
 * getFirstName -> R.id.first_name
 * isToast -> R.id.toast
 */
/*
class BeanAdapter<T> extends BaseAdapter {
   val List<T> data
   val Context context
   val int layoutId
   val HashMap<Integer,Method> mapping = newHashMap()
   
   new(Context context, int layoutId, List<T> data) {
      this.data = data
      this.layoutId = layoutId
      this.context = context
   }

   new(Context context, int layoutId, T[] data) {
      this.data = data.map[i| i]
      this.layoutId = layoutId
      this.context = context
   }
   
   override getCount() {
      data.size
   }
   
   override T getItem(int row) {
      data.get(row)
   }
   
   override getItemId(int row) {
      try {
         var item = getItem(row)
         var m = item.class.getMethod("getId")
         Long.valueOf(String.valueOf(m.invoke(item)))
      } catch (Exception e) {
         row as long
      }
   }
   
   override getView(int row, View cv, ViewGroup root) {
      val i = getItem(row)
      var v = cv
      if (v == null) {
         v = LayoutInflater.from(context).inflate(layoutId, root, false)
         if (mapping.empty) setupMapping(v, i)
      }
      
      val view = v
      mapping.forEach [resId,method|
         var res = view.findViewById(resId)
         if (res != null) {
            switch (res.class) {
               case TextView: (res as TextView).setText(String.valueOf(method.invoke(i)))
               case EditText: (res as EditText).setText(String.valueOf(method.invoke(i)))
               case ImageView: (res as ImageView).setImageBitmap(method.invoke(i) as Bitmap)
               default: Log.e("base_adapter", "View type not yet supported: " + res.class)
            }
         }
      ]
      
      return v
   }
   
   */
/**
    * Set up the bean-to-view mapping for use in subsequent rows
    */
/*
   def setupMapping(View v, T i) {
      i.class.methods.forEach [m|
         if (m.name.startsWith("get") || m.name.startsWith("is")) {
            // might be a getter, let's see if there is a corresponding view
            var resName = Utils.toResourceName(m)
            var resId = context.resources.getIdentifier(resName, "id", context.packageName)
            if (resId > 0) {
               mapping.put(resId, m)
            } 
         }
      ]
   }

}
*/

@Active(typeof(AdapterizeProcessor))
annotation Adapterize {
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
			(f.type.name.startsWith(java.util.List.newTypeReference.name) || f.type.array) && !f.final]

		// determine if it provides an aggregate data object
		if (dataContainerFields.empty) {
			clazz.addError(
				clazz.simpleName +
					" must contain at least one (non-final) array or java.util.List type object to store the data.\nThe first one will be used.")
		}

		// where to get the inflater
		clazz.addField("mContext") [
			visibility = Visibility.PRIVATE
			type = android.content.Context.newTypeReference
			final = true
		]

		val dataContainerField = dataContainerFields.get(0)
		clazz.addConstructor [
			visibility = Visibility::PUBLIC
			body = [
				'''
					this.«dataContainerField.simpleName» = data;
					this.mContext = context;
				''']
			addParameter("data", dataContainerField.type)
			addParameter("context", android.content.Context.newTypeReference)
		]

		// if one dummy (custom) View (Group) type is provided, then use it
		val androidViewGroupType = ViewGroup.newTypeReference
		val androidViewType = View.newTypeReference
		val dummyViews = clazz.declaredFields.filter[f| androidViewGroupType.isAssignableFrom(f.type) || androidViewType.isAssignableFrom(f.type) ]
		if (dummyViews.size == 1) {
			val dummyType = dummyViews.get(0).type
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
«««						// TODO the custom view might contain the method #show, because my other annotation generates one, also check if it has my annotation
						«IF !dummyType.name.startsWith("android")»
							view.show(item);
						«ENDIF»
						return view;
					''']
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

/*
 
 import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

public class ContactView extends LinearLayout {

    public static final Contact EMPTY = new Contact(null, null, null, null);
    private TextView nameView;
    private TextView emailView;
    private TextView addressView;
    private Contact contact = EMPTY;

    public ContactView(Context context) {
        super(context);
        init(context);
    }

    public ContactView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public ContactView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        init(context);
    }

    private void init(Context context) {
        setOrientation(VERTICAL);
        LayoutInflater.from(context).inflate(R.layout.contact_view, this, true);
        nameView = (TextView) findViewById(R.id.contact_name);
        emailView = (TextView) findViewById(R.id.contact_email);
        addressView = (TextView) findViewById(R.id.contact_address);
    }

    public void showContact(Contact contact) {
        this.contact = (contact != null ? contact : EMPTY);
        String name = contact.getName();
        String email = contact.getEmail();
        String address = contact.getAddressLines();
        if (name != null) {
            nameView.setText(name);
        } else if (email != null) {
            nameView.setText(email);
        } else {
            nameView.setText(R.string.unidentified);
        }
        if (email != null) {
            emailView.setText(email);
            emailView.setVisibility(name == null ? View.GONE : View.VISIBLE);
        } else {
            emailView.setVisibility(View.GONE);
        }
        if (address != null) {
            addressView.setText(address);
            addressView.setVisibility(View.VISIBLE);
        } else {
            addressView.setVisibility(View.GONE);
        }
    }
}
 
 */