Documentation
=============

Contents

- [Activities and Fragments](#activities_and_fragments)
- [Background Tasks and multi-threading](#background-tasks-and-multi-threading)
- [Shared Preferences](#shared-preferences)
- [Database](#datebase)
- [JSON handling](#json-handling)
- [Bundles and Parcelables]()
- [Utilities](#utilities)


Activities and Fragments
------------------------

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

In a ```Fragment```, you can use the same code, but add the ```@AndroidFragment``` annotation, 
and ensure that you only reference your widgets after onCreateView() is called, otherwise the 
widgets will still be null. Typically, you can initialize your widget in ```onActivityCreated()```. 
Here is an example of a Fragment:

```xtend
@AndroidFragment class MyFragment extends Fragment {
	@AndroidView TextView myText // references R.id.my_text
	
	override onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
	   // inflate and return our layout here
		inflater.inflate(R.layout.fragment_myfragment, container, false)
	}
	
	override onActivityCreated(Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState)
		
		// initialize our widgets
		myText.text = "Hello, fragment!"
	}  		
}
```

As an alternative to using individual ```@AndroidView``` annotations, you can bind all the controls in an 
Activity layout file to the code automatically by using the @AndroidActivity annotation, as follows (this is 
not currently supported in Fragments):

```xtend
@AndroidActivity(layout=R.layout.my_activity) class MyActivity {

	@OnCreate
	def init(Bundle savedInstanceState) {
		myTextView.text = "some text"
	}

}

```

Here, you specify the layout resource using the ```@AndroidActivity``` annotation, and Xtendroid will automatically parse the layout file and create getters for all the controls within the layout. This will be immediately accessible in the IDE (you will see the controls in your outline view and code-complete list). It will also auto-generate the ```onCreate()``` method if it doesn't exist, extend from ```Activity``` class, and load the layout into the Activity. Finally, it will look for any method with the ```@OnCreate``` annotation, and call them within the ```onCreate()``` method once the controls are ready to be accessed.

View this video of how this works and how well it integrates with the IDE: http://vimeo.com/77024959


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

Handling errors in a background task is made easy: you can simply pass a third lambda function that will be executed if an error occurs during the background task:

```xtend
new BgTask<String>.runInBg([|
   // this runs in the background thread
   fetchStringFromSomewhere()
],[result|
   // this runs in the UI thread
   toast("Got back: " + result)
],[error|
   // this runs in the UI thread
   toast("Oops, this went wrong: " + error.message)
)
```

Since Honeycomb, Android has defaulted to using a single thread for all AsyncTasks, because too many developers were writing non-thread-safe code. BgTask changes that, so that multiple AsyncTasks will run simultaneously using the THREAD_POOL_EXECUTOR, so be careful to write thread-safe code.


Shared Preferences
------------------

If you are using SharedPreferences, and you have a PreferenceActivity to allow the user to change app settings, then the BasePreferences class and @AndroidPreference annotation makes it super-easy to access the settings in your Activity:

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
      return getPreferences(context, Settings)
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

The list will now display the data. If you need to add some presentation logic, for 
example display a formatted date, simply add a method to the bean to do it (e.g.
```def getFormattedDate() {...}``` and then display it in the list by naming your 
view appropriately, e.g. ```<TextView android:id="@+id/formatted_date" .../>```

Database
--------

Database handling is made much easier thanks to the aBatis project - a fork of this project is included in Xtendroid with some syntactic sugar provided by the BaseDbService class for Xtend. Let's look at typical usage:

Create a bean for some data you want to store:
```xtend
class User {
  @Property String firstName
  @Property String lastName
  @Property int age
  
  override toString() {
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

    <string name="dbGetOlderThan">
      select * from users
      where age > #age#
      order by age asc
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

// get all users order by lastName
var users = db.findAll("users", "lastName asc", User)
users.forEach [user|
   Log.d("db", "Got user: " + user)
]

// get all users older than 18 (uses SQL defined above)
var adults = db.executeForBeanList(R.string.dbGetOlderThan, 
   #{ 'age' -> 18 }, User)
adults.forEach [adult|
   Log.d("db", "Got user: " + adult)
]

// alternative to above without defining an SQL string
adults = db.findByFields("users", #{ 'age >' -> 18 },
    "age asc", User)

// can also do paging by specifying a limit and offset, e.g.
// get top 6 to top 10 users 18 or younger
adults = db.findByFields("users", #{ 'age <=' -> 18 }, "age desc",
    5, 5, User)

// insert a record
var johnId = db.insert("users", #{
   'firstName' -> 'John',
   'lastName' -> 'Doe',
   'age' -> 43
})

// get back this user
var john = db.findById("users", johnId, User)
toast("Hi " + john)   

// update this user
db.update("users", #{'lastName' -> 'Smith'}, johnId)

// delete this user
db.delete("users", johnId) 

// Suppose you have a million users and want to display them in a list.
// You can do so using the optimized lazyFindAll() and lazyFindByFields() methods
// They use a pre-allocated buffer to avoid garbage collection, and load
// batches of data at a time
var aMillionUsers = db.lazyFindAll("users", null, User)
listView.adapter = new BeanAdapter(activity, R.layout.list_row, aMillionUsers)
```

JSON handling
-------------

You can easily create a bean to hold and parse JSON data. This bean will simply 
store the JSONObject passed into the constructor without parsing the data into fields. 
The data is then parsed on-demand and cached, which makes it more efficient for use in 
```Adapter``` classes (quick load time, minimal garbage collection, parse on-demand). 

This can become memory-inefficient if you only need a small amount of data from the JSON response 
(and you discard the rest), but in that case, you are wasting the user's bandwidth and 
should seek to improve the JSON API call.

Creating a JSON bean is done as in this example:

```xtend
class NewsItem {
	@JsonProperty String url
	@JsonProperty String title
	@JsonProperty long id
	@JsonProperty boolean published
}
```

You can then load JSON into the bean as in this example:

```xtend
var jsonResponse = '''{"url":"http://one.com", "title": "One", "id": 1, "published": true}'''
var newsItem = new NewsItem(new JSONObject(jsonResponse))
toast(newsItem.title) // JSON parsed here and cached for later use
```

Currently, nested JSON beans are not yet supported, although you can declare
```@JsonProperty JSONObject user`` for example. See the 
[JsonTest](https://github.com/tobykurien/Xtendroid/blob/master/XtendroidTest/XtendroidTestCasesTest/src/org/xtendroid/xtendroidtest/test/JsonTest.xtend)
for more.

Bundles and Parcelables
-----------------------

Coming soon...


Utilities
---------

AlertUtils makes prompts and confirmation dialog boxes easy
```xtend
import static extension org.xtendroid.utils.AlertUtils.*

toast("Upload started!")
toastLong("No internet connection")

confirm("Are you sure you want to exit?") [|
    finish
]
```

ViewUtils make getting widgets from views/activities/fragments/dialogs easier by eliminating the type-casting
```xtend
import static extension org.xtendroid.utils.ViewUtils.*

var Button myButton = getView(R.id.my_button)
var TextView myText = getView(R.id.my_text)
```

TimeUtils helps with using java.util.Date
```xtend
import static extension org.xtendroid.utils.TimeUtils.*

var Date yesterday = 24.hours.ago
var Date tomorrow = 24.hours.fromNow
var Date futureDate = now + 48.days + 20.hours + 2.seconds
if (futureDate - now < 24.hours) {
    // we are in the future!
}
```
