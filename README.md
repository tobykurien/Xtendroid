Xtendroid
=========

Xtendroid is an Android library that combines the power of Xtend with some utility classes/annotations for productive Android development. With Xtendroid, you can spend a lot less time writing boilerplate code and benefit from the tooling support provided by the Xtend framework. Xtendroid is based on the convention-over-configuration philosophy, so resources in Android map automatically to Java getters and setters by name (CamelCase to resource_name mapping).

Examples
========

Toasts
------

If you display toasts often, you know that typing out Toast.makeText... is a pain, and it's not easy to add it to a base class, since Activities may extend multiple base classes (like ListActivity, FragmentActivity, etc.) Here's the easy way using Xtendroid:

```xtend
import static extension com.tobykurien.xtendroid.utils.AlertUtils.*

// elsewhere
toast("My message")
```

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
getMyTextView.text = "some text" // use the getter for lazy-loading
```

in a Fragment, add the @AndroidFragment annotation:
```xtend
@AndroidFragment class MyFragment extends Fragment {
   @AndroidView TextView myTextView // maps to R.id.my_text_view
}
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
val progressBar = new ProgressDialog(...)

new BgTask<String>.runInBg([|
   // this bit runs in a background thread
   var retVal = fetchStringFromSomewhere()
   runOnUiThread[| progressBar.progress = 10 ] // update UI
   retVal
],[result|
   // this runs in the UI thread
   toast("Got back: " + result) // How cool is this?
])
```

Shared Preferences
------------------

If you are using SharedPreferences, and you have a PreferenceActivity to allow the user to change app settings, then the BasePreferences class and @Preference annotation makes it super-easy to access the settings in your Activity:

Create a Settings class:
```xtend
class Settings extends BasePreferences {
   @Preference boolean enabled = true // maps to preference "enabled"
   @Preference String authToken = ""  // maps to preference "auth_token"

   // convenience method to get instance
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

Do you have a list of POJO's that you want to display inside a ListView? The BeanAdapter makes this super easy!

row_user.xml:
```xml
<LinearLayout ... >
 <TextView android:id="@+id/first_name" .../>
 <TextView android:id="@+id/last_name" .../>
 <ImageView android:id="@+id/avatar" .../>
</LinearLayout>
```

The POJO:
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
var List<User> users = getUsers(...) // load the POJO's
var adapter = new BeanAdapter<User>(this, R.layout.row_user, users)
getUserList.adapter = adapter
```

Database
--------

Database handling is made much easier thanks to the aBatis project - a fork of this project is included in Xtendroid with some syntactic sugar provided by the BaseDbService class for Xtend. Let's look at typical usage:

Create a POJO for some data you want to store:
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
Note that the column names in the database are exactly the same as the field names in the POJO. The special string name "dbInitialize" is used the first time the db is created, thereafter onUpgrade() is called on the DbService class for newer versions.

Create a DbService class you will use to interact with the database:
```xtend
class DbService extends BaseDbService {
   protected new(Context context) {
      super(context, "mydatabase", 1) // mydatabase.db is created with version 1
   }

   // convenience method for syntactic sugar
   def static getDb(Context context) {
      return new DbService(context)
   }   
}
```
Note that DbService ultimately extends android.database.sqlite.SQLiteOpenHelper, so you can use your normal Android database code too.

Now you are ready to play! Here are some example usages:
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

For an example of a project that uses this library, see the Webapps project http://github.com/tobykurien/webapps

Getting Started
===============

Git clone this repository and import it using Eclipse. Add it as a library project to your Xtend project. Now you can use it as shown in the examples above.

More documentation coming soon. This project is in early alpha stage, so expect changes as it matures. Feel free to fork and send me pull requests.

Xtend
=====

For more about Xtend, see http://xtend-lang.org


