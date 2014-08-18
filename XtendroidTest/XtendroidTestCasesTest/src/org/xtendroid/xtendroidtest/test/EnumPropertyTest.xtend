package org.xtendroid.xtendroidtest.test

import android.test.AndroidTestCase
import org.xtendroid.annotations.EnumProperty

enum AbcEnum {
	a, b, c
}

class EnumPropertyTest extends AndroidTestCase {
	
	@EnumProperty(enumType=AbcEnum)
	String alpha
	
	@EnumProperty(name="GroupEnum", values=#["Baby", "Toddler", "Child", "Adult", "Senior"]) 
	String group
	
	def testEnum() {
		group = GroupEnum.Baby.toString
		assertEquals(group, "Baby")
		assertEquals(GroupEnum.Baby, GroupEnum.toGroupEnumValue(group))
		assertNotNull(GroupEnum.toGroupEnumValue("Juvenile"))
	}
}