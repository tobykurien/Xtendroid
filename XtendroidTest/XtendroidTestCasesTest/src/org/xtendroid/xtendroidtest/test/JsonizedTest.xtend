package org.xtendroid.xtendroidtest.test

/**
 * TODO
 * + warn for "@attr attrpart2" : "value", or just strip the non-ascii values
 * + handle name collisions, by suffixing digits, or by not re-registering the damn thing, the decoration can go on without re-registering
 * - make "attr" : null, String by default
 * + "class" : "yes, this is a reserved keyword" will break your shizzle (scan for all the reserved keywords), quadratic costs...
 * - write unit tests!
 */

import org.xtendroid.json.AndroidJsonized
import org.junit.Test
import static org.junit.Assert.*
import org.json.JSONObject

/**
 * We generate getters/setters/models, depending on the JSON model
 * Minimal manual work is required
*/
@AndroidJsonized('{ "aBoolean" : true }') class ABooleanJz {}
@AndroidJsonized('{ "anInteger" : 800 }') class ALongJz {}
@AndroidJsonized('{ "aFloat" : 800.01 }') class ADoubleJz {}
@AndroidJsonized('{ "aString" : "string" }') class AStringJz {}

@AndroidJsonized('{ "bString" : "string", "bFloat" : 800.00 }') class AHeterogenousObject {}

// NOTE: suffixed 'Parent' because of name collision TODO create test case
@AndroidJsonized('{ "anObjectWithAStringFirstJz" : { "aString" : "string" } }') class ATypeWithAStringParent {}

@AndroidJsonized('{
	"aDeepNesting0Jz" : {
		"aDeepNesting1Jz" : {
			"aDeepNesting2Jz" : {
				"aDeepNesting3Jz" : { "anInteger" : 4321 }
			}
		}
	}
}') class ATypeWithDeepNesting {}

@AndroidJsonized('{ "manyBooleans" : [ true, false, true ] }') class ManyBooleansParent {}
@AndroidJsonized('{ "manyIntegers" : [ 0, 1, 2 ] }') class ManyIntegersParent {}
@AndroidJsonized('{ "manyFloats" : [ 0.0, 1.1, 2.2 ] }') class ManyFloatsParent {}
@AndroidJsonized('{ "manyStrings" : [ "str0", "str1" ] }') class ManyStringsParent {}
@AndroidJsonized('{ "manyObjectsWithStringsFirst" : [ { "aString" : "string" } ] }') class ManyObjectsWithStringsParent {}

@AndroidJsonized('{
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

@AndroidJsonized('{
	"manyBooleans" : [ true, false, true ]
	, "manyIntegers" : [ 0, 1, 2 ]
	, "manyFloats" : [ 0.0, 1.1, 2.2 ]
	, "manyStrings" : [ "str0", "str1" ]
	, "manyObjectsWithStringsSecond" : [ { "aString" : "string" } ]
}') class VectorsTogether {}

@AndroidJsonized('{
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
//@AndroidJsonized("http://api.icndb.com/jokes/random") ChuckNorrisApi {}
// the http plumbing seems broken, besides the call is incomplete
// the VERB could be POST or something else (TODO add parameters)

@AndroidJsonized('{
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

// Looky here, there's a null-value
// "params": null
/*
@AndroidJsonized('{
    "textList": {
        "messages": [
            {
                "messageKey": "MESSAGE_KKAI106_04",
                "messageText": "Meh, nan anananan booo boo.",
                "messageType": "WARNING"
            }
        ],
        "texts": [
            {
                "id": "mobileAppsConfig_clothingline",
                "text": "VESTMENTS_DEFAULT",
		"params": null
            }
        ]
    }
}')
class WildernessResponse1 {}
*/

/*
@AndroidJsonized('{
    "texts": [
        {
            "id": "mobileAppsConfig_clothingline",
            "text": "VESTMENTS_DEFAULT",
            "@_this_will_totally_not_wor _@" : "params"
        }	
    ]
}')
class WildernessResponse2 {}
*/

class JsonizedTest {

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
	public def testBooleanVectorJson()
	{
		assertFalse(new ManyBooleansParent(new JSONObject('{ "manyBooleans" : [ true, false, true, false ] }')).getManyBooleans.get(3))
	}

	@Test
	public def testIntegerVectorJson()
	{
		assertTrue (new ManyIntegersParent(new JSONObject('{ "manyIntegers" : [ 0, 1, 2, 3, 4 ] }')).getManyIntegers.get(3) == 3)
	}

	@Test
	public def testFloatVectorJson()
	{
		assertTrue (new ManyFloatsParent(new JSONObject('{ "manyFloats" : [ 0.0, 1.0, 2.0, 3, 4.0 ] }')).getManyFloats.get(3) == 3.0f) // float === double?

	}

	@Test
	public def testStringVectorJson()
	{
		assertTrue (new ManyStringsParent(new JSONObject('{ "manyStrings" : [ "0", "1", "2", "3" ] }')).getManyStrings.get(3) .equals ("3"))

	}

	@Test
	public def testObjectVectorJson()
	{
		assertTrue (new ManyObjectsWithStringsParent(new JSONObject('{ "manyObjectsWithStringsFirst" : [ { "aString" : "string" } ] }')).getManyObjectsWithStringsFirst.get(0).getAString.equals("string"))
	}

//	@Test // TODO fix the http call
	public def testChuckNorrisHttpJson()
	{
		var randomQuote = '{ "type": "success", "value": { "id": 417, "joke": "meh", "categories": [] } }'
		//assertTrue(new ChuckNorrisApi(new JSONObject(randomQuote)).getValue.getJoke.equals("meh"))
	}

	@Test
	public def testTheOriginalExampleAtJsonizer()
	{
		assertTrue(new MusicReleases(new JSONObject(MusicReleases.input)).getQuery.getResults.getRelease.get(0).getUPC.equals("602527291567"))
	}

	// TODO do the other tests... like isDirty etc. getJSONObject

	@Test
	public def testsFromTheWilderness()
	{
//		new WildernessResponse1()
	}
}
