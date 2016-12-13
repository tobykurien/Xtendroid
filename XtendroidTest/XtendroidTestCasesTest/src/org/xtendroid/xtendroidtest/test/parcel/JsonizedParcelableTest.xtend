package org.xtendroid.xtendroidtest.test.parcel

/**
 * TODO
 * - make "attr" : null, String by default
 */

import org.xtendroid.json.AndroidJsonizedParcelable
import org.junit.Test
import static org.junit.Assert.*
import org.json.JSONObject
import android.os.Parcel
import android.os.Parcelable
import android.support.test.runner.AndroidJUnit4
import org.junit.runner.RunWith
import android.test.suitebuilder.annotation.SmallTest

/**
 * We generate getters/setters/models, depending on the JSON model
 * Minimal manual work is required
*/
@AndroidJsonizedParcelable('{ "aBoolean" : true }') class ABooleanJz {}
@AndroidJsonizedParcelable('{ "anInteger" : 800 }') class ALongJz {}
@AndroidJsonizedParcelable('{ "aFloat" : 800.01 }') class ADoubleJz {}
@AndroidJsonizedParcelable('{ "aString" : "string" }') class AStringJz {}

@AndroidJsonizedParcelable('{ "bString" : "string", "bFloat" : 800.00 }') class AHeterogenousObject {}

// NOTE: suffixed 'Parent' because of name collision TODO create test case
@AndroidJsonizedParcelable('{ "anObjectWithAStringFirstJz" : { "aString" : "string" } }') class ATypeWithAStringParent {}

@AndroidJsonizedParcelable('{
	"aDeepNesting0Jz" : {
		"aDeepNesting1Jz" : {
			"aDeepNesting2Jz" : {
				"aDeepNesting3Jz" : { "anInteger" : 4321 }
			}
		}
	}
}') class ATypeWithDeepNesting {}

@AndroidJsonizedParcelable('{ "manyBooleans" : [ true, false, true ] }') class ManyBooleansParent {}
@AndroidJsonizedParcelable('{ "manyIntegers" : [ 0, 1, 2 ] }') class ManyIntegersParent {}
@AndroidJsonizedParcelable('{ "manyFloats" : [ 0.0, 1.1, 2.2 ] }') class ManyFloatsParent {}
@AndroidJsonizedParcelable('{ "manyStrings" : [ "str0", "str1" ] }') class ManyStringsParent {}
@AndroidJsonizedParcelable('{ "manyObjectsWithStringsFirst" : [ { "aString" : "string" } ] }') class ManyObjectsWithStringsParent {}

@AndroidJsonizedParcelable('{
	"aBoolean" : true
	, "anInteger" : 800
	, "aFloat" : 800.00
	, "aString" : "string"
	, "anObjectWithAStringSecondJz" : { "aString" : "string" }
	, "deepNesting0Jz" : {
		"deepNesting1Jz" : {
			"deepNesting2Jz" : {
				"deepNesting3Jz" : { "anInteger" : 4321 }
			}
		}
	}
}') class ScalarsTogether {}

@AndroidJsonizedParcelable('{
	"manyBooleans" : [ true, false, true ]
	, "manyIntegers" : [ 0, 1, 2 ]
	, "manyFloats" : [ 0.0, 1.1, 2.2 ]
	, "manyStrings" : [ "str0", "str1" ]
	, "manyObjectsWithStringsSecond" : [ { "aString" : "string" } ]
}') class VectorsTogether {}

@AndroidJsonizedParcelable('{
	"aBoolean" : true
	, "anInteger" : 800
	, "aFloat" : 800.00
	, "aString" : "string"
	, "anObjectWithAStringThird" : { "aString" : "string" }
	, "manyBooleans" : [ true, false, true ]
	, "manyIntegers" : [ 0, 1, 2 ]
	, "manyFloats" : [ 0.0, 1.1, 2.2 ]
	, "manyStrings" : [ "str0", "str1" ]
	, "manyObjectsWithStringsThird" : [ { "aString" : "string" } ]
}') class EverythingTogether {}

// TODO write test case that checks that_this_is_a_good_member // snake case
// TODO write test case that checks type name collisions, and gives a warning?
// TODO null tests
// Add (randomized? overkill?) version number to prevent name collision.

// TODO write unit test with URLs
//@AndroidJsonizedParcelable("http://api.icndb.com/jokes/random") ChuckNorrisApi {}
// the http plumbing seems broken, besides the call is incomplete
// the VERB could be POST or something else (TODO add parameters)

@AndroidJsonizedParcelable('{
 "query": {
  "count": 24,
  "created": "2013-03-21T20:13:42Z",
  "lang": "en-US",
  "results": {
   "Release": [
    {
     "UPC": "602527291567",
     "explicit": "0",
     "flags": "2",
     "id": "218641405",
     "label": "Streamline/Interscope/Kon Live",
     "rating": "-1",
     "releaseDate": "2009-11-23T08:00:00Z",
     "releaseYear": "2009",
     "rights": "160",
     "title": "The Fame Monster",
     "typeID": "2",
     "url": "http://new.music.yahoo.com/lady-gaga/albums/fame-monster--218641405",
     "Artist": {
      "catzillaID": "0",
      "flags": "115202",
      "hotzillaID": "1810013384",
      "id": "58959115",
      "name": "Lady Gaga",
      "rating": "-1",
      "trackCount": "172",
      "url": "http://new.music.yahoo.com/lady-gaga/",
      "website": "http://www.ladygaga.com/"
     },
     "ItemInfo": {
      "ChartPosition": {
       "last": "1",
       "now": "1"
      }
     }
    }]
   }
  }
}')
class MusicReleases {
	public static val input = '{
 "query": {
  "count": 24,
  "created": "2013-03-21T20:13:42Z",
  "lang": "en-US",
  "results": {
   "Release": [
    {
     "UPC": "602527291567",
     "explicit": "0",
     "flags": "2",
     "id": "218641405",
     "label": "Streamline/Interscope/Kon Live",
     "rating": "-1",
     "releaseDate": "2009-11-23T08:00:00Z",
     "releaseYear": "2009",
     "rights": "160",
     "title": "The Fame Monster",
     "typeID": "2",
     "url": "http://new.music.yahoo.com/lady-gaga/albums/fame-monster--218641405",
     "Artist": {
      "catzillaID": "0",
      "flags": "115202",
      "hotzillaID": "1810013384",
      "id": "58959115",
      "name": "Lady Gaga",
      "rating": "-1",
      "trackCount": "172",
      "url": "http://new.music.yahoo.com/lady-gaga/",
      "website": "http://www.ladygaga.com/"
     },
     "ItemInfo": {
      "ChartPosition": {
       "last": "1",
       "now": "1"
      }
     }
    }]
   }
  }
 }'
}

@AndroidJsonizedParcelable('{
	"i" : 1,
	"b" : true,
	"s" : "string",
	"array" : [ 0, 1, 2 ]
}')
class WildernessResponse1 {}

@AndroidJsonizedParcelable('{ "class" : "looky here a reserved keyword" }')
class WildernessResponse_Reserved_Keyword {}

@AndroidJsonizedParcelable('{
    "texts": [
        {
            "id": "mobileAppsConfig_clothingline",
            "text": "VESTMENTS_DEFAULT",
            "@_this_will_totally_not_wor _@" : "params",
            "12 34" : "totally starts with a number"
        }	
    ]
}')
class WildernessResponse2 {
	var meh = 'meh'
}

@RunWith(AndroidJUnit4)
@SmallTest
class JsonizedParcelableTest {

	@Test
	public def testScalarJson() {
		assertTrue(new ABooleanJz(new JSONObject('{ "aBoolean" : true }')).getABoolean)
		assertTrue(new ALongJz(new JSONObject('{ "anInteger" : 800 }')).getAnInteger == 800)
		assertTrue(new ADoubleJz(new JSONObject('{ "aFloat" : 800.008 }')).getAFloat == 800.008)
		assertTrue(new AStringJz(new JSONObject('{ "aString" : "string" }')).getAString.equals("string"))
		assertTrue(new AHeterogenousObject(new JSONObject('{ "bString" : "meh" }')).getBString.equals("meh"))
		assertTrue(new ATypeWithAStringParent(new JSONObject('{ "anObjectWithAStringFirstJz" : { "aString" : "string" } }')).getAnObjectWithAStringFirstJz.getAString.equals("string"))
		assertTrue(new ATypeWithDeepNesting(new JSONObject('{
			"aDeepNesting0Jz" : {
				"aDeepNesting1Jz" : {
					"aDeepNesting2Jz" : {
						"aDeepNesting3Jz" : { "anInteger" : 4321 }
					}
				}
			}
		}')).getADeepNesting0Jz.getADeepNesting1Jz.getADeepNesting2Jz.getADeepNesting3Jz.getAnInteger == 4321)
	}

	@Test
	def testManyParcelables() {
		testParcelable(new ABooleanJz(new JSONObject('{ "aBoolean" : false }')))
		testParcelable(new ALongJz(new JSONObject('{ "anInteger" : 803 }')))
		testParcelable(new ADoubleJz(new JSONObject('{ "aFloat" : 803.008 }')))
		testParcelable(new AStringJz(new JSONObject('{ "aString" : "meh string" }')))
		testParcelable(new AHeterogenousObject(new JSONObject('{ "bString" : "abcd" }')))
		testParcelable(new ATypeWithAStringParent(new JSONObject('{ "anObjectWithAStringFirstJz" : { "aString" : "bla" } }')))
		testParcelable(new ATypeWithDeepNesting(new JSONObject('{
			"aDeepNesting0Jz" : {
				"aDeepNesting1Jz" : {
					"aDeepNesting2Jz" : {
						"aDeepNesting3Jz" : { "anInteger" : 4321 }
					}
				}
			}
		}')))
	}

	@Test
	public def testBooleanVectorJson()
	{
		val stuff = new ManyBooleansParent(new JSONObject('{ "manyBooleans" : [ true, false, true, false ] }'))
		assertFalse(stuff.getManyBooleans.get(3))
		testParcelable(stuff)
	}

	@Test
	public def testIntegerVectorJson()
	{
		val stuff = new ManyIntegersParent(new JSONObject('{ "manyIntegers" : [ 0, 1, 2, 3, 4 ] }'))
		assertTrue (stuff.getManyIntegers.get(3) == 3L)
		testParcelable(stuff)
	}

	@Test
	public def testFloatVectorJson()
	{
		val stuff = new ManyFloatsParent(new JSONObject('{ "manyFloats" : [ 0.0, 1.0, 2.0, 3,0f, 4.0 ] }'))
		assertTrue (stuff.getManyFloats.get(3) == 3.0f) // float === double?
		testParcelable(stuff)
	}

	@Test
	public def testStringVectorJson()
	{
		val stuff = new ManyStringsParent(new JSONObject('{ "manyStrings" : [ "0", "1", "2", "3" ] }'))
		assertTrue (stuff.getManyStrings.get(3).equals("3"))
		testParcelable(stuff)
	}

	@Test
	public def testObjectVectorJson()
	{
		val stuff = new ManyObjectsWithStringsParent(new JSONObject('{ "manyObjectsWithStringsFirst" : [ { "aString" : "string" } ] }'))
		assertTrue (stuff.getManyObjectsWithStringsFirst.get(0).getAString.equals("string"))
		testParcelable(stuff)
	}

	@Test
	public def testTheOriginalExampleAtJsonizer()
	{
		val musicReleases = new MusicReleases(new JSONObject(MusicReleases.input))
		assertTrue(musicReleases.getQuery.getResults.getRelease.get(0).getUPC.equals("602527291567"))
		testParcelable(musicReleases)
	}

	// TODO do the other tests... like isDirty etc. getJSONObject

	@Test
	public def testsFromTheWilderness()
	{
		val res0 = new WildernessResponse1(new JSONObject('{"i":null, "b":null, "s":null, "array":null}'))
		//assertNull(res0.optI) // bad test, null -> 0, because it's a primitive
		assertEquals(res0.optI, 0)
		assertEquals(res0.optI(1), 1)
		assertFalse(res0.optB) // null -> false
		assertNotNull(res0.optS) // null -> "null"
		//assertEquals(res0.optS("meh"), "meh") // bad test, on a string type "attr" : null resolves to literal string "null" instance
		assertEquals(res0.optS, "null")
		assertNull(res0.optArray)
		val res1 = new WildernessResponse1(new JSONObject('{"i":0, "b":true, "s":"string", "array":[0,1,2]}'))
		assertEquals(res1.optI, 0)
		assertTrue(res1.optB)
		assertEquals(res1.optS, "string")
		assertNotNull(res1.optArray)

		testParcelable(res0)
		testParcelable(res1)
	}

	static def<T> void testParcelable(T parcelable) {

		// Obtain a Parcel object and write the parcelable object to it
		// parcelable.writeToParcel(parcel, 0)
		val parcel = Parcel.obtain

		assertNotNull(parcel)

		val Class[] params = #[ Parcel, Integer.TYPE ]
		val method = parcelable.class.getDeclaredMethod("writeToParcel", params)
		method.invoke(parcelable, parcel, 0)

		// After you're done with writing, you need to reset the parcel for reading
		parcel.dataPosition = 0

		// Reconstruct object from parcel and asserts:
		// val createdFromParcel = T.CREATOR.createFromParcel(parcel)
		val creator = parcelable.class.getDeclaredField("CREATOR")
		creator.accessible = true
		val value = creator.get(null) as Parcelable.Creator
		val createFromParcelMethod = value.class.getDeclaredMethod("createFromParcel", #[ Parcel ])

		val createdFromParcel = createFromParcelMethod.invoke(value, parcel)

		assertNotNull(parcelable.toString)
		assertNotNull(createdFromParcel.toString)
		assertEquals(parcelable.toString, createdFromParcel.toString)
	}
}
