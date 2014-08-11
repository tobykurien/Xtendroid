package org.xtendroid.xtendroidtest

import android.app.Activity
import android.app.Fragment
import android.app.LoaderManager
import android.content.Loader
import android.os.Parcelable
import android.support.v4.app.FragmentActivity
import org.xtendroid.annotations.AndroidFragment
import org.xtendroid.annotations.AndroidLoader
import org.xtendroid.app.AndroidActivity
import org.xtendroid.parcel.AndroidParcelable
import org.xtendroid.utils.BgLoader

@AndroidParcelable
class LoaderPayLoad implements Parcelable {
	String a
	String b
	String c
}

// NOTE: the sequence of the annotations matter
@AndroidLoader
@AndroidActivity(layout=R.layout.activity_bundle)
class LoaderTestActivity0 extends FragmentActivity implements android.support.v4.app.LoaderManager.LoaderCallbacks {
	var BgLoader<LoaderPayLoad> something = new BgLoader<LoaderPayLoad>(this, [|new LoaderPayLoad()], [])
	var BgLoader<LoaderPayLoad> anotherThing = new BgLoader<LoaderPayLoad>(this, [|new LoaderPayLoad()], [])
	var BgLoader<LoaderPayLoad> babyThatsWhat = new BgLoader<LoaderPayLoad>(this, [|new LoaderPayLoad()], [])

	override onLoadFinished(android.support.v4.content.Loader loader, Object data) {
		if (loader.id == LOADER_ANOTHER_THING_ID)
		{
			// do something
		}
	}

	override onLoaderReset(android.support.v4.content.Loader loader) {
	}
}

// NOTE: the sequence of the annotations matter
@AndroidLoader
@AndroidActivity(layout=R.layout.activity_bundle)
class LoaderTestActivity1 extends FragmentActivity implements android.support.v4.app.LoaderManager.LoaderCallbacks {
	var BgLoader<LoaderPayLoad> something = new BgLoader<LoaderPayLoad>(this, [|new LoaderPayLoad()], [])
	var BgLoader<LoaderPayLoad> anotherThing = new BgLoader<LoaderPayLoad>(this, [|new LoaderPayLoad()], [])
	var BgLoader<LoaderPayLoad> babyThatsWhat = new BgLoader<LoaderPayLoad>(this, [|new LoaderPayLoad()], [])

	override onLoadFinished(android.support.v4.content.Loader loader, Object data) {
		if (loader.id == LOADER_ANOTHER_THING_ID)
		{
			// do something
		}
	}

	override onLoaderReset(android.support.v4.content.Loader loader) {
	}
}


// NOTE: the sequence of the annotations matter
@AndroidActivity(layout=R.layout.activity_bundle)
@AndroidLoader
class LoaderTestActivity2 extends Activity implements LoaderManager.LoaderCallbacks {

	var Loader<LoaderPayLoad> a = new Loader<LoaderPayLoad>(this)
	
	override onLoadFinished(Loader loader, Object data) {
	}

	override onLoaderReset(Loader loader) {
	}
	
}

@AndroidLoader
@AndroidFragment
class LoaderTestFragment1 extends android.support.v4.app.Fragment implements android.support.v4.app.LoaderManager.LoaderCallbacks {
	val BgLoader<LoaderPayLoad> something = new BgLoader<LoaderPayLoad>(this.activity, [|new LoaderPayLoad()], [])
	val BgLoader<LoaderPayLoad> anotherThing = new BgLoader<LoaderPayLoad>(this.activity, [|new LoaderPayLoad()], [])
	val BgLoader<LoaderPayLoad> babyThatsWhat = new BgLoader<LoaderPayLoad>(this.activity, [|new LoaderPayLoad()], [])
	
	override onLoadFinished(android.support.v4.content.Loader arg0, Object arg1) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override onLoaderReset(android.support.v4.content.Loader arg0) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
}

@AndroidLoader
@AndroidFragment
class LoaderTestFragment2 extends Fragment implements LoaderManager.LoaderCallbacks {
	var Loader<LoaderPayLoad> a = new Loader<LoaderPayLoad>(activity)
	var Loader<LoaderPayLoad> b = new Loader<LoaderPayLoad>(activity)
	
	override onLoadFinished(Loader loader, Object data) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override onLoaderReset(Loader loader) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}

