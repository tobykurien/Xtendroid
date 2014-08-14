package org.xtendroid.xtendroidtest.adapter

import android.content.Context
import android.os.Parcelable
import android.widget.BaseAdapter
import android.widget.Button
import android.widget.LinearLayout
import android.widget.RelativeLayout
import android.widget.TextView
import java.util.List
import org.xtendroid.adapter.AndroidAdapter
import org.xtendroid.annotations.CustomView
import org.xtendroid.annotations.CustomViewGroup
import org.xtendroid.json.JsonProperty
import org.xtendroid.parcel.AndroidParcelable
import org.xtendroid.xtendroidtest.R

/**
 * This Bean is responsible for all the data in the following
 * Views, ViewGroups and BaseAdapters. 
 */
@AndroidParcelable
class Payload implements Parcelable
{
	@Property
	var String a
	@Property
	var String b
	@Property
	var int    c
	
	@JsonProperty
	var String d 
	
	@JsonProperty
	var String ppp
	@JsonProperty
	var String qqq
	@JsonProperty
	var int rrr
	@JsonProperty
	var String sss
}

/**
 * It only takes two fields to extend a BaseAdapter
 */
@AndroidAdapter
class XtendAdapter0 extends BaseAdapter {
	@Property
	var List<Payload> data
	var CustomAdapterView1 showWithJsonData
}

/**
 * You may also use an array to enter data,
 * although I would advise against this for
 * dynamic data input.
 */
@AndroidAdapter
class XtendAdapter1 extends BaseAdapter {
	@Property
	var Payload[] data
	var CustomAdapterView1 show
}

/**
 * Currently, I'm experimenting with multiple custom views,
 * Right now all you get is a method name collision... 
 */
@AndroidAdapter
class XtendAdapter2 extends BaseAdapter {
	var Payload[] data
	var CustomAdapterView2 show
//	var CustomAdapterView  meh // this might actually be a good idea for Expandable ListView Adapter
}

/**
 * Instead of using custom layouts,
 * you may also use unadulterated
 * native android ViewGroup types.
 */
@AndroidAdapter
class XtendAdapter3 extends BaseAdapter {
	var Payload[] data
	var LinearLayout show
}

/**
 * Heck, you can even use native View types.
 * This one gives a warning in a comment that
 * a method is required to manipulate the Button.
 */
@AndroidAdapter
class XtendAdapter4 extends BaseAdapter {
	var Payload[] data
	var Button show
}

/**
 * 
 * This time another basic TextView type,
 * and in this case we implement a method: meh2
 * to change the TextView.
 * 
 * The method "meh" is only there to demonstrate
 * that the parameter order is important. 
 * 
 */
@AndroidAdapter
class XtendAdapter5 extends BaseAdapter {
	var Payload[] data
	var TextView show80085
	
	def void meh(Payload something, TextView meh)
	{
		// nothing happens, the order of the params is important
	}
	
	def void meh2(TextView meh, Payload something)
	{
		meh.text = something.a
	}
	
	def void changeTextFromJsonString(TextView hmf, Payload gogogo)
	{
		hmf.text = gogogo.d
	}
}

/**
 * Custom views (In this case an extended TextView)
 * can also play well with the Adapter.
 */
@AndroidAdapter
class XtendAdapter6 extends BaseAdapter {
	var Payload[] data
	var CustomView1 show80085
	
	def void meh2(CustomView1 meh, Payload something)
	{
		meh.text = something.a
	}
}

/**
 * This is a custom ViewGroup type that contains
 * certain View type fields.
 * 
 * This corresponds to the Views contained in the
 * <merge />-layout.
 * 
 * The annotation @AndroidView can provide accessors
 * to these views (by accident, haha).
 * 
 * The abstract method is implemented automagically
 * according to the name of the fields.
 * The "Bean" type provides the data as usual.
 * 
 * For this trick to work, we have to contend with a
 * temporarily abstract class...
 */
@CustomViewGroup(layout = R.layout.custom_adapter_view)
abstract class CustomAdapterView1 extends LinearLayout
{
	def abstract void show(Payload input)

	def void initViewGroup(Context context) {
		orientation = LinearLayout.HORIZONTAL
	}
	
	def void someRandomMethodMatchingTheSignature(Context context)
	{}
	
	/**
	 * 
	 * This one was not generated
	 * 
	 */
	public def void showWithJsonData(Payload p)
	{
		a.text = p.d
	}
	
//	def void init(Context context) {
//		initViewGroup(context)
//	}
}

@CustomViewGroup(layout = R.layout.custom_adapter_view2)
abstract class CustomAdapterView2 extends RelativeLayout
{
	def abstract void show(Payload input)

	def void initViewGroup2(Context context) {
		c.imageAlpha = 1
	}
}

@CustomViewGroup(layout = R.layout.custom_adapter_view2)
abstract class CustomAdapterView3 extends RelativeLayout
{
	def abstract void show(Payload input)

	def void initViewGroup2(Context context) {
		c.imageAlpha = 1
	}
}

@CustomView
class CustomView1 extends Button
{
	def void helpInitTheView (Context context)
	{
		// this matches the signature
		activated = false
	}
	
	/**
	 * This one is not generated
	 */
	public def void show80085(Payload p)
	{
		text = p.a
	}
}

@CustomView
class CustomView2 extends TextView
{
	def void helpInitTheView (Context context)
	{
		// this matches the signature
		text = "wow"
	}
}

@CustomView
class CustomView3 extends TextView
{
	def void setTextSize (Context context)
	{
		textSize = 500
	}
}

