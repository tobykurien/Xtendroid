Xtendroid
=========

Xtendroid is an Android library that combines the power of [Xtend][] 
(think: CoffeeScript for Java) with some utility classes/annotations for productive Android development. With Xtendroid, 
you can spend a lot less time writing boilerplate code and benefit from the tooling support 
provided by the Xtend framework. Xtendroid is based on the convention-over-configuration 
philosophy, so resources in Android map automatically to Java getters and setters by name 
(CamelCase to resource_name mapping).

Introduction
------------

If you display toasts often, you know that typing out Toast.makeText... is a pain, and it's not easy to add it to a base class, since Activities may extend multiple base classes (like ListActivity, FragmentActivity, etc.) Here's the easy way using Xtendroid:

```xtend
import static extension org.xtendroid.utils.AlertUtils.*

// elsewhere
toast("My short message")
toastLong("This message displays for longer")
```

Where is the reference to the Context object? It is implicit, thanks to Xtend:

```xtend
// this:
toast(context, "My message")

// is equivalent to:
context.toast("My message")

// which, in an Activity is the same as:
this.toast("My message")

// But "this" is implicit, so we can shorten it to:
toast("My message")
```

The above magic, as well as the mix-in style ability of the "import static extension" of Xtend, is used to great effect in Xtendroid. 

In addition, Xtendroid implements several [Active Annotations][] (think of them as code generators) which remove most of the boilerplate-code that's associated with Android development. Here's an example of one of the most powerful Xtendroid annotations, ```@AndroidActivity```, which automatically extends the ```Activity``` class, loads the layout into the activity, parses the specified layout file, and creates getters/setters for each of the views contained there-in, at **edit-time** (not compile-time or runtime)! Once everything is ready, the method annotated with ```@OnCreate``` is called, to set up your views, although as with everything in Xtendroid, you are free to implement the ```onCreate()``` method yourself.

```xtend
@AndroidActivity(R.layout.my_activity) class MyActivity {

	@OnCreate
	def init(Bundle savedInstanceState) {
		myTextView.text = "some text"
	}

}
``` 

View this video of how this works and how well it integrates with the IDE: http://vimeo.com/77024959

Xtendroid combines extension methods, active annotations, and convention-over-configuration (convention-over-code) to provide you with a highly productive environment for Android development, where you are still writing standard Android code, but without boilerplate code.

Documentation
-------------

View the documentation [here](/Xtendroid/docs/index.md).

Samples
-------

There are several examples in the examples folder: https://github.com/tobykurien/Xtendroid/tree/master/examples

For an example of a live project that uses this library, see the Webapps project https://github.com/tobykurien/webapps

Getting Started
===============

Method 1:
---------
- Download the latest release from https://github.com/tobykurien/Xtendroid/tree/master/Xtendroid/release
- Copy the JAR file into your Android project's `libs` folder
- If you are using an existing or new Android project:
-- Right-click on your project -> Properties -> Java Build Path 
-- Click Libraries -> Add library -> Xtend Library
- Now you can use it as shown in the examples above.


Method 2:
---------
- Git clone this repository and import it using Eclipse. 
- Add it as a library project to your Android project:
-- Right-click your project -> Properties -> Android -> (Library) Add -> Xtendroid
- If you are using an existing or new Android project:
-- Right-click on your project -> Properties -> Java Build Path 
-- Click Libraries -> Add library -> Xtend Library
- Now you can use it as shown in the examples above.

Xtend
=====

For more about the Xtend language, see http://xtend-lang.org

Gotchas
=======

There are currently some bugs with the Xtend editor that can lead to unexpected behaviour (e.g. compile errors). 
Here are the current bugs you should know about:

- [Android: Editor not refreshing R class](https://bugs.eclipse.org/bugs/show_bug.cgi?id=433358)
- [Android: First-opened Xtend editor shows many errors and never clears those errors after build ](https://bugs.eclipse.org/bugs/show_bug.cgi?id=433589)
- [Android: R$array does not allow dot notation, although R$string and others do](https://bugs.eclipse.org/bugs/show_bug.cgi?id=437660)

[Xtend]: http://xtend-lang.org
[Active Annotations]: http://www.eclipse.org/xtend/documentation.html#activeAnnotation
