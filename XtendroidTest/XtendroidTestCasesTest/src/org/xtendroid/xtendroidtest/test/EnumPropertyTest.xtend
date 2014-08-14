package org.xtendroid.xtendroidtest.test

import android.test.AndroidTestCase
import org.xtendroid.annotations.EnumProperty

class EnumPropertyTest extends AndroidTestCase {
	enum AbcEnum {
		a, b, c
	}
	
//	@EnumProperty(enumType=AbcEnum)
//	String alpha
	
	@EnumProperty(name="GroupEnum", values=#["Baby", "Toddler", "Child", "Adult", "Senior"]) 
	String group
	
	def testEnum() {
		group = GroupEnum.Baby.toString
		assertEquals(group, "Baby")
		assertEquals(GroupEnum.Baby, GroupEnum.toGroupEnumValue(group))
		//assertNull(GroupEnum.toGroupEnumValue("Juvenile"))
	}
}