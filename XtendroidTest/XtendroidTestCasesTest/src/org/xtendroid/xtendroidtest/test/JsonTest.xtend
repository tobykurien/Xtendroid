package org.xtendroid.xtendroidtest.test

import android.test.AndroidTestCase
import java.text.SimpleDateFormat
import java.util.Date
import java.util.List
import org.json.JSONObject
import org.xtendroid.json.AndroidJson
import org.xtendroid.annotations.BundleProperty
import java.lang.annotation.Documented
import android.annotation.SuppressLint

/**
 * 
 * This test demonstrates the JSON to POJO translation of...
 * 1) primitive JSON types (i.e. String, boolean, Number), but not 'null'
 * 2) String -> Date (also array, List), according to the default date format string or one provided the user
 * 3) A JSON Object containing another JSON Object
 * 4) The array version of the aforementioned
 * 5) The java.util.List version of the aforementioned
 * 
 */
@AndroidJson class Result {
	var String url = null
	var String title = null
	var int id = 0
	var boolean published = false
}

@AndroidJson class ResultHolder {
	var List<Result> results
	var ArraysOfPrimitives[] arraysOfPrimitives
	var List<ListsOfPrimitives> listsOfPrimitives
	var DateTypes dateTypes;
	var ZuluFormat zuluFormat;
}

class DateTypes {
	@AndroidJson("yyyy-MM-dd")
	var Date scalar

	@AndroidJson("yyyy-MM-dd")
	var Date[] array

	@AndroidJson("yyyy-MM-dd")
	var List<Date> list
}

@AndroidJson class ZuluFormat {
	var Date scalar
	var Date[] array
	var List<Date> list
}

@AndroidJson class ArraysOfPrimitives {
	var Double[] ddta
	var double[] dta
	var int[] ita
	var Integer[] iita
	var long[] lta
	var Long[] llta
	var boolean[] bta
	var Boolean[] bbta
}

@AndroidJson class ListsOfPrimitives {
	var List<Double> ddtl
	var List<Integer> iitl
	var List<Long> lltl
	var List<Boolean> bbtl
}

@AndroidJson class Response {
	ResultHolder responseData = null
	@AndroidJson("it")
	var int it_is_a_reserved_keyword = 0

	var protected Double ddt // this gets left alone
	var package double dt // this gets left alone
	var public Integer iit = 0 // this gets left alone
	
	var long lt = 0
	var Long llt = null
	var boolean bt = false
	var Boolean bbt = false
}

class JsonTest extends AndroidTestCase {
	def testJson() {
		var jsonRaw = '''
			{
				"responseData": 
				  	{
				  		"results":[
							  		{"url":"http://one.com", "title": "One", "id": 1, "published": true}
									, {"url":"http://two.com", "title": "Two", "id": 2, "published": true}
									, {"url":"http://three.com", "title": "Three", "id": 3, "published": true}
									, {"url":"http://four.com", "title": "Four", "id": 4, "published": false}
						]
						, "arraysOfPrimitives" : [{
							  "ddta" : [ 0.01, 0.02 ]
							, "dta"  : [ 0.01 ]
							, "ita"  : [ 1234 ]
							, "iita" : [ 1234 ]
							, "lta"  : [ 2345 ]
							, "llta" : [ 1234 ]
							, "bta"  : [ true ]
							, "bbta" : [ true ]
						}]
						, "listsOfPrimitives" : [{
							  "ddtl" : [ 0.01, 0.02 ]
							, "iitl" : [ 1234 ]
							, "lltl" : [ 2345 ]
							, "bbtl" : [ true ]
						}]
						, "dateTypes" : {
							  "scalar" : "1981-07-07"
							, "array"  : [ "1981-07-07" ]
							, "list"   : [ "1981-07-07" ]
						}
						, "zuluFormat" :
						{
							  "scalar" : "2011-11-11T12:34:56.789Z"
							, "array" : [ "2011-11-11T12:34:56.789Z" ]
							, "list" : [ "2011-11-11T12:34:56.789Z" ]
						}
					}
					
					, "ddt" : 0.01
					, "dt"  : 0.01
					, "it"  : 1234
					, "iit" : 1234
					, "lt"  : 2345
					, "llt" : 2345
					, "bt"  : true
					, "bbt" : true
			}
		'''

		val response = new Response(new JSONObject(jsonRaw))
		val ret = response.responseData.results

		assertNotNull(ret)
		assertTrue(ret.length == 4)
		assertEquals(ret.get(0).url, "http://one.com")
		assertEquals(ret.get(0).title, "One")
		assertEquals(ret.get(0).id, 1)
		assertEquals(ret.get(0).published, true)
		assertEquals(ret.get(3).published, false)

		// these fields should have been left alone
		assertNull(response.ddt) //assertEquals(response.ddt, 0.01)
		assertEquals(0.0, response.dt) //assertEquals(response.dt, 0.01)
		assertEquals(0, response.iit)
		
		assertEquals(response.itisareservedkeyword, 1234)
		assertEquals(response.lt, 2345)
		assertTrue(response.bt)

		val arraysOfPrimitives = response.responseData.arraysOfPrimitives.get(0)
		assertEquals(arraysOfPrimitives.ddta.get(0), 0.01)
		assertEquals(arraysOfPrimitives.ddta.get(1), 0.02)
		assertEquals(arraysOfPrimitives.lta.get(0), 2345)
		assertEquals(arraysOfPrimitives.ita.get(0), 1234)
		assertEquals(arraysOfPrimitives.bbta.get(0), true)

		val listsOfPrimitives = response.responseData.listsOfPrimitives.get(0)
		assertEquals(listsOfPrimitives.ddtl.head, 0.01)
		assertEquals(listsOfPrimitives.ddtl.drop(1).head, 0.02)
		assertEquals(listsOfPrimitives.iitl.head, 1234)
		assertEquals(listsOfPrimitives.lltl.head, 2345)
		assertEquals(listsOfPrimitives.bbtl.head, true)

		val dateTypes = response.responseData.dateTypes
		val format1 = new SimpleDateFormat("yyyy-MM-dd")
		assertEquals(dateTypes.scalar.time, format1.parse("1981-07-07").time)
		assertEquals(dateTypes.array.get(0).time, format1.parse("1981-07-07").time)

		val zuluFormat = response.responseData.zuluFormat
		val format2 = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
		assertEquals(zuluFormat.scalar.time, format2.parse("2011-11-11T12:34:56.789Z").time)
		assertEquals(zuluFormat.array.get(0).time, format2.parse("2011-11-11T12:34:56.789Z").time)

	}

}
