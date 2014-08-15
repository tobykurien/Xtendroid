package org.xtendroid.xtendroidtest.activities

import android.content.Intent
import android.os.Parcelable
import java.util.Date
import org.xtendroid.app.AndroidActivity
import org.xtendroid.app.OnCreate
import org.xtendroid.parcel.AndroidParcelable
import org.xtendroid.xtendroidtest.R

import static extension org.xtendroid.utils.AlertUtils.*

@AndroidActivity(R.layout.activity_parcelable) class ParcelableActivity {
	//@BundleProperty 
	ParcelableData parcel
	
	@OnCreate
	def init() {
		// if activity called without bundle arguments, add bundle arguments and reload activity
		parcel = intent.getParcelableExtra("parcel")
		if (parcel == null) {
			var p = new ParcelableData
			p.age = 1
			p.createdAt = new Date().time
			p.likeAButterfly = 0.1234f
			p.likeABee = "Bzzzz"
			
			var intent2 = new Intent(this, ParcelableActivity)
			intent2.putExtra("parcel", p)
			startActivity(intent2)
			finish
		} else {
			// pass the parcel to the fragment as argument
			parcelText.text = "Got parcel: " + parcel.toString
		}
	}
}

@AndroidParcelable
class ParcelableData {
	public int age
	public long createdAt
	public float likeAButterfly
	public String likeABee
	
	override toString() {
		'''«age», «createdAt», «likeAButterfly», «likeABee»'''
	}
}
	