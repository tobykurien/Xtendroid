package org.xtendroid.xtendroidtest.test

import android.test.AndroidTestCase
import org.xtendroid.json.AndroidJsonized
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
	, "anObjectWithAStringSecond" : { "aString" : "string" }
	, "manyBooleans" : [ true, false, true ]
	, "manyIntegers" : [ 0, 1, 2 ]
	, "manyFloats" : [ 0.0, 1.1, 2.2 ]
	, "manyStrings" : [ "str0", "str1" ]
	, "manyObjectsWithStringsSecond" : [ { "aString" : "string" } ]
}') class EverythingTogether {}

// TODO write test case that checks that_this_is_a_good_member // snake case
// TODO write test case that checks type name collisions, and gives a warning?
// Add (randomized? overkill?) version number to prevent name collision.

class JsonizedTest extends AndroidTestCase {
	def testScalarJson() {
		/*
		// TODO make this stable
		assertTrue(new ABoolean(new JSONObject('{ "aBoolean" : true }')).aBoolean)
		assertTrue(new ALong(new JSONObject('{ "anInteger" : 800 }')).anInteger == 800)
		*/
	}
}
