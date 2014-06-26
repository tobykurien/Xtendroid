package org.xtendroid.xtendroidtest.parcel

import org.xtendroid.parcel.AndroidParcelable
import android.os.Parcelable
import org.xtendroid.parcel.Parcelize

@AndroidParcelable
class PojoParcelableTest implements Parcelable {
	@Parcelize @Property int i
	@Parcelize @Property int j = 0
	@Property int k
	@Property int l = 123412341
	@Parcelize @Property boolean m = true
	@Parcelize @Property Boolean n = true
	@Property Double o = 1.0
	Double p = 1.0
}

// TODO enum tests
//@AndroidParcelable
//enum JavaEnum
//{
//	
//}