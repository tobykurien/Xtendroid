package org.xtendroid.xtendroidtest.test

import android.content.Intent
import android.test.ActivityInstrumentationTestCase2
import org.json.JSONObject
import org.xtendroid.xtendroidtest.MainActivity
import org.xtendroid.xtendroidtest.parcel.ModelRoot
import android.util.SparseBooleanArray
import org.json.JSONArray

class ActivityParcelableAnnotationTest extends ActivityInstrumentationTestCase2<MainActivity> {
	
	new() {
		super(MainActivity)
	}
	
	val label = "payload"
	protected override setUp()
	{
        val newIntent = new Intent()
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
		
        val model = new ModelRoot(new JSONObject(jsonRaw.toString))
        model.b_byte = "ä".bytes.get(0)
        model.c_float = 1.0f
        model.h_byte_array = "äöëü".bytes
        model.j_float_array = #[ 1.0f, 2.0f, 3.0f ]
        val sba = new SparseBooleanArray()
        sba.put(0,false)
        sba.put(1,true)
        sba.put(2,false)
        model.m_bool_array = sba
        model.r_json_array = new JSONArray('[false,true,false]');
	    newIntent.putExtra(label, model)
		activityIntent = newIntent
	}
	
	def void testAndroidParcelableAnnotation() {
		activity.runOnUiThread [|
			assertTrue(activity.intent.extras.containsKey(label))
			val model = activity.intent.extras.getParcelable(label) as ModelRoot
//        model.b_byte = "ä".bytes.get(0)
			assertEquals(model.b_byte, "ä".bytes.get(0))
//        model.c_float = 1.0f
			assertEquals(model.c_float, 1.0f)
//        model.h_byte_array = "äöëü".bytes
			assertEquals(model.h_byte_array, "äöëü".bytes)
//        model.j_float_array = #[ 1.0f, 2.0f, 3.0f ]
			assertEquals(model.j_float_array, #[ 1.0f, 2.0f, 3.0f ])
//        val sba = new SparseBooleanArray()
//        sba.put(0,false)
//        sba.put(1,true)
//        sba.put(2,false)
//        model.m_bool_array = sba
			assertEquals(model.m_bool_array.get(1), true)
//        model.r_json_array = new JSONArray('[false,true,false]');			
        	assertEquals(model.r_json_array, new JSONArray('[false,true,false]'));			
		]
		Thread.sleep(1000) // wait for above thread to run
	}
	
	def void testJsonParcelableAnnotation() {
		activity.runOnUiThread [|
			assertTrue(activity.intent.extras.containsKey(label))
			val model = activity.intent.extras.getParcelable(label) as ModelRoot
		]
		Thread.sleep(5000) // wait for above thread to run
	}
}