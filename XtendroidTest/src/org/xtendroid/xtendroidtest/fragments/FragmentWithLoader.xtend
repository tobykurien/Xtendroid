package org.xtendroid.xtendroidtest.fragments

import android.app.LoaderManager.LoaderCallbacks
import android.content.Loader
import android.os.Bundle
import org.xtendroid.annotations.AndroidFragment
import org.xtendroid.annotations.AndroidLoader
import org.xtendroid.app.OnCreate
import org.xtendroid.utils.BgLoader
import org.xtendroid.xtendroidtest.R

//@AndroidLoader
@AndroidFragment(R.layout.fragment_test) 
class FragmentWithLoader implements LoaderCallbacks<String> {
	var BgLoader<String> loader

	@OnCreate
	def init() {
		loader = new BgLoader<String>(activity, [|
				Thread.sleep(5000)
				"Return value from loader"
			], [
			])		
		
		fragText.text = "Fragment loading value..."
	}
	
	override onCreateLoader(int id, Bundle args) {
	}
	
	override onLoaderReset(Loader<String> arg0) {
	}
	
	override onLoadFinished(Loader<String> arg0, String result) {
		fragText.text = result
	}
	
}