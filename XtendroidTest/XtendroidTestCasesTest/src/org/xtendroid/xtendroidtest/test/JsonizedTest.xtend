package org.xtendroid.xtendroidtest.test

import android.test.AndroidTestCase
import org.xtendroid.json.AndroidJsonized


/**
 * We generate getters/setters/models, depending on the JSON model
 * Minimal manual work is required
*/
@AndroidJsonized('{ "aBoolean" : true }') class ABoolean {}
@AndroidJsonized('{ "anInteger" : 800 }') class ALong {}
@AndroidJsonized('{ "aFloat" : 800.01 }') class ADouble {}
@AndroidJsonized('{ "aString" : "string" }') class AString {}

@AndroidJsonized('{ "bString" : "string", "bFloat" : 800.00 }') class AHeterogenousObject {}

// NOTE: suffixed 'Parent' because of name collision TODO create test case
@AndroidJsonized('{ "anObjectWithAStringFirst" : { "aString" : "string" } }') class AnObjectWithAStringParent {}

/*
@AndroidJsonized('{ "manyBooleans" : [ true, false, true ] }') class ManyBooleansParent {}
@AndroidJsonized('{ "manyIntegers" : [ 0, 1, 2 ] }') class ManyIntegersParent {}
@AndroidJsonized('{ "manyFloats" : [ 0.0, 1.1, 2.2 ] }') class ManyFloatsParent {}
@AndroidJsonized('{ "manyStrings" : [ "str0", "str1" ] }') class ManyStringsParent {}
@AndroidJsonized('{ "manyObjectsWithStringsFirst" : [ { "aString" : "string" } ] }') class ManyObjectsWithStringsParent {}
*/

@AndroidJsonized('{
	"aBoolean" : true
	, "anInteger" : 800
	, "aFloat" : 800.00
	, "aString" : "string"
	, "anObjectWithAStringSecond" : { "aString" : "string" }
}') class ScalarsTogether {}

/*
@AndroidJsonized('{
	, "manyBooleans" : [ true, false, true ]
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
*/

class JsonizedTest extends AndroidTestCase {
	def testJson() {

	}
}
