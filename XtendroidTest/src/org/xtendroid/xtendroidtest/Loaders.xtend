package org.xtendroid.xtendroidtest

import org.xtendroid.app.AndroidActivity
import org.xtendroid.xtendroidtest.R
import android.app.LoaderManager.LoaderCallbacks
import android.os.Bundle
import android.content.Loader
import org.xtendroid.annotations.AndroidLoader
import org.xtendroid.utils.BgLoader
import org.xtendroid.parcel.AndroidParcelable
import android.os.Parcelable

@AndroidParcelable
class LoaderPayLoad implements Parcelable
{
	String a
	String b
	String c
}

// NOTE: the sequence of the annotations matter
@AndroidLoader
@AndroidActivity(layout=R.layout.activity_main)
class LoaderTestActivity1 implements LoaderCallbacks {
	
	val something     = new BgLoader<LoaderPayLoad>(this, [], [])
	val anotherThing  = new BgLoader<LoaderPayLoad>(this, [], [])
	val babyThatsWhat = new BgLoader<LoaderPayLoad>(this, [], [])
	
	override onLoadFinished(Loader loader, Object data) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override onLoaderReset(Loader loader) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override onCreateLoader(int id, Bundle args) {
		
	}
	
}

// NOTE: the sequence of the annotations matter
@AndroidActivity(layout=R.layout.activity_main)
@AndroidLoader
class LoaderTestActivity2 extends android.app.Activity implements LoaderCallbacks {
	
	val something     = new BgLoader<LoaderPayLoad>(this, [], [])
	val anotherThing  = new BgLoader<LoaderPayLoad>(this, [], [])
	val babyThatsWhat = new BgLoader<LoaderPayLoad>(this, [], [])
	
	override onLoadFinished(Loader loader, Object data) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override onLoaderReset(Loader loader) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override onCreateLoader(int id, Bundle args) {
		return getLoaderObject(id, args)
	}
	
}

@AndroidLoader
class Meh {
	
}