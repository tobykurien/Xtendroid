package org.xtendroid.xtendroidtest.fragments

import android.support.v4.app.LoaderManager.LoaderCallbacks
import android.support.v4.content.Loader
import org.xtendroid.annotations.AndroidFragment
import org.xtendroid.app.OnCreate
import org.xtendroid.utils.BgSupportLoader
import org.xtendroid.xtendroidtest.R
import org.xtendroid.annotations.AndroidLoader
import android.support.v4.app.Fragment

@AndroidLoader
@AndroidFragment (R.layout.fragment_test) 
class FragmentWithLoader extends Fragment implements LoaderCallbacks<String> {
	BgSupportLoader<String> superFantasticLoader = new BgSupportLoader<String>(activity, [|
				Thread.sleep(5000)
				"Return value from loader"
			], [
			])

	@OnCreate
	def init() {
		fragText.text = "Fragment loading value..."
	}
	
	override onLoaderReset(Loader<String> arg0) {
	}
	
	override onLoadFinished(Loader<String> arg0, String result) {
		fragText.text = result
	}
}
