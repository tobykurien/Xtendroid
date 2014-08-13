Xtendroid
=========

Xtendroid is an Android library that combines the power of [Xtend][] (think: CoffeeScript for Java) with some utility classes and annotations for productive Android development. With Xtendroid, you can spend a lot less time writing boilerplate code and benefit from the tooling support provided by the Xtend framework and Eclipse IDE.

Xtend code looks like Ruby or Groovy code, but is fully statically-typed and compiles to readable Java code. Most Java code is valid Xtend code too, making the learning curve very easy for Java developers. You can debug the original Xtend code or the generated Java code. The runtime library is very thin and includes [Google Guava][]. Xtend's *extension methods* and *active annotations* gives it meta-programming capabilities that are perfectly suited for Android development, and this is what Xtendroid takes advantage of. Xtend also provides lambdas and other functional programming constructs, string templating, [and more][xtend-doc]. You could say that Xtend is [Swift][] for Android.

Note that Xtend and Xtendroid are currently only supported in Eclipse (Xtend is an Eclipse project), although projects using them can be compiled with Maven or Gradle.

How it works
------------

If you display toasts often, you know that typing out ```Toast.makeText(msg, Toast.LENGTH_SHORT).show();``` is a pain, and it's not easy to add it to a base class, since Activities (and Fragments) may extend multiple base classes (like ListActivity, FragmentActivity, etc.). Here's the easy way using Xtendroid:

```xtend
import static extension org.xtendroid.utils.AlertUtils.*  // mix-in our alert utils

// elsewhere
toast("My short message")
toastLong("This message displays for longer")
```

Where is the reference to the ```Context``` object? It is implicit, thanks to Xtend:

```xtend
// this:
AlertUtils.toast(context, "My message")

// becomes this via the static import:
toast(context, "My message")

// which is equivalent to (extension method):
context.toast("My message")

// which, in an Activity is the same as:
this.toast("My message")

// But "this" is implicit, so we can shorten it to:
toast("My message")
```

The above magic, as well as the mix-in style ability of the ```import static extension``` of Xtend, is used to great effect in Xtendroid.

In addition, Xtendroid implements several [Active Annotations][] (think of them as code generators) which remove most of the boilerplate-code that's associated with Android development. Here is an example of one of the most powerful Xtendroid annotations, ```@AndroidActivity```, which automatically extends the ```Activity``` class, loads the layout into the activity, parses the specified layout file, and creates getters/setters for each of the views contained there-in, and checks for the existence of all ```onClick``` methods, at **edit-time**! You will immediately get code-completion and outline for your views! Any method annotated with ```@OnCreate``` is called at runtime once the views are ready, although as with everything in Xtendroid, you are free to implement the ```onCreate()``` method yourself.

```xtend
@AndroidActivity(R.layout.my_activity) class MyActivity {

	@OnCreate
	def init(Bundle savedInstanceState) {
		myTextView.text = "some text"
	}

}
```

Note that the Active Annotations run at compile-time and simply generate the usual Java code for you, so there is no runtime performance impact. View this video of how this works and how well it integrates with the Eclipse IDE: http://vimeo.com/77024959

Xtendroid combines extension methods, active annotations, and convention-over-configuration to provide you with a highly productive environment for Android development, where you are still writing standard Android code, but without all that boilerplate.

Documentation
-------------

Xtendroid has helpers for things like activities and fragments (as shown above), background processing, shared preferences, adapters, database handling, JSON handling, and more. Combining these, you get concise and expressive code.

View the full reference documentation for Xtendroid [here][doc].

Samples
-------

Here's an example of an app that fetches a quote from the internet and displays it. First, the activity layout:

*res/layout/activity_main.xml*
```xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".MainActivity" 
    android:orientation="vertical">

    <TextView
        android:id="@+id/main_quote"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"
        android:gravity="center"
        android:text="Click below to load a quote..."/>    

    <Button
        android:id="@+id/main_load_quote"
        android:layout_width="fill_parent"
        android:layout_height="wrap_content"
        android:text="Load Quote"/>
    
</LinearLayout>

```

Now the activity class to fetch the quote from the internet (in a background thread), handle any errors, and display the result. Imports and package declaration omitted.

*MainActivity.xtend*
```xtend
@AndroidActivity(layout=R.layout.activity_main) class MainActivity {

   @OnCreate
   def init() {
      // set up the button to load quotes
      mainLoadQuote.setOnClickListener([
         // show progress
         val pd = new ProgressDialog(this)
         pd.message = "Loading quote..."
         
         // load quote in the background
         new BgTask<String>.runInBgWithProgress(pd,[|
            // get the data in the background
            getData('http://www.iheartquotes.com/api/v1/random')               
         ],[result|
            // update the UI with new data
            mainQuote.text = Html.fromHtml(result)
         ],[error|
            // handle any errors by toasting it
            toast("Error: " + error.message)
         ])
      ])
   }

   /**
    * Utility function to get data from the internet. In production code, 
    * you should rather use something like the Volley library.
    */
   def static String getData(String url) {
      // connect to the URL
      var c = new URL(url).openConnection as HttpURLConnection
      c.connect
      
      if (c.responseCode == HttpURLConnection.HTTP_OK) {
         // read data into a buffer
         var os = new ByteArrayOutputStream
			 ByteStreams.copy(c.inputStream, os) // Guava utility            
         return os.toString
      }

      throw new Exception("[" + c.responseCode + "] " + c.responseMessage)
   }
}
```

That's it! Note the lack of boilerplate code as well as Java verbosity in things like exception handling. 

This and other examples are in the [examples folder][examples].

For an example of a live project that uses this library, see the Webapps project: https://github.com/tobykurien/webapps

Getting Started
===============

Method 1:
---------
- Download the latest release from https://github.com/tobykurien/Xtendroid/tree/master/Xtendroid/release
- Copy the JAR file into your Android project's `libs` folder
- If you are using an existing or new Android project:
  - Right-click on your project -> Properties -> Java Build Path
  - Click Libraries -> Add library -> Xtend Library
- Now you can use it as documented [here][doc].


Method 2:
---------
- Git clone this repository and import it using Eclipse.
- Add it as a library project to your Android project:
  - Right-click your project -> Properties -> Android -> (Library) Add -> Xtendroid
- If you are using an existing or new Android project:
  - Right-click on your project -> Properties -> Java Build Path
  - Click Libraries -> Add library -> Xtend Library
- Now you can use it as documented [here][doc].

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

If in doubt, clean the project, and re-open the editor.

[Xtend]: http://xtend-lang.org
[xtend-doc]: http://www.eclipse.org/xtend/documentation.html
[Google Guava]: https://code.google.com/p/guava-libraries/
[Active Annotations]: http://www.eclipse.org/xtend/documentation.html#activeAnnotation
[Swift]: https://developer.apple.com/swift/
[doc]: /Xtendroid/docs/index.md
[examples]: /examples
