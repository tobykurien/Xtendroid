package org.xtendroid.utils

import android.support.v4.content.AsyncTaskLoader
import android.content.Context
import android.app.Activity

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
 * If you don't want to use the support AsyncTaskLoader, then just change the import.
 */
class BgSupportLoader<R> extends AsyncTaskLoader<R> {
	var ()=>R bgFunction
	var (R)=>void disposeFunction
	protected var R result

	// Type-safety is thrown out of the window for convenience
	public static def BgSupportLoader<Object> loaderSupport(Activity context, ()=>Object bg, (Object)=>void dispose)
	{
		return new BgSupportLoader<Object>(context, bg, dispose)
	}

	// 'defenestrated' comes to mind
	public static def BgSupportLoader<Object> loaderSupport(Activity context, ()=>Object bg)
	{
		return new BgSupportLoader<Object>(context, bg)
	}

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
		else if (takeContentChanged || result == null) {
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

class BgLoader<R> extends android.content.AsyncTaskLoader<R> {
	var ()=>R bgFunction
	var (R)=>void disposeFunction
	protected var R result

	// Type-safety is thrown out of the window for convenience
	public static def BgLoader<Object> loader(Activity context, ()=>Object bg, (Object)=>void dispose)
	{
		return new BgLoader<Object>(context, bg, dispose)
	}

	// 'defenestrated' comes to mind
	public static def BgLoader<Object> loader(Activity context, ()=>Object bg)
	{
		return new BgLoader<Object>(context, bg)
	}

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
		else if (takeContentChanged || result == null) {
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
