package org.xtendroid.xtendroidtest.adapter

import android.widget.BaseAdapter
import org.xtendroid.annotations.Adapterize
import java.util.List
import org.xtendroid.parcel.AndroidParcelable
import android.os.Parcelable
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.RelativeLayout

@AndroidParcelable
class Payload implements Parcelable
{
	var String a
	var String b
	var String c
	var String d
}

@Adapterize
class XtendAdapter extends BaseAdapter {
	@Property
	var List<Payload> data
	var LinearLayout dummy
}

@Adapterize
class XtendAdapter2 extends BaseAdapter {
	var Payload[] data
	var RelativeLayout dummy
}