package org.xtendroid.xtendroidtest.parcel

import org.xtendroid.parcel.AndroidParcelable
import android.os.Parcelable
import java.util.Date
import org.xtendroid.json.JsonProperty
import org.json.JSONObject
import org.json.JSONArray
import java.util.List

//import org.xtendroid.parcel.AndroidParcelableEnum

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
class ParcelableTestA implements android.os.Parcelable {
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

	// object reference recursion
	@Property
	ParcelableTestA ppta
	
	@JsonProperty
	boolean boolz
}

@AndroidParcelable
class ParcelableTestB implements Parcelable
{
	JSONObject _jsonObj // required for both to interoperate or data will be lost during the marshalling process

	@Property
	byte b
	
	@Property
	Date dt

	@Property
	Date[] dtdt
	
	@Property
	ParcelableTestA ppta

	@JsonProperty
	double d_

	@JsonProperty
	String s
	
	@JsonProperty("mint")
	int useAnAliasInstead

	@JsonProperty
	double[] dd__
}
/*

	// Broken by design (tm)
	@JsonProperty // disallowed by @AndroidParcelable, allowed by @JsonProperty
//	Double DD_

//	@JsonProperty // disallowed by both
//	Double[] D__
}*/

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
	List<Rare> rares;
	
	/**
	 * Primitive to JSON
	 */
	@JsonProperty("o")
	String[] o;
	
	/**
	 * Rare is a JSON object
	 */
	@JsonProperty("y")
	Rare[] y;
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
/*
*/

class Rare
{
	@JsonProperty
	String stringy
	
	@JsonProperty
	List<String> listy
	
	@JsonProperty
	List<C> cs
}

// TODO do inheritance tests to see unannotated fields added to child types

// TODO enum tests
//@AndroidParcelableEnum // TODO extend enum type to be parcelized
//@XtendEnum(String, float, int, Complex) // provide types for the members 
//enum EnumTestA
//{
//	/**
//	 * @XtendEnumValue("", 1.0f, 1337, new Complex())
//	 * weetikveel
//	 * @XtendEnumValue("", 1.0f, 1337, new Complex())
//	 * , hu
//	 *
//	weetikveel, hu, nog, wat
//}