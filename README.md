Xtendroid
=========

Xtendroid is an Android library that combines the power of Xtend with some utility classes/annotations for productive Android development. With Xtendroid, you can spend a lot less time writing boilerplate code and benefit from the tooling support provided by the Xtend framework. Xtendroid is based on the convention-over-configuration philosophy, so resources in Android map automatically to Java getters and setters by name (CamelCase to resource_name mapping).

Examples
========

Toasts
------

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

Android view resources
----------------------

Want to access a view in your Activity? Instead of

```java
TextView myTextView;

// elsewhere
myTextView = (TextView) findViewById(R.id.my_text_view);
myTextView.setText("some text");
```

do this using Xtendroid in an Activity:

```xtend
@AndroidView TextView myTextView // maps to R.id.my_text_view

// elsewhere
myTextView.text = "some text" // uses a getter for lazy-loading the actual view
```

The reference to the R class could be missing if you have not used it anywhere in
your Activity or Fragment, in which case you can specify it as follows:
```xtend
   val r = R // field declaration to import and reference correct R class
```

Background tasks using AsyncTask
--------------------------------

Do you find the AsyncTask boilerplate code too messy? Try the BgTask class:

```xtend
new BgTask<String>.runInBg([|
   // this bit runs in a background thread
   return getSomeString()
],[result|
   // this runs in the UI thread
   toast("Got back: " + result) // note how toast() works here too!
])
```

ProgressDialog is also handled automatically when using this syntax:

```xtend
val progressBar = new ProgressDialog(...)

new BgTask<String>.runInBgWithProgress(progressBar, [|
   // this bit runs in a background thread, progressDialog automatically displayed
   var retVal = fetchStringFromSomewhere()
   runOnUiThread[| progressBar.progress = 10 ] // update UI
   retVal
],[result|
   // this runs in the UI thread, progressDialog automatically dismissed afterwards
   toast("Got back: " + result)
])
```

Shared Preferences
------------------

If you are using SharedPreferences, and you have a PreferenceActivity to allow the user to change app settings, then the BasePreferences class and @Preference annotation makes it super-easy to access the settings in your Activity:

Create a Settings class:
```xtend
class Settings extends BasePreferences {
   @AndroidPreference boolean enabled = true // maps to preference "enabled"
   @AndroidPreference String authToken = ""  // maps to preference "auth_token"

   /** 
    * convenience method to get instance:
    *   var s = Settings.getSettings(context)
    *   s.XXX()
    * can be shortened as (using import static extension):
    *   context.getSettings().XXX()
    * which can further be shortened in an Activity or other context as:
    *   getSettings().XXX()
    * which can be shortened further as:
    *   settings.XXX 
    */
   def static Settings getSettings(Context context) {
      return getPreferences(context, typeof(Settings)) as Settings
   }
}
```

Now you can use the Settings class in any Activity:
```xtend
import static extension Settings.*

// elsewhere
if (settings.enabled) {
   settings.authToken = "new auth token" // How cool is this?
}
```

Generic list adapter
--------------------

Do you have a list of Java beans that you want to display inside a ListView? The BeanAdapter makes this super easy!

Layout for each row - row_user.xml:
```xml
<LinearLayout ... >
 <TextView android:id="@+id/first_name" .../>
 <TextView android:id="@+id/last_name" .../>
 <ImageView android:id="@+id/avatar" .../>
</LinearLayout>
```

Java bean containing the data (fields map by name to the layout above):
```xtend
class User {
  @Property String firstName
  @Property String lastName
  @Property Bitmap avatar
}
```

The Activity:
```xtend
@AndroidView ListView userList // maps to R.id.user_list

// in onCreate
var List<User> users = getUsers(...) // load the beans from somewhere
var adapter = new BeanAdapter<User>(this, R.layout.row_user, users)
userList.adapter = adapter
```

Database
--------

Database handling is made much easier thanks to the aBatis project - a fork of this project is included in Xtendroid with some syntactic sugar provided by the BaseDbService class for Xtend. Let's look at typical usage:

Create a bean for some data you want to store:
```xtend
class User {
  @Property String firstName
  @Property String lastName
  @Property int age
  
  def toString() {
      firstName + " " + lastName
  }
}
```

Create some SQL strings in res/values folder, e.g. in sqlmaps.xml:
```xml
<resources>
    <string name="dbInitialize">
        create table users (
           id integer primary key,
           firstName text not null,
           lastName text not null,
           age number
        );
    </string>

    <string name="dbGetUsers">
      select * from users
      order by lastName asc
    </string>
        
    <string name="dbGetUser">
      select * from users
      where id = #id#
    </string>
</resources>
```
Note that the column names in the database are exactly the same as the field names in the bean. The special string name "dbInitialize" is used the first time the db is created, thereafter onUpgrade() is called on the DbService class for newer versions. If you need to migrate between database versions, just implement onUpgrade().

Create a DbService class you will use to interact with the database:
```xtend
class DbService extends BaseDbService {
   protected new(Context context) {
      super(context, "mydatabase", 1) // mydatabase.db is created with version 1
   }

   // convenience method for syntactic sugar (as per above example of Settings class)
   def static getDb(Context context) {
      return new DbService(context)
   }   
}
```
Note that DbService ultimately extends android.database.sqlite.SQLiteOpenHelper, so you can use your normal Android database code too.

Now you are ready to play! Here are some examples:
```xtend
import static extension DbService.*

// get all users
var users = db.executeForBeanList(R.string.dbGetUsers, null, typeof(User))
users.forEach [user|
   Log.d("db", "Got user: " + user)
]

// insert a record
var johnId = db.insert("users", #{
   'firstName' -> 'John',
   'lastName' -> 'Doe',
   'age' -> 43
})

// get back this user
var john = db.executeForBean(R.string.dbGetUser, 
   #{'id' -> johnId}, typeof(User))
toast("Hi " + john)   

// update this user
db.update("users", #{'lastName' -> 'Smith'}, johnId)

// delete this user
db.delete("users", johnId) 
```

Samples
-------

There are several examples in the examples folder: https://github.com/tobykurien/Xtendroid/tree/master/examples

For an example of a live project that uses this library, see the Webapps project https://github.com/tobykurien/webapps

Getting Started
===============

Method 1:
---------
- Download the latest release from https://github.com/tobykurien/Xtendroid/releases
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
