package org.xtendroid.xtendroidtest.fragments

import android.support.v4.app.Fragment
import android.support.v4.app.LoaderManager.LoaderCallbacks
import android.support.v4.content.Loader
import org.xtendroid.annotations.AndroidFragment
import org.xtendroid.annotations.AndroidLoader
import org.xtendroid.app.OnCreate
import org.xtendroid.xtendroidtest.R
import static extension org.xtendroid.utils.BgSupportLoader.*

@AndroidLoader
@AndroidFragment (R.layout.fragment_test) 
class FragmentWithLoader extends Fragment implements LoaderCallbacks<String> {
	var Loader superFantasticLoader

	@OnCreate
	def init() {
		fragText.text = "Fragment loading value..."
		superFantasticLoader = <String>supportLoader(activity) [
			Thread.sleep(5000)
			"Return value from loader"
		]
	}
	
	override onLoaderReset(Loader<String> arg0) {
	}
	
	override onLoadFinished(Loader<String> arg0, String result) {
		fragText.text = result
	}
}
