package org.xtendroid.xtendroidtest

import org.xtendroid.app.AndroidActivity
import org.xtendroid.xtendroidtest.R
import android.os.Bundle
//import android.content.Loader
import org.xtendroid.parcel.AndroidParcelable
import android.os.Parcelable
import org.xtendroid.utils.BgLoader
import org.xtendroid.annotations.AndroidLoader
import android.app.Activity
import org.xtendroid.annotations.AndroidFragment
import android.app.Fragment
import android.support.v4.app.FragmentActivity
import android.support.v4.app.LoaderManager.LoaderCallbacks
import android.support.v4.content.Loader
import android.app.LoaderManager

@AndroidParcelable
class LoaderPayLoad implements Parcelable {
	String a
	String b
	String c
}

// NOTE: the sequence of the annotations matter
@AndroidLoader
@AndroidActivity(layout=R.layout.activity_main)
class LoaderTestActivity1 extends FragmentActivity implements android.support.v4.app.LoaderManager.LoaderCallbacks {
	var BgLoader<LoaderPayLoad> something = new BgLoader<LoaderPayLoad>(this, [|new LoaderPayLoad()], [])
	var BgLoader<LoaderPayLoad> anotherThing = new BgLoader<LoaderPayLoad>(this, [|new LoaderPayLoad()], [])
	var BgLoader<LoaderPayLoad> babyThatsWhat = new BgLoader<LoaderPayLoad>(this, [|new LoaderPayLoad()], [])

	override onLoadFinished(Loader loader, Object data) {
	}

	override onLoaderReset(Loader loader) {
	}

}

// NOTE: the sequence of the annotations matter
@AndroidActivity(layout=R.layout.activity_main)
@AndroidLoader
class LoaderTestActivity2 extends android.app.Activity implements android.app.LoaderManager.LoaderCallbacks {

	var BgLoader<LoaderPayLoad> something //= new BgLoader<LoaderPayLoad>(this, [|new LoaderPayLoad()], [])
	var BgLoader<LoaderPayLoad> anotherThing //= new BgLoader<LoaderPayLoad>(this, [|new LoaderPayLoad()], [])
	var BgLoader<LoaderPayLoad> babyThatsWhat //= new BgLoader<LoaderPayLoad>(this, [|new LoaderPayLoad()], [])

	override onLoadFinished(Loader loader, Object data) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override onLoaderReset(Loader loader) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
}
//
//@AndroidLoader
//@AndroidFragment
//class LoaderTestFragment1 extends Fragment {
//	val BgLoader<LoaderPayLoad> something = new BgLoader<LoaderPayLoad>(this.activity, [|new LoaderPayLoad()], [])
//	val BgLoader<LoaderPayLoad> anotherThing = new BgLoader<LoaderPayLoad>(this.activity, [|new LoaderPayLoad()], [])
//	val BgLoader<LoaderPayLoad> babyThatsWhat = new BgLoader<LoaderPayLoad>(this.activity, [|new LoaderPayLoad()], [])
//}
//
//@AndroidLoader
//@AndroidFragment
//class LoaderTestFragment2 extends Fragment {
//	val BgLoader<LoaderPayLoad> something = new BgLoader<LoaderPayLoad>(this.activity, [|new LoaderPayLoad()], [])
//	val BgLoader<LoaderPayLoad> anotherThing = new BgLoader<LoaderPayLoad>(this.activity, [|new LoaderPayLoad()], [])
//	val BgLoader<LoaderPayLoad> babyThatsWhat = new BgLoader<LoaderPayLoad>(this.activity, [|new LoaderPayLoad()], [])
//}

