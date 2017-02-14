package org.xtendroid.xtendroidtest.fragments

import org.xtendroid.annotations.AndroidFragment
import org.xtendroid.annotations.AndroidLoader
import org.xtendroid.app.OnCreate
import org.xtendroid.utils.BgSupportLoader
import org.xtendroid.xtendroidtest.R

import static org.xtendroid.utils.BgSupportLoader.*
import android.content.Loader
import android.app.Fragment

@AndroidLoader
@AndroidFragment (R.layout.fragment_test)
class FragmentWithLoader extends Fragment implements android.app.LoaderManager.LoaderCallbacks<String> {
	var BgSupportLoader superFantasticLoader

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
