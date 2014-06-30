package org.xtendroid.xtendroidtest.parcel

import org.xtendroid.parcel.AndroidParcelable
import android.os.Parcelable
import java.util.Date
import org.xtendroid.json.JsonProperty
import org.json.JSONObject
import org.json.JSONArray
import java.util.List

/**
forbidden non-primitive types:
	Byte B
	Byte[] BB
	Double D
	Double[] DD
	Float F
	Float[] FF
	Integer I
	Integer[] II
	Long L
	Long[] LL
	Boolean BO
	Boolean[] BOBO
*/

@AndroidParcelable
class E implements android.os.Parcelable {
	JSONObject _jsonObj

	@Property
	byte b
	byte[] bb
	
	double d
	double[] dd
	
	float f
	float[] ff
	
	int i
	int[] ii
	
	long l
	long[] ll
	
	String s
	String[] ss
	
	boolean bo
	boolean[] bobo

	@Property
	E eee
	
	@JsonProperty
	Date ddd
	
	@JsonProperty
	boolean boolz
}

@AndroidParcelable
class F implements Parcelable
{
	JSONObject _jsonObj // required for both to interoperate or data will be lost during the marshalling process

	@Property
	byte b
	
	@Property
	Date dt

	@Property
	Date[] dtdt
	
	@Property
	E ppta

	@JsonProperty
	double d_

	@JsonProperty
	String s
	
	@JsonProperty("mint")
	int useAnAliasInstead

	@JsonProperty
	double[] dd__
}

//@AndroidParcelable
class ZZZ /** implements Parcelable */
{
	// Broken by design (tm)
/*
	@JsonProperty // disallowed by @AndroidParcelable, allowed by @JsonProperty
	Double DD_

	@JsonProperty // disallowed by both
	Double[] D__
*/
	@Property
	int placeHolder
}

class A
{
	@JsonProperty
	String ss
	
	@JsonProperty
	int ii

	@JsonProperty
	java.lang.Integer II
	
//	@JsonProperty
//	Float FF
	
	@JsonProperty
	long ll

	@JsonProperty
	Long LL

	@Property
	String normalPropertyField
}

//@Data // is would be compatible with @AndroidParcelable, if it did not make the fields final
@AndroidParcelable
class P implements Parcelable
{
	String data
}

//@Data // is not compatible
class B
{
	/**
	 * Primitive to JSON
	 */
	@JsonProperty("aLottaFaginas")
	List<String> strs;
	
	/**
	 * Rare is a JSON object
	 */
	@JsonProperty("someCustomType")
	List<RRR> rares;
	
	/**
	 * Primitive to JSON
	 */
	@JsonProperty("o")
	String[] o;
	
	/**
	 * Rare is a JSON object
	 */
	@JsonProperty("y")
	RRR[] y;
}

@AndroidParcelable
class C implements Parcelable
{
	JSONObject _jsonObject
	
	@JsonProperty
	String meh
	
	@Property
	String normal
	
	@JsonProperty
	List<String> listy
	
	@JsonProperty
	List<C> ourobouros
}

class RRR // in the android dev context, it's dangerous to name a type 'R'
{
	@JsonProperty
	String stringy
	
	@JsonProperty
	List<String> listy
	
	@JsonProperty
	List<C> cs
	
	@JsonProperty
	JSONArray rrr
	
	@JsonProperty
	JSONObject obj
	
	public def add_i_and_j()
	{
		return _i + _j
	}
	
	@JsonProperty
	int i
	
	@JsonProperty
	int j
	
}

@AndroidParcelable
class Datezzz implements Parcelable
{
	JSONObject _jsonObj
	
	@JsonProperty("ddd-mmm-YYYY")
	Date meh
	
	@JsonProperty("yyyy-MM-dd'T'HH:mm:ssZ")
	Date[] mehArray
	
	@JsonProperty("yyyy-MM-dd'T'HH:mm:sssZ")
	List<Date> mehList
	
	@JsonProperty
	int mehint
}