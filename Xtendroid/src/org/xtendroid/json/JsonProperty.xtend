package org.xtendroid.json

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.Active

/**
 * @JsonProperty annotation creates a "Json bean" that accepts a JSONObject
 * and then parses it on-demand with getters.
 * 
 * @deprecated Use @AndroidJson instead, does the same thing, and more
 */
@Active(AndroidJsonProcessor)
@Target(ElementType.FIELD)
annotation JsonProperty {
	// Use this to explicitly state the key value (String) of the JSON Object
	// and define the expected String for DateFormat for Date fields
	String value = ""
}