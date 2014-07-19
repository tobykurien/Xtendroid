package org.xtendroid.xtendroidtest.async

import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.Active
import android.content.Context
import android.content.AsyncTaskLoader

/**
 * 
 * To plug into the generated methods, match the signature of the desired method
 * to plugin to.
 * 
 */
@Active(AndroidLoaderProcessor)
@Target(ElementType.TYPE)
annotation AndroidLoader {
	val Class value
}

/**
 * 
 * TODO
 * 
 * - auto-generate Loader IDs and put them in the Activity/Fragment
 * - check if implements support or standard LoaderCallbacks or just plain LoaderCallback in case of multiple Loader pattern
 * - add convenience functions to start, restart, stop, convenience method calls to the (support) LoaderManager
 * - add callbacks to Activity client (make it so that the Activity client, can implement multiple AsyncTaskLoaders if need be)
 * - Research: hook on to ApplicationContext instead of the activity context, or rehook the same Loader instance to the Activity context, onConfigurationChanged or onCreate even.
 * - bonus: mTask is an instance of LoadTask is inherited from AsyncTaskLoader, now do this: mTask.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR), ha no reflection required
 */
class AndroidLoaderProcessor extends AbstractClassProcessor {
	override doRegisterGlobals(ClassDeclaration clazz, extension RegisterGlobalsContext context) {
		//		context.registerInterface(annotatedClass.qualifiedName + "_CallBacks")
	}

	override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {
	}
}

/**
 * 
 * Implementation inspiration from: http://www.androiddesignpatterns.com/2012/08/implementing-loaders.html
 * http://developer.android.com/reference/android/content/AsyncTaskLoader.html
 * http://grepcode.com/file/repository.grepcode.com/java/ext/com.google.android/android/4.0.1_r1/android/content/AsyncTaskLoader.java#AsyncTaskLoader.onLoadInBackground%28%29
 * 
 * This implementation will reuse old results, unless reset explicitly.
 * 
 * The lifetime of this BgLoader is bound to the lifecycle of the (Support)LoaderManager.
 * 
 */
class BgLoader<R> extends AsyncTaskLoader<R> {
	var ()=>R bgFunction
	var (R)=>void disposeFunction
	var R result

	new(Context context) {
		super(context)
	}
	
	new(Context context, ()=>R bg) {
		super(context)
		runInBg(bg, null)
	}
	
	new(Context context, ()=>R bg, (R)=>void dispose) {
		super(context)
		runInBg(bg, dispose)
	}
	
	def runInBg(()=>R bg, (R)=>void dispose) {
		bgFunction = bg
		disposeFunction = dispose
	}
	
	override protected onStartLoading() {
		super.onStartLoading()
		// send an old result back immediately
		if (result != null)
		{
			deliverResult(result)
		}

		// fetch new results
		if (takeContentChanged || result == null) {
			forceLoad	
		}
	}

	override loadInBackground() {
		return bgFunction.apply
	}
	
	override protected onStopLoading() {
		super.onStopLoading()
		cancelLoad
	}
	
	override protected onReset() {
		super.onReset()
		cancelLoad
	}
	
	/**
	 * 
	 * Final stop to guarantee
	 * your data has been obliterated
	 * 
	 */
	override onCanceled(R data) {
		super.onCanceled(data)
		if (disposeFunction != null)
		{
			if (data != null)
				disposeFunction.apply(data)
			if (result != null)
				disposeFunction.apply(result)
		}
	}
	
	override deliverResult(R data) {
		// onCanceled will obliterate all data
		if (isReset()) {
			return
		}
		
		// keep old reference
		val R oldData = result
		
		// reassign reference of new data
		result = data
		
		if (started)
			super.deliverResult(result)

		// obliterate old data
		if (disposeFunction != null)		
			disposeFunction.apply(oldData)
	}
	
}
