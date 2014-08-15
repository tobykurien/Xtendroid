package org.xtendroid.xtendroidtest.bundle

import android.app.Activity
import android.app.Fragment
import android.app.IntentService
import android.content.Intent
import android.os.Bundle
import android.os.Parcelable
import android.util.SparseArray
import java.io.Serializable
import java.util.ArrayList
import org.xtendroid.annotations.AndroidFragment
import org.xtendroid.annotations.BundleProperty
import org.xtendroid.app.AndroidActivity
import org.xtendroid.xtendroidtest.R

class BundleService extends IntentService
{
	var Intent myIntent
	
	@BundleProperty('some.long.ass.name.that.cannot.be.taken.seriously')
	String allOfThatForADamnString = 'default'
	
	@BundleProperty
	String stringWithDefault = "long string, not really"
	
	new(String name) {
		super(name)
	}
	
	override protected onHandleIntent(Intent intent) {
		myIntent = intent
	}
	
}

class BundleBean
{
	Intent intent
	
//	@BundleProperty // TODO test on api level 18
//	var IBinder binder
	
	@BundleProperty
	String stringWithDefault = "long string, not really"
	
	@BundleProperty
	boolean b = true

	@BundleProperty
	boolean[] bs = newBooleanArrayOfSize(5)
	
	@BundleProperty
	byte bite = 0 as byte
	
	@BundleProperty
	byte[] bites
	
	@BundleProperty
	char c = "\\0".charAt(0)
	
	@BundleProperty
	char[] cs
	
	@BundleProperty
	CharSequence almostString
	
	@BundleProperty
	CharSequence[] lotsaAlmostStrings
	
	@BundleProperty
	ArrayList<CharSequence> evenMore
	
	@BundleProperty
	double d = 0.0
	
	@BundleProperty
	double[] ds
	
	@BundleProperty
	float f = 0.0f
	
	@BundleProperty
	float[] fs
	
	@BundleProperty
	int i = 0
	
	@BundleProperty
	int[] is
	
	@BundleProperty
	ArrayList<Integer> iss
	
	@BundleProperty
	long l = 0
	
	@BundleProperty
	long[] ls
	
	@BundleProperty
	Parcelable paa
	
	@BundleProperty
	Parcelable[] paaaa
	
	@BundleProperty
	ArrayList<Parcelable> ppp
	
	@BundleProperty
	Serializable szszsz
	
	@BundleProperty
	short sh = 0 as short
	
	@BundleProperty
	short[] shshshshshs

//	@BundleProperty // breaks in java, the Intent does not support this
//	SparseArray<? extends Parcelable> sparpa
	
	@BundleProperty
	String str

	@BundleProperty
	String[] strs
	
	@BundleProperty
	ArrayList<String> mrstrs
	
}

@AndroidActivity(layout=R.layout.activity_bundle)
class BundleActivity extends Activity {

	@BundleProperty
	var Bundle bundle
	
	@BundleProperty
	String stringWithDefault = "long string, not really"
	
//	@BundleProperty // TODO test on api level 18
//	var IBinder binder
	
	@BundleProperty
	boolean b = true

	@BundleProperty
	boolean[] bs = newBooleanArrayOfSize(5)
	
	@BundleProperty
	byte bite = 0 as byte
	
	@BundleProperty
	byte[] bites
	
	@BundleProperty
	char c = 0 as char
	
	@BundleProperty
	char[] cs
	
	@BundleProperty
	CharSequence almostString
	
	@BundleProperty
	CharSequence[] lotsaAlmostStrings
	
	@BundleProperty
	ArrayList<CharSequence> evenMore
	
	@BundleProperty
	double d = 0.0
	
	@BundleProperty
	double[] ds
	
	@BundleProperty
	float f = 0.0f
	
	@BundleProperty
	float[] fs
	
	@BundleProperty
	int i = 0
	
	@BundleProperty
	int[] is
	
	@BundleProperty
	ArrayList<Integer> iss
	
	@BundleProperty
	long l = 0
	
	@BundleProperty
	long[] ls
	
	@BundleProperty
	Parcelable paa
	
	@BundleProperty
	Parcelable[] paaaa
	
	@BundleProperty
	ArrayList<Parcelable> ppp
	
	@BundleProperty
	Serializable szszsz
	
	@BundleProperty
	short sh = 0 as short
	
	@BundleProperty
	short[] shshshshshs

	@BundleProperty
	short s = 0 as byte
	
//	@BundleProperty // breaks in java, the Intent does not support this
//	SparseArray<? extends Parcelable> sparpa
	
	@BundleProperty
	String str

	@BundleProperty
	String[] strs
	
	@BundleProperty
	ArrayList<String> mrstrs
}

@AndroidFragment(layout=R.layout.activity_bundle)
class BundleFragment1 extends Fragment {
	
	@BundleProperty
	var Bundle bundle
	
	@BundleProperty
	String stringWithDefault = "long string, not really"
	
	//	@BundleProperty
	//	var IBinder binder
	
	@BundleProperty
	boolean b = false
	
	@BundleProperty
	boolean[] bs
	
	@BundleProperty
	byte bite = 0 as byte
	
	@BundleProperty
	byte[] bites
	
	@BundleProperty
	char c = 0 as char
	
	@BundleProperty
	char[] cs
	
	@BundleProperty
	CharSequence almostString
	
	@BundleProperty
	CharSequence[] lotsaAlmostStrings
	
	@BundleProperty
	ArrayList<CharSequence> evenMore
	
	@BundleProperty
	double d = 0.0
	
	@BundleProperty
	double[] ds
	
	@BundleProperty
	float f = 0.0f
	
	@BundleProperty
	float[] fs
	
	@BundleProperty
	int i = 0
	
	@BundleProperty
	int[] is
	
	@BundleProperty
	ArrayList<Integer> iss
	
	@BundleProperty
	long l = 0 as long
	
	@BundleProperty
	long[] ls
	
	@BundleProperty
	Parcelable paa
	
	@BundleProperty
	Parcelable[] paaaa
	
	@BundleProperty
	ArrayList<Parcelable> ppp
	
	@BundleProperty
	Serializable szszsz
	
	@BundleProperty
	short sh = 0 as short
	
	@BundleProperty
	short[] shshshshshs

	@BundleProperty
	short s = 0 as short
	
	@BundleProperty
	SparseArray<? extends Parcelable> sparpa
	
	@BundleProperty
	String str

	@BundleProperty
	String[] strs
	
	@BundleProperty
	ArrayList<String> mrstrs
	
}

@AndroidFragment(layout=R.layout.activity_bundle)
class BundleFragment2 extends android.support.v4.app.Fragment {
	
	@BundleProperty
	var Bundle bundle
	
	//	@BundleProperty
	//	var IBinder binder
	
	@BundleProperty
	String stringWithDefault = "long string, not really"
	
	@BundleProperty
	boolean b = false
	
	@BundleProperty
	boolean[] bs
	
	@BundleProperty
	byte bite = 0 as byte
	
	@BundleProperty
	byte[] bites
	
	@BundleProperty
	char c = 0 as char
	
	@BundleProperty
	char[] cs
	
	@BundleProperty
	CharSequence almostString
	
	@BundleProperty
	CharSequence[] lotsaAlmostStrings
	
	@BundleProperty
	ArrayList<CharSequence> evenMore
	
	@BundleProperty
	double d = 0.0
	
	@BundleProperty
	double[] ds
	
	@BundleProperty
	float f = 0.0f
	
	@BundleProperty
	float[] fs
	
	@BundleProperty
	int i = 0
	
	@BundleProperty
	int[] is
	
	@BundleProperty
	ArrayList<Integer> iss
	
	@BundleProperty
	long l = 0 as long
	
	@BundleProperty
	long[] ls
	
	@BundleProperty
	Parcelable paa
	
	@BundleProperty
	Parcelable[] paaaa
	
	@BundleProperty
	ArrayList<Parcelable> ppp
	
	@BundleProperty
	Serializable szszsz
	
	@BundleProperty
	short sh = 0 as short
	
	@BundleProperty
	short[] shshshshshs

	@BundleProperty
	short s = 0 as short
	
	@BundleProperty
	SparseArray<? extends Parcelable> sparpa
	
	@BundleProperty
	String str

	@BundleProperty
	String[] strs
	
	@BundleProperty
	ArrayList<String> mrstrs
}