package org.xtendroid.xtendroidtest.test

import android.test.AndroidTestCase
import android.test.suitebuilder.annotation.SmallTest
import java.util.List
import org.json.JSONObject
import org.xtendroid.json.JsonProperty
import java.util.Date

/**
 * 
 * This test demonstrates the JSON to POJO translation of...
 * 1) primitive JSON types (i.e. String, boolean, Number), but not 'null'
 * @ 2) String -> Date (also array, List), according to the default date format string or one provided the user
 * 3) A JSON Object containing another JSON Object
 * 4) The array version of the aforementioned
 * 5) The java.util.List version of the aforementioned
 * 
 */
 
 
class Result
{
	@JsonProperty
	var String url = null

	@JsonProperty
	var String title = null

	@JsonProperty
	var int id = 0

	@JsonProperty
	var boolean published = false
}

class ResultHolder
{
	@JsonProperty
	var List<Result> results
	
	@JsonProperty
	var ArraysOfPrimitives[] arraysOfPrimitives

	@JsonProperty
	var List<ListsOfPrimitives> listsOfPrimitives
	
	@JsonProperty
	var DateTypes dateTypes;
}

class DateTypes
{
	@JsonProperty("yyyy-MM-dd")
	var Date scalar
	
	@JsonProperty("yyyy-MM-dd")
	var Date[] array
	
	@JsonProperty("yyyy-MM-dd")
	var List<Date> list
}

class ArraysOfPrimitives
{
	@JsonProperty
	var Double[] ddta

	@JsonProperty
	var double[] dta

	@JsonProperty("ita")
	var int[] it_is_a_reserved_keyword

	@JsonProperty
	var Integer[] iita
	
	@JsonProperty
	var long[] lta

	@JsonProperty
	var Long[] llta

	@JsonProperty
	var boolean[] bta

	@JsonProperty
	var Boolean[] bbta
}


class ListsOfPrimitives
{
	@JsonProperty
	var List<Double> ddtl

	@JsonProperty
	var List<Integer> iitl
	
	@JsonProperty
	var List<Long> lltl

	@JsonProperty
	var List<Boolean> bbtl
}

class Response
{
	@JsonProperty
	ResultHolder responseData = null
	
	@JsonProperty
	var Double ddt

	@JsonProperty
	var double dt

	@JsonProperty("it")
	var int it_is_a_reserved_keyword = 0

	@JsonProperty
	var Integer iit = 0
	
	@JsonProperty
	var long lt = 0

	@JsonProperty
	var Long llt = null

	@JsonProperty
	var boolean bt = false

	@JsonProperty
	var Boolean bbt = false
}

@SmallTest
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
				   	  "ddta" : [ 0.01 ]
				   	, "dta"  : [ 0.01 ]
				   	, "ita"  : [ 1234 ]
				   	, "iita" : [ 1234 ]
				   	, "lta"  : [ 1234 ]
				   	, "llta" : [ 1234 ]
				   	, "bta"  : [ true ]
				   	, "bbta" : [ true ]
		   		}]
		   		, "listsOfPrimitives" : [{
				   	  "ddtl" : [ 0.01 ]
				   	, "iitl" : [ 1234 ]
				   	, "lltl" : [ 1234 ]
				   	, "bbtl" : [ true ]
		   		}]
		   		, "dateTypes" : {
		   			  "scalar" : "1981-07-07"
		   			, "array"  : [ "1981-07-07" ]
		   			, "list"   : [ "1981-07-07" ]
		   		}
		   	}
		   	
		   	, "ddt" : 0.01
		   	, "dt"  : 0.01
		   	, "it"  : 1234
		   	, "iit" : 1234
		   	, "lt"  : 1234
		   	, "llt" : 1234
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
	}
	
		
}