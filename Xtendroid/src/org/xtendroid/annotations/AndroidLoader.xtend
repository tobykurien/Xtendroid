package org.xtendroid.annotations

import android.app.Activity
import android.os.Bundle
import android.support.v4.app.Fragment
import android.support.v4.app.FragmentActivity
import android.support.v4.app.LoaderManager
import android.support.v4.content.Loader
import android.view.View
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static extension org.xtendroid.utils.NamingUtils.*

/**
 * 
 * TODO
 * 
 * - Research: hook on to ApplicationContext instead of the activity context, or rehook the same Loader instance to the Activity context, onConfigurationChanged or onCreate even.
 */
@Active(AndroidLoaderProcessor)
@Target(ElementType.TYPE)
annotation AndroidLoader {
}

class AndroidLoaderProcessor extends AbstractClassProcessor {

	def String getLoaderIdFromName(String chars) {
		return 'LOADER_' + chars.toResourceName.toUpperCase + '_ID'
	}

	override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {

		// check if extends (support) LoaderCallbacks
		val mandatoryCallbackTypes = #['android.app.LoaderManager$LoaderCallbacks',
			'android.support.v4.app.LoaderManager$LoaderCallbacks']
		val callbackInterface = clazz.implementedInterfaces.findFirst[i|i.simpleName.contains('LoaderCallbacks')]
		if (callbackInterface == null) {
			clazz.addError(
				String.format("You must implement a LoaderCallbacks interface, either %s",
					mandatoryCallbackTypes.join(' or ')))
		}

		// we need at least one loader in the field
		val mandatoryLoaderTypes = #['android.content.Loader', 'android.support.v4.content.Loader']
		val loaderFields = clazz.declaredFields.filter[f|
			!f.type.inferred && f.initializer != null && (
			android.content.Loader.newTypeReference.isAssignableFrom(f.type) ||
				Loader.newTypeReference.isAssignableFrom(f.type)
		)]
		
		if (loaderFields.size == 0) {
			clazz.declaredFields.filter[f|f.type.inferred].forEach[f|
				f.addWarning(
					"To make the @AndroidLoader annotation recognize your Loader fields," +
						"\nyou must declare the Loader type on the left hand side of the field expression.")]
			clazz.addError(
				String.format("You must declare Loaders of these types in the fields: %s",
					mandatoryLoaderTypes.join(', ')))
		}
		
		val loaderFieldNames = loaderFields.map[simpleName]

		// check if you are using the correct types
		// TODO rethink this check, if the user wants to shoot herself in the foot..., BgLoader is done with support
		val usingSupportCallbacks = clazz.implementedInterfaces.exists[i|
			LoaderManager.LoaderCallbacks.newTypeReference.isAssignableFrom(i)]
		val usingSupportLoaders = loaderFields.exists[f|
			Loader.newTypeReference.isAssignableFrom(f.type)]
		if (!usingSupportCallbacks && usingSupportLoaders || usingSupportCallbacks && !usingSupportLoaders) {
			val warning = String.format(
				"Don't mix support version and the standard version of Loaders (support:%s) and LoaderCallbacks (support:%s)",
				Boolean.valueOf(usingSupportLoaders), Boolean.valueOf(usingSupportCallbacks))
			loaderFields.filter[f|
				usingSupportCallbacks && Loader.newTypeReference.isAssignableFrom(f.type)].
				forEach[f|f.addError(warning)]
		}

		// generate ID tags with random numbers for each Loader
		val className = clazz.simpleName // this was added to decrease the chance of collisions (but there are no guarantees)
		val randomInitialInt = loaderFields.map[f|className + f.simpleName].join().bytes.fold(0 as int,
			[_1, _2|_1 as int + _2 as int])

		for (var i = 0; i < loaderFields.length; i++) {
			val int integer = i + randomInitialInt * (i + 1)
			val f = loaderFields.get(i)
			clazz.addField(f.simpleName.loaderIdFromName) [
				final = true
				static = true
				type = int.newTypeReference
				initializer = ['''«integer»''']
			]
		}

		// neither an Activity nor Fragment
		if (clazz.extendedClass.equals(Object.newTypeReference)) {
			clazz.addWarning("Currently the use-case beyond Activity/Fragment is out-of-scope.")
			return; // get out, you're on your own
		}

		// Determine that clazz is an Activity or support.v4.app.Fragment or app.Fragment
		// and try to call initLoaders, where they should be called.
		var isTypeActivity = false;
		var isTypeFragment = false;
		val fragmentWarning = "The initLoaders method must be invoked from the onViewCreated or the onActivityCreated method.\n" +
			"The initLoaders method must be invoked after the views are inflated, or expect crashes when the LoaderCallback attempts to access views."
		if (Activity.newTypeReference.isAssignableFrom(clazz.extendedClass)) {
			val onCreateMethod = clazz.findDeclaredMethod('onCreate')
			if (onCreateMethod != null) {
				onCreateMethod.addWarning(
					"The initLoaders method must be invoked here.\n" +
						"After the setContentView method is called, or expect crashes when the LoaderCallback attempts to access views.\n" +
						"Pro tip: use the @OnCreate annotation, to call initLoaders method.")
			}

			// TODO figure out a way to use @AndroidActivity's onCreate injection mechanism
			// NOTE: this is especially hard when I cannot (read: know not how) modify the expression of a method body
			// that is already set.
			isTypeActivity = true
		} else if (Fragment.newTypeReference.isAssignableFrom(clazz.extendedClass) ||
			android.app.Fragment.newTypeReference.isAssignableFrom(clazz.extendedClass)) {
			val onViewCreatedMethod = clazz.findDeclaredMethod('onViewCreated')
			val onActivityCreatedMethod = clazz.findDeclaredMethod('onActivityCreated')
			val onStartMethod = clazz.findDeclaredMethod('onStart')
			
			// try this one first
			if (onStartMethod == null)
			{
				clazz.addMethod('onStart') [
					addAnnotation(Override.newAnnotationReference)
					returnType = void.newTypeReference
					body = [
						'''
							super.onStart();
							initLoaders();
						''']
				]
			}else if (onActivityCreatedMethod == null)
			{
				clazz.addMethod('onActivityCreated') [
					addAnnotation(Override.newAnnotationReference)
					addParameter("savedInstanceState", Bundle.newTypeReference)
					returnType = void.newTypeReference
					body = [
						'''
							super.onActivityCreated(savedInstanceState);
							initLoaders();
						''']
				]
			// try the next best
			}else if (onViewCreatedMethod == null) {
				clazz.addMethod('onViewCreated') [
					addAnnotation(Override.newAnnotationReference)
					addParameter("view", View.newTypeReference)
					addParameter("savedInstanceState", Bundle.newTypeReference)
					returnType = void.newTypeReference
					body = [
						'''
							super.onViewCreated(view, savedInstanceState);
							initLoaders();
						''']
				]
			}else
			{
				onViewCreatedMethod.addWarning(fragmentWarning)
				onActivityCreatedMethod.addWarning(fragmentWarning)
			}
			isTypeFragment = true
		}

		val support = if(usingSupportCallbacks) "Support" else ''

		var String initString = '''
			// (re)load Loader result
			«IF isTypeFragment»
				final LoaderManager lm = getActivity().get«support»LoaderManager();
			«ELSE»
				final LoaderManager lm = get«support»LoaderManager();
			«ENDIF»
		'''

		for (n : loaderFieldNames) {
			initString += '''
				if (lm.getLoader(«n.loaderIdFromName») == null)
				{
					lm.initLoader(«n.loaderIdFromName», null, (%s) this);
				}
			'''
		}
		
		if (usingSupportCallbacks && isTypeActivity) {
			if (!FragmentActivity.newTypeReference.isAssignableFrom(clazz.extendedClass))
				clazz.addError(
					"Your Activity type must extend android.support.v4.app.FragmentActivity, to use android.app.LoaderManager$LoaderCallbacks")
		}

		// add initLoaders method
		val String _initString = initString.toString
		clazz.addMethod("initLoaders") [
			returnType = void.newTypeReference
			body = [
				_initString.toString.replaceAll("%s", toJavaCode(callbackInterface))
			]
		]
		
		val onCreateLoaderMethodBody = loaderFieldNames.map[n|
							String.format("if (%s == LOADER_ID) return get%sLoader();", n.loaderIdFromName,
								n.toJavaIdentifier.toFirstUpper)].join("\n")

		// if multiple Loaders then no generic param
		// if single then generic param,
		// this design works regardlessly at the cost of boilerplate casts
		// or more boilerplate: one LoaderCallbacks instance per Loader...
		
		// if onCreateLoader method does not exist then create it
		val onCreateLoaderMethod = clazz.declaredMethods.findFirst[m|m.simpleName.equals('onCreateLoader')]
		val existsOnCreateLoader = onCreateLoaderMethod != null
		if (!existsOnCreateLoader) {
			clazz.addMethod("onCreateLoader") [
				addParameter("LOADER_ID", int.newTypeReference)
				addParameter("args", Bundle.newTypeReference)
				addAnnotation(Override.newAnnotationReference)
				returnType = if (usingSupportCallbacks)
					Loader.newTypeReference
				else
					android.content.Loader.newTypeReference
				visibility = Visibility.PUBLIC
				body = [
					'''
						«onCreateLoaderMethodBody»
						return null;
					''']
			]
		} else /*if (existsOnCreateLoader)*/ {
			onCreateLoaderMethod.addWarning(
				'You must return the Loader objects here, you may use the getLoaderObject synthetic method.')
			clazz.addMethod('getLoaderObject') [
				addParameter("LOADER_ID", int.newTypeReference)
				addParameter("args", Bundle.newTypeReference)
				returnType = if (usingSupportCallbacks)
					Loader.newTypeReference
				else
					android.content.Loader.newTypeReference
				visibility = Visibility.PRIVATE
				body = [
					'''
						«onCreateLoaderMethodBody»
						return null;
					''']
			]
		}

		// add getters for Loaders (NOTE: workaround/hack, because I don't know how to evaluate initializer exprs)
		loaderFields.forEach [ f |
			clazz.addMethod("get" + f.simpleName.toJavaIdentifier.toFirstUpper + "Loader") [
				visibility = Visibility.PUBLIC
				body = f.initializer
				returnType = f.type
				primarySourceElement = f.primarySourceElement
			]
		]

		// remove useless fields
		clazz.declaredFields.filter[f|
			!f.type.inferred && f.initializer == null && (
				android.content.Loader.newTypeReference.isAssignableFrom(f.type) ||
				Loader.newTypeReference.isAssignableFrom(f.type)
			)].forEach[remove]
	}
}
