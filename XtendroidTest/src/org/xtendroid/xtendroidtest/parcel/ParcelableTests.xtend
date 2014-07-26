package org.xtendroid.xtendroidtest.parcel

import org.xtendroid.parcel.AndroidParcelable
import android.os.Parcelable
import java.util.Date
import org.xtendroid.json.JsonProperty
import org.json.JSONObject
import org.json.JSONArray
import java.util.List
import android.util.SparseBooleanArray
import org.xtendroid.annotations.EnumProperty

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
class ModelRoot implements Parcelable
{
	@Property
	JSONObject jsonObj
	
	@JsonProperty
	String a_str
	
	@Property
	byte   b_byte
	
	@Property
	float  c_float
	
	@JsonProperty
	double c_double
	
	@JsonProperty
	int    d_int
	
	@JsonProperty
	long   e_long
	
	@JsonProperty
	String[] f_string_array
	
	@JsonProperty
	boolean[] g_boolean_array

	@Property
	byte[] h_byte_array

	@JsonProperty
	double[] i_double_array

	@Property // not supported
	float[] j_float_array

	@JsonProperty
	int[] k_int_array

	@JsonProperty
	long[] l_long_array

	@JsonProperty
	List<String> f_string_list
	
//	@JsonProperty // unsupported by @AndroidParcelable
//	List<Boolean> g_boolean_list
//
//	@JsonProperty // unsupported by @AndroidParcelable
//	List<Byte> h_byte_list
//
//	@JsonProperty // unsupported by @AndroidParcelable
//	List<Double> i_double_list
//
//	@JsonProperty // unsupported by @AndroidParcelable
//	@Property // not supported by @JsonProperty
//	List<Float> j_float_list
//
//	@JsonProperty // unsupported by @AndroidParcelable
//	List<Integer> k_int_list
//
//	@JsonProperty // unsupported by @AndroidParcelable
//	List<Long> l_long_list
	
	@Property
	SparseBooleanArray m_bool_array
	
	// special cases start here
	@JsonProperty
	boolean n_bool
	
	@JsonProperty
	boolean[] o_bool_array

	@JsonProperty
	Date p_date

	@JsonProperty
	Date[] q_date_array
	
	@Property
	JSONArray r_json_array
	
	@JsonProperty
	SubModel submodel
	
	@JsonProperty
	SubModel[] lotsaSubmodels
	
	@JsonProperty
	List<SubModel> evenMore
	
	// Missing in the 1st implementation
	@Property
	char[] s_char_array
	
//	@Property // not supported with @AndroidParcelable
//	Exception exception
}

@AndroidParcelable
class SubModel implements Parcelable
{
	@JsonProperty
	boolean a
}

@AndroidParcelable
class E implements android.os.Parcelable {
	JSONObject jsonObj

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
	JSONObject jsonObj // required for both to interoperate or data will be lost during the marshalling process

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
	JSONObject jsonObject
	
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
	
	@JsonProperty
	int i
	
	@JsonProperty
	int j
}

enum ABCEnum
{
	a,b,c
}

@AndroidParcelable
class EnumTypesHolder implements Parcelable
{
	@EnumProperty(enumType=ABCEnum) // pre-defined
	String alpha = "a"
	
	
	@EnumProperty(name="DEFEnum", values=#["d","e","f"])
	@JsonProperty
	String delta = "d"

	@JsonProperty
	String epsilon = "e"
}

@AndroidParcelable
class Datezzz implements Parcelable
{
	JSONObject jsonObj
	
	@JsonProperty("ddd-mmm-YYYY")
	Date meh
	
	@JsonProperty("yyyy-MM-dd'T'HH:mm:ssZ")
	Date[] mehArray
	
	@JsonProperty("yyyy-MM-dd'T'HH:mm:sssZ")
	List<Date> mehList
	
	@JsonProperty
	int mehint
}