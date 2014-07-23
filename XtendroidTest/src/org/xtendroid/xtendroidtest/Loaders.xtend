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
		if (loader.id == LOADER_ANOTHER_THING_ID)
		{
			// do something
		}
	}

	override onLoaderReset(Loader loader) {
	}
}

// NOTE: the sequence of the annotations matter
@AndroidActivity(layout=R.layout.activity_main)
@AndroidLoader
class LoaderTestActivity2 extends android.app.Activity implements android.app.LoaderManager.LoaderCallbacks {

	var android.content.Loader<LoaderPayLoad> a = new android.content.Loader<LoaderPayLoad>(this)
	
	override onLoadFinished(android.content.Loader loader, Object data) {
	}

	override onLoaderReset(android.content.Loader loader) {
	}
	
}

@AndroidLoader
@AndroidFragment
class LoaderTestFragment1 extends android.support.v4.app.Fragment implements android.support.v4.app.LoaderManager.LoaderCallbacks {
	val BgLoader<LoaderPayLoad> something = new BgLoader<LoaderPayLoad>(this.activity, [|new LoaderPayLoad()], [])
	val BgLoader<LoaderPayLoad> anotherThing = new BgLoader<LoaderPayLoad>(this.activity, [|new LoaderPayLoad()], [])
	val BgLoader<LoaderPayLoad> babyThatsWhat = new BgLoader<LoaderPayLoad>(this.activity, [|new LoaderPayLoad()], [])
	
	override onLoadFinished(Loader arg0, Object arg1) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override onLoaderReset(Loader arg0) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
}

@AndroidLoader
@AndroidFragment
class LoaderTestFragment2 extends Fragment implements android.app.LoaderManager.LoaderCallbacks {
	var android.content.Loader<LoaderPayLoad> a = new android.content.Loader<LoaderPayLoad>(activity)
	var android.content.Loader<LoaderPayLoad> b = new android.content.Loader<LoaderPayLoad>(activity)
	
	override onLoadFinished(android.content.Loader loader, Object data) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override onLoaderReset(android.content.Loader loader) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}

