Xtendroid
=========

Xtendroid is a DSL (domain-specific language) for Android that is implemented 
using the [Xtend][] language, which features [extension methods][xtend-doc] and 
[active annotations][] (edit-time code generators) that expand out to Java 
code during editing or compilation. *Active annotations* make Xtend more suitable 
for DSL creation than languages like Kotlin or Groovy. Xtendroid supports Eclipse 
and IntelliJ/Android Studio.

Xtendroid can replace dependency injection frameworks like RoboGuice, Dagger, 
and Android Annotations, with lazy-loading getters that are 
[automatically generated][injection] for widgets in your layouts. With Xtend's 
lambda support and functional-style programming constructs, it 
reduces/eliminates the need for libraries like RetroLambda and RxJava. With 
it's [database support][database], Xtendroid also removes the need for ORM 
libraries.

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

**Type Inference**

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

Blink a button 3 times (equivalent Android code is too verbose to include here):
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

**Android boilerplate removal**

Android:
```java
public class Student implements Parcelable {
        private String id;
        private String name;
        private String grade;

        // Constructor
        public Student(String id, String name, String grade){
            this.id = id;
            this.name = name;
            this.grade = grade;
       }

       // Getter and setter methods
       // ... ommitted for brevity!
       
       // Parcelling part
       public Student(Parcel in){
           String[] data = new String[3];

           in.readStringArray(data);
           this.id = data[0];
           this.name = data[1];
           this.grade = data[2];
       }

       @Оverride
       public int describeContents(){
           return 0;
       }

       @Override
       public void writeToParcel(Parcel dest, int flags) {
           dest.writeStringArray(new String[] {this.id,
                                               this.name,
                                               this.grade});
       }
       public static final Parcelable.Creator CREATOR = new Parcelable.Creator() {
           public Student createFromParcel(Parcel in) {
               return new Student(in); 
           }

           public Student[] newArray(int size) {
               return new Student[size];
           }
       };
   }
```

Xtendroid:
```xtend
// @Accessorts creates getters/setters, @AndroidParcelable makes it parcelable!
@Accessors @AndroidParcelable class Student {
    String id
    String name
    String grade
}
```

**Functional programming style**

```xtend
    @Accessors class User {
        String username
        long salary
        int age
    }

    var List<User> users = getAllUsers() // from somewhere...
    var result = users
            .filter[ age >= 40 ]
            .maxBy [ salary ]
            
    toast('''Top over 40 is «result.username» earning «result.salary»''')
```


**Builder pattern**
```xtend
// Builder class to create UI widgets
class UiBuilder {
   
   def static LinearLayout linearLayout(Context it, (LinearLayout)=>void initializer) {
      new LinearLayout(it) => initializer
   }
   
   def static Button button(Context it, (Button)=>void initializer) {
      new Button(it) => initializer
   }
   
} 

// Now let's use it!
import static extension org.xtendroid.utils.AlertUtils.*
import static extension UiBuilder.*

contentView = linearLayout [
   gravity = Gravity.CENTER
   addView( button [
      text = "Say Hello!"
      onClickListener = [ 
         toast("Hello Android from Xtend!")
      ]
   ])
]

```

Documentation
-------------

Xtendroid removes boilerplate code from things like activities and fragments, 
background processing, shared preferences, adapters (and ViewHolder pattern), 
database handling, JSON handling, Parcelables, Bundle arguments, and more. 

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

Getting Started
===============

Have a look at the [XtendApp skeleton app][xtendapp] to jump-start your project. It is a pre-configured skeleton Xtendroid app for Android Studio 2+. Simply clone it to begin your new project.

Method 1: Copy JAR file in
------------------------
- Download the latest release from https://github.com/tobykurien/Xtendroid/tree/master/Xtendroid/release
- Copy the JAR file into your Android project's `libs` folder
- If your project isn't Xtend-enabled yet in Eclipse:
  - Right-click on your project -> Properties -> Java Build Path
  - Click Libraries -> Add library -> Xtend Library
- Now you can use it as documented [here][doc].

Method 2: Gradle build config
---------------------------
- In your `build.gradle` file, add a compile dependency for ```com.github.tobykurien:xtendroid:0.13``` and also add the [Xtend compiler](http://xtext.github.io/xtext-gradle-plugin/xtend.html)
- A typical `build.gradle` file looks as follows:

```groovy
buildscript {
    repositories {
        jcenter()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:2.1.0-alpha3'
        classpath 'org.xtext:xtext-android-gradle-plugin:1.0.3'
    }
}

apply plugin: 'android'
apply plugin: 'org.xtext.android.xtend'

repositories {
    mavenCentral()
}

android {
	dependencies {
		compile 'com.github.tobykurien:xtendroid:0.13'
		
		compile 'org.eclipse.xtend:org.eclipse.xtend.lib:2.9.1'

		// other dependencies here
	}

	// other build config stuff
}
```

Xtend
=====

The latest version of Xtendroid is built with Xtend v2.9.1. For more about the Xtend language, see [http://xtend-lang.org][xtend].

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

If in doubt, close and re-open the file, or worst-case, clean the project.

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
[android_studio]: https://github.com/tobykurien/Xtendroid/wiki/HowTo-setup-Android-Studio-%28also-Intellij%29-support
[eclipse_aar_gradle]: https://github.com/ksoichiro/gradle-eclipse-aar-plugin
[Groovy]: http://groovy-lang.org
[android-groovy-support]: https://github.com/tobykurien/android-groovy-support 
