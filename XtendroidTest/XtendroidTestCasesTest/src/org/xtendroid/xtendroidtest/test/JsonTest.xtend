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
 * 2) String -> Date (also array, List), according to the default date format string or one provided the user
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

	@JsonProperty
	var ZuluFormat zuluFormat;
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

class ZuluFormat
{
	@JsonProperty
	var Date scalar
	
	@JsonProperty
	var Date[] array
	
	@JsonProperty
	var List<Date> list
}

class ArraysOfPrimitives
{
	@JsonProperty
	var Double[] ddta

	@JsonProperty
	var double[] dta

	@JsonProperty
	var int[] ita

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
		   		, "zuluFormat" :
		   		{
		   			  "scalar" : "2011-11-11T12:34:56.789Z"
		   			, "array" : "2011-11-11T12:34:56.789Z"
		   			, "list" : "2011-11-11T12:34:56.789Z"
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
		
		assertEquals(response.ddt, response.dt)
		assertEquals(response.itisareservedkeyword, response.iit)
		assertEquals(response.lt, response.llt)
		assertEquals(response.bt, response.bbt)
		
		val arraysOfPrimitives = response.responseData.arraysOfPrimitives.get(0)
		assertEquals(arraysOfPrimitives.ddta.get(0), arraysOfPrimitives.dta.get(0))
		assertEquals(arraysOfPrimitives.lta.get(0), arraysOfPrimitives.llta.get(0))
		assertEquals(arraysOfPrimitives.ita.get(0), arraysOfPrimitives.iita.get(0))
		assertEquals(arraysOfPrimitives.bbta.get(0), arraysOfPrimitives.bta.get(0))
		
		val listsOfPrimitives = response.responseData.listsOfPrimitives.get(0)
		assertEquals(listsOfPrimitives.ddtl.head, 0.01)
		assertEquals(listsOfPrimitives.iitl.head, 1234)
		assertEquals(listsOfPrimitives.lltl.head, 1234)
		assertEquals(listsOfPrimitives.bbtl.head, true)

		val dateTypes = response.responseData.dateTypes
		assertEquals(dateTypes.scalar, dateTypes.array.get(0))
		assertEquals(dateTypes.array.get(0), dateTypes.list.head)

		val zuluFormat = response.responseData.zuluFormat
		assertEquals(zuluFormat.scalar, zuluFormat.array.get(0))
		assertEquals(zuluFormat.array.get(0), zuluFormat.list.head)
		
	}
	
		
}