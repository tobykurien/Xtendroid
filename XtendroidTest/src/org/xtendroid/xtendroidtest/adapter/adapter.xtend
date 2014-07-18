package org.xtendroid.xtendroidtest.adapter

import android.widget.BaseAdapter
import org.xtendroid.annotations.AndroidAdapter
import java.util.List
import org.xtendroid.parcel.AndroidParcelable
import android.os.Parcelable
import android.widget.LinearLayout
import android.widget.RelativeLayout
import org.xtendroid.annotations.CustomViewGroup
import org.xtendroid.annotations.CustomView
import android.widget.TextView
import android.widget.ImageView
import org.xtendroid.annotations.AndroidView
import android.content.Context
import org.xtendroid.xtendroidtest.R;
import org.xtendroid.json.JsonProperty
import android.widget.Button

@AndroidParcelable
class Payload implements Parcelable
{
	@Property
	var String a
	@Property
	var String b
	@Property
	var int    c
	
	@JsonProperty // this requires a JSONException catch
	var String d 
}

@AndroidAdapter
class XtendAdapter1 extends BaseAdapter {
	@Property
	var List<Payload> data
	var CustomAdapterView1 show
	
}

@AndroidAdapter
class XtendAdapter2 extends BaseAdapter {
	var Payload[] data
	var CustomAdapterView2 show
//	var CustomAdapterView  meh // this might actually be a good idea for Expandable ListView Adapter
}

@CustomViewGroup(layout = R.layout.custom_adapter_view)
abstract class CustomAdapterView1 extends LinearLayout
{
	@AndroidView
	TextView  a
	@AndroidView
	TextView  b
	@AndroidView
	ImageView c
	
	def abstract void show(Payload input)

	def void initViewGroup(Context context) {
		orientation = LinearLayout.HORIZONTAL
	}
	
	def void someRandomMethodMatchingTheSignature(Context context)
	{}
	
//	def void init(Context context) {
//		initViewGroup(context)
//	}
}

@CustomViewGroup(layout = R.layout.custom_adapter_view2)
abstract class CustomAdapterView2 extends RelativeLayout
{
	@AndroidView
	TextView  a
	@AndroidView
	TextView  b
	@AndroidView
	ImageView c
	
	def abstract void show(Payload input)

	def void initViewGroup2(Context context) {
		c.imageAlpha = 1 
	}
	
//	def void init(Context context) {
//		initViewGroup(context)
//	}
}

@CustomView
abstract class CustomView1 extends Button
{
	def void helpInitTheView (Context context)
	{
		// this matches the signature
		activated = false
	}
}

@CustomView
abstract class CustomView2 extends TextView
{
	def void helpInitTheView (Context context)
	{
		// this matches the signature
		text = "wow"
	}
}