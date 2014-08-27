package org.xtendroid.xtendroidtest.test

import android.content.Intent
import android.os.Parcelable
import android.test.ActivityInstrumentationTestCase2
import android.test.UiThreadTest
import android.util.SparseBooleanArray
import org.json.JSONArray
import org.json.JSONObject
import org.xtendroid.xtendroidtest.activities.MainActivity
import org.xtendroid.xtendroidtest.parcel.ModelRoot

import static android.test.MoreAsserts.*

class ActivityParcelableAnnotationTest extends ActivityInstrumentationTestCase2<MainActivity> {
	
	var delay = 2000
	
	new() {
		super(MainActivity)
	}
	
    val jsonRaw = '''
	{
		  "a_str" : "String"
		, "c_double" : 1.1234
		, "d_int" : 1234
		, "e_long" : 123412341234
		, "f_string_array" : [ "head", "tail" ]
		, "g_boolean_array" : [ true, false, true ] 
		, "i_double_array" : [ 1.0e-2, 0.01, -1.0e-2 ] 
		, "k_int_array" : [ 1,2,3,4,5 ]
		, "l_long_array" : [ 1,2,3,4,5 ]
		, "f_string_list" : [ "head", "tail" ]
		, "n_bool" : true
		, "o_bool_array" : [ true, false, true ]
		, "p_date" : "2011-11-11T12:34:56.789Z"
		, "q_date_array" : [ "2011-11-11T12:34:56.789Z" ]
		, "submodel" : { "a" : true }
		, "lotsaSubmodels" : [ { "a" : true } ]
		, "evenMore" : [ { "a" : true } ]
	}
	'''
	
	val label = "org.xtendroid.xtendroidtest.test.payload"
	
	protected def createSparseBooleanArray() {
		val sba = new SparseBooleanArray()
		        sba.put(0,false)
		        sba.put(1,true)
		        sba.put(2,false)
		sba
	}
	
	protected override setUp()
	{
		super.setUp
        val newIntent = new Intent()
		
		// provide all(?) the input for @AndroidJson annotated fields
        val model = new ModelRoot(new JSONObject(jsonRaw.toString))
        
        model.b_byte = "ä".bytes.get(0)
        model.c_float = 1.0f
        model.h_byte_array = "äöëü".bytes
        model.j_float_array = #[ 1.0f, 2.0f, 3.0f ]
        model.m_bool_array = createSparseBooleanArray()
        model.r_json_array = new JSONArray('[false,true,false]');
        model.s_char_array = #[ 'a' , 'b' , 'c' ]
        
        // prepare activity, insert Intent
	    newIntent.putExtra(label, model as Parcelable)
	    activityInitialTouchMode = false
		activityIntent = newIntent
	}
	
	@UiThreadTest
	def testPureAndroidParcelableAnnotation()
	{
		assertTrue(activity.intent.extras.containsKey(label))
		val model = activity.intent.getParcelableExtra(label) as ModelRoot
		
		assertEquals(model.b_byte, "ä".bytes.get(0))
		
		assertEquals(model.c_float, 1.0f)
		
		for (var i=0; i<4; i++)
			assertEquals(model.h_byte_array.get(i), "äöëü".bytes.get(i))
			
		for (var i=0; i<3; i++)			
			assertEquals(model.j_float_array.get(i), #[ 1.0f, 2.0f, 3.0f ].get(i))
		assertEquals(model.m_bool_array.get(1), true)
		
		val sba = createSparseBooleanArray
		for (var i=0; i<3; i++)
			assertEquals(model.m_bool_array.get(i), sba.get(i))	
		
		// TODO fix below, NPE
//		for (var i=0; i<3; i++)
//			assertEquals(model.r_json_array.getBoolean(i), new JSONArray('[false,true,false]').getBoolean(i));
		
		// TODO fix below, out-of-bounds
//		for (var i=0; i<3; i++)
//			assertEquals(String.valueOf(model.s_char_array.get(i)), #[ 'a' , 'b' , 'c' ].get(i))					
	}
	
	@UiThreadTest
	def void dont_testAndroidJsonAnnotatedFields() {
		assertTrue(activity.intent.extras.containsKey(label))
		val model = activity.intent.getParcelableExtra(label) as ModelRoot
		val compareModel = new ModelRoot(new JSONObject(jsonRaw))
		
		// from @JsonProperty
		assertEquals(model.astr, compareModel.astr)
		assertEquals(model.cdouble, compareModel.cdouble)
		assertEquals(model.dint, compareModel.dint)
		assertEquals(model.elong, compareModel.elong)
		assertEquals(model.fstringarray, compareModel.fstringarray)
		assertEquals(model.gbooleanarray, compareModel.gbooleanarray)
		assertEquals(model.idoublearray, compareModel.idoublearray)
		assertEquals(model.kintarray, compareModel.kintarray)
		assertEquals(model.llongarray, compareModel.llongarray)
		assertEquals(model.nbool, compareModel.nbool)
		assertEquals(model.oboolarray, compareModel.oboolarray)
		assertEquals(model.pdate, compareModel.pdate)
		assertEquals(model.qdatearray, compareModel.qdatearray)
		assertEquals(model.submodel, compareModel.submodel)
		assertEquals(model.lotsaSubmodels, compareModel.lotsaSubmodels)
		assertEquals(model.evenMore, compareModel.evenMore)
	}
}