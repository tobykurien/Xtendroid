package org.xtendroid.xtendroidtest.loaders

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
import org.xtendroid.utils.BgSupportLoader
import org.xtendroid.xtendroidtest.R
import org.xtendroid.app.OnCreate

import org.xtendroid.xtendroidtest.loaders.LoaderPayLoad

@AndroidParcelable
class LoaderPayLoad implements Parcelable {
	String a
	String b
	String c

	//new () {}
}

// NOTE: the sequence of the annotations matter
@AndroidLoader
@AndroidActivity(layout=R.layout.activity_bundle)
class LoaderTestActivity0 extends FragmentActivity implements android.support.v4.app.LoaderManager.LoaderCallbacks {
	var BgSupportLoader<LoaderPayLoad> something = new BgSupportLoader<LoaderPayLoad>(this, [|new LoaderPayLoad], [])
	var BgSupportLoader<LoaderPayLoad> anotherThing = new BgSupportLoader<LoaderPayLoad>(this, [|new LoaderPayLoad], [])
	var BgSupportLoader<LoaderPayLoad> babyThatsWhat = new BgSupportLoader<LoaderPayLoad>(this, [|new LoaderPayLoad], [])

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
	var BgSupportLoader<LoaderPayLoad> something = new BgSupportLoader<LoaderPayLoad>(this, [|new LoaderPayLoad], [])
	var BgSupportLoader<LoaderPayLoad> anotherThing = new BgSupportLoader<LoaderPayLoad>(this, [|new LoaderPayLoad], [])
	var BgSupportLoader<LoaderPayLoad> babyThatsWhat = new BgSupportLoader<LoaderPayLoad>(this, [|new LoaderPayLoad], [])

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
	val BgSupportLoader<LoaderPayLoad> something = new BgSupportLoader<LoaderPayLoad>(this.activity, [|new LoaderPayLoad], [])
	val BgSupportLoader<LoaderPayLoad> anotherThing = new BgSupportLoader<LoaderPayLoad>(this.activity, [|new LoaderPayLoad], [])
	val BgSupportLoader<LoaderPayLoad> babyThatsWhat = new BgSupportLoader<LoaderPayLoad>(this.activity, [|new LoaderPayLoad], [])
	
	override onLoadFinished(android.support.v4.content.Loader arg0, Object arg1) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override onLoaderReset(android.support.v4.content.Loader arg0) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
}

@AndroidLoader
@AndroidFragment(R.layout.fragment_test)
class LoaderTestFragment2 extends Fragment implements LoaderManager.LoaderCallbacks {
	var Loader<LoaderPayLoad> a = new Loader<LoaderPayLoad>(activity)
	var Loader<LoaderPayLoad> b = new Loader<LoaderPayLoad>(activity)
	
	@OnCreate
	def bogus()
	{
		// something
	}
	
	
	override onLoadFinished(Loader loader, Object data) {
		fragText.text = "something really fun"
	}
	
	override onLoaderReset(Loader loader) {
	}
}

@AndroidLoader
@AndroidFragment(R.layout.fragment_test)
class LoaderTestFragment3 extends Fragment implements LoaderManager.LoaderCallbacks<String> {
	val BgLoader<String> something = new BgLoader<String>(this.activity, [| "some string" ], [])
	
	@OnCreate
	def bogus()
	{
		// something
	}
	
	override onLoadFinished(Loader loader, String data) {
		fragText.text = data
	}
	
	override onLoaderReset(Loader loader) {
	}
}
