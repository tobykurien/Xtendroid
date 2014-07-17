package org.xtendroid.xtendroidtest.adapter

import android.widget.BaseAdapter
import org.xtendroid.annotations.AndroidAdapter
import java.util.List
import org.xtendroid.parcel.AndroidParcelable
import android.os.Parcelable
import android.widget.LinearLayout
import android.widget.RelativeLayout
import org.xtendroid.annotations.CustomViewGroup
import android.widget.TextView
import android.widget.ImageView
import org.xtendroid.annotations.AndroidView
import android.content.Context
import org.xtendroid.xtendroidtest.R;
import org.xtendroid.json.JsonProperty

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
class XtendAdapter extends BaseAdapter {
	@Property
	var List<Payload> data
	var LinearLayout dummy
}

@AndroidAdapter
class XtendAdapter2 extends BaseAdapter {
	var Payload[] data
	var RelativeLayout dummy
}

@CustomViewGroup(layout = R.layout.custom_adapter_view)
class CustomAdapterView extends LinearLayout
{
	@AndroidView
	TextView  a
	@AndroidView
	TextView  b
	@AndroidView
	ImageView c
	
	var Payload p

	def void initViewGroup(Context context) {
		orientation = LinearLayout.HORIZONTAL
	}
	
//	def void init(Context context) {
//		initViewGroup(context)
//	}
}

@CustomViewGroup(layout = R.layout.custom_adapter_view2)
class CustomAdapterView2 extends RelativeLayout
{
	@AndroidView
	TextView  a
	@AndroidView
	TextView  b
	@AndroidView
	ImageView c
	
	var Payload p

	def void initViewGroup2(Context context) {
		// meh
	}
	
//	def void init(Context context) {
//		initViewGroup(context)
//	}
}