Xtendroid
=========

Xtendroid is an Android library that combines the power of [Xtend][] with some utility classes and annotations for productive Android development. Xtendroid helps to reduce/eliminate boilerplate code that Android is known for, while providing full IDE support. This is achieved by using Xtend's [extension methods][xtend-doc] and [active annotations][] (edit-time code generators), which expand out to Java code during editing/compilation.

Xtendroid can replace dependency injection frameworks like RoboGuice, Dagger, and Android Annotations, with lazy-loading getters that are [automatically generated][injection] for widgets in your layouts. With Xtend's lambda support and functional-style programming constructs, it reduces/eliminates the need for libraries like RetroLambda and RxJava. With it's [database support][database], Xtendroid also removes the need for ORM libraries.

**Anonymous inner classes**

Android code:
```java
// get button widget, set onclick handler to toast a message
Button myButton = (Button) findViewById(R.id.my_button);

myButton.setOnClickListener(new View.OnClickListener() {
   public void onClick(View v) {
      Toast.makeText(this, "Hello, world!", Toast.LENGTH_LONG).show();
   }
});
```
Xtendroid Code:
```xtend
// myButton references pre-generated getMyButton() lazy-getter
myButton.onClickListener = [
   toast("Hello, world!")
]
```

**Redundant Type Information**

Android code:
```java
// Store JSONObject results into an array of HashMaps
ArrayList<HashMap<String,JSONObject>> results = new ArrayList<HashMap<String,JSONObject>>();

HashMap<String,JsonObject> result1 = new HashMap<String,JSONObject>();
result1.put("query", new JSONObject());

results.put(result1);
```

Xtendroid (Xtend) code:
```xtend
var results = #[
    #{ "query" -> new JSONObject }
]
```

**Lambdas and multi-threading**

Blink a button 3 times (equivalent Java code is too verbose to include here):
```xtend
import static extension org.xtendroid.utils.AsyncBuilder.*

// Blink button 3 times using AsyncTask
async [
    for (i : 1..3) { // number ranges, nice!
        runOnUiThread [ myButton.pressed = true ]
        Thread.sleep(250) // look ma! no try/catch!
        runOnUiThread [ myButton.pressed = false ]
        Thread.sleep(250)
    }
].start()
```

Documentation
-------------

Xtendroid removes boilerplate code from things like activities and fragments, background processing, shared preferences, adapters (and ViewHolder pattern), database handling, JSON handling, Parcelables, Bundle arguments, and more. Combining these, you get concise and expressive code.

View the full reference documentation for Xtendroid [here][doc].

Sample
-------

Here's an example of an app that fetches a quote from the internet and displays it. First, the standard Android activity layout:

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

Now the activity class to fetch the quote from the internet (in a background thread), handle any errors, and display the result. Only imports and package declaration have been omitted.

*MainActivity.xtend*
```xtend
@AndroidActivity(R.layout.activity_main) class MainActivity {

   @OnCreate   // Run this method when widgets are ready
   def init() {
      // set up the button to load quotes
      mainLoadQuote.onClickListener = [
         // show progress
         val pd = new ProgressDialog(this)
         pd.message = "Loading quote..."

         // load quote in the background
         async(pd) [
            // get the data in the background
            getData('http://www.iheartquotes.com/api/v1/random')
         ].then [String result|
            // update the UI with new data
            mainQuote.text = Html.fromHtml(result)
         ].onError [Exception error|
            // handle any errors by toasting it
            toast("Error: " + error.message)
         ].start()
      ]
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

Declare the activity in your ```AndroidManifest.xml``` file, add the internet permission, and that's it! Note the lack of boilerplate code and Java verbosity in things like exception handling and implementing anonymous inner classes for handlers.

This and other examples are in the [examples folder][examples]. The [Xtendroid Test app][] is like Android's API Demos app, and showcases the various features of Xtendroid.

For an example of a live project that uses this library, see the Webapps project: https://github.com/tobykurien/webapps

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

In addition, Xtendroid implements several [Active Annotations][] which remove most of the boilerplate-code that's associated with Android development. Here is an example of one of the most powerful Xtendroid annotations, ```@AndroidActivity```:

```xtend
@AndroidActivity(R.layout.my_activity) class MyActivity {

	@OnCreate
	def init(Bundle savedInstanceState) {
		myTextView.text = "some text"
	}

}
```

```@AndroidActivity``` automatically extends the ```Activity``` class, loads the layout into the activity, parses the specified layout file, and creates getters/setters for each of the views contained there-in, and checks for the existence of all ```onClick``` methods, at **edit-time**! You will immediately get code-completion and outline for your layout widgets! Any method annotated with ```@OnCreate``` is called at runtime once the views are ready, although as with everything in Xtendroid, you are free to implement the ```onCreate()``` method yourself.

Note that the Active Annotations run at edit-time and simply generate the usual Java code for you, so there is no runtime performance impact. View this video of how this works and how well it integrates with the Eclipse IDE: http://vimeo.com/77024959

Getting Started
===============

Have a look at the [XtendApp skeleton app][xtendapp] to jump-start your project. It is pre-configured and works in Android Studio as well (although support for Xtend in Android Studio is still in development).

Method 1: Copy JAR file in
------------------------
- Download the latest release from https://github.com/tobykurien/Xtendroid/tree/master/Xtendroid/release
- Copy the JAR file into your Android project's `libs` folder
- If your project isn't Xtend-enabled yet:
  - Right-click on your project -> Properties -> Java Build Path
  - Click Libraries -> Add library -> Xtend Library
- Now you can use it as documented [here][doc].

Method 2: Gradle build config
---------------------------
- In your `build.gradle` file, add a compile dependency for ```com.github.tobykurien:xtendroid:0.12.1``` and also add the [Xtend compiler](https://github.com/oehme/xtend-gradle-plugin)
- A typical `build.gradle` file looks as follows:

```groovy
buildscript {
    repositories {
        jcenter()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:1.2.3'
        classpath 'org.xtend:xtend-android-gradle-plugin:0.4.9'
    }
}

apply plugin: 'android'
apply plugin: 'org.xtend.xtend-android'

repositories {
    mavenCentral()
}

android {
	dependencies {
		compile 'com.github.tobykurien:xtendroid:0.12.1'
		
		compile 'org.eclipse.xtext:org.eclipse.xtext.xbase.lib:2.8.3'

		// other dependencies here
	}

	// other build config stuff
}
```

Xtend
=====

The latest version of Xtendroid is built with Xtend v2.8.1. For more about the Xtend language, see [http://xtend-lang.org][xtend].

A port of Xtendroid to [Groovy][] is in the works, see [android-groovy-support][]

IDE Support
===========

Xtend and Xtendroid are currently supported in Eclipse (Xtend is an Eclipse project) as well as Android Studio 2+ (or IntelliJ 15+). Here's how to [use Xtendroid in Android Studio][android_studio]. Also for Android Studio, check out the [android-groovy-support] project for a similar library for the Groovy language.

If you'd like to use Gradle for your build configuration, but still be able to develop in Eclipse, use the [Eclipse AAR plugin for Gradle][eclipse_aar_gradle]. This also allows you to use either Eclipse or Android Studio while maintaining a single build configuration.

Gotchas
=======

There are currently some bugs with the Eclipse Xtend editor that can lead to unexpected behaviour (e.g. compile errors).
Here are the current bugs you should know about:

- [Android: Editor not refreshing R class](https://bugs.eclipse.org/bugs/show_bug.cgi?id=433358)
- [Android: First-opened Xtend editor shows many errors and never clears those errors after build ](https://bugs.eclipse.org/bugs/show_bug.cgi?id=433589)

If in doubt, clean the project, and re-open the editor.

Some Xtend Gradle plugin gotchas:

- [First Gradle build fails, but works thereafter](https://github.com/xtext/xtend-gradle-plugin/issues/32)


[Xtend]: http://xtend-lang.org
[xtend-doc]: http://www.eclipse.org/xtend/documentation.html
[Active Annotations]: http://www.eclipse.org/xtend/documentation.html#activeAnnotation
[doc]: /Xtendroid/docs/index.md
[injection]: /Xtendroid/docs/index.md#activities-and-fragments
[database]: /Xtendroid/docs/index.md#database
[examples]: /examples
[Xtendroid Test app]: /XtendroidTest
[xtendapp]: https://github.com/tobykurien/XtendApp
[android_studio]: https://github.com/tobykurien/Xtendroid/wiki/HowTo-setup-Android-Studio-%28aka-Intellij%29-support
[eclipse_aar_gradle]: https://github.com/ksoichiro/gradle-eclipse-aar-plugin
[Groovy]: http://groovy-lang.org
[android-groovy-support]: https://github.com/tobykurien/android-groovy-support 