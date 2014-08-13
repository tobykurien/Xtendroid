Documentation
=============

Contents

- [Activities and Fragments](?#activities-and-fragments)
- [Background Tasks and multi-threading](?#background-tasks-using-asynctask)
- [AsyncTaskLoaders and LoaderCallbacks](?#asynctaskloaders-and-loadercallbacks)
- [Shared Preferences](?#shared-preferences)
- [Adapters](?#generic-list-adapter)
- [Base Adapter](?#base-adapter)
- [Database](?#database)
- [JSON handling](?#json-handling)
- [Enum types](?#enums-types)
- [Parcelables](?#parcelables)
- [Intents and Bundles](?#intent-and-bundles)
- [Custom Views and ViewGroups](?#custom-views-and-viewgroups)
- [Utilities](?#utilities)


Activities and Fragments
------------------------

You can bind all the view widgets in an Activity layout file to the code automatically by using the @AndroidActivity annotation, as follows:

```xtend
@AndroidActivity(R.layout.my_activity) class MyActivity {

	@OnCreate
	def init(Bundle savedInstanceState) {
		myTextView.text = "some text"
	}

}

```

Here, you specify the layout resource using the ```@AndroidActivity``` annotation, and Xtendroid will automatically parse the layout file and create getters for all the controls within the layout. This will be immediately accessible in the IDE (you will see the controls in your outline view and code-complete list). It will also auto-generate the ```onCreate()``` method if it doesn't exist, extend from ```Activity``` class, and load the layout into the Activity. Finally, it will look for any methods with the ```@OnCreate``` annotation, and call them within the ```onCreate()``` method once the controls are ready to be accessed. This annotation also ensures that all ```android:onClick``` method references in the layout exist in the activity, and if not, marks the activity with an error.

You can do something similar in a fragment using the ```@AndroidFragment``` annotation, but beware that in a fragment, the layout is loaded in the ```onCreateView()``` method and the controls are only ready to be accessed in ```onViewCreated()``` or ```onActivityCreated()``` methods. If you simply use the ```@OnCreate``` annotation on your method that instantiates the fragment, this will all be taken care of for you:

```xtend
@AndroidFragment(R.layout.my_fragment) class MyFragment {

	@OnCreate
	def init(Bundle savedInstanceState) {
		myTextView.text = "some text"
	}

}

```


Background tasks using AsyncTask
--------------------------------

A class called ```BgTask``` is provided, that extends the standard ```AsyncTask``` and works in much the same way, but provides lambda parameters for the background task and the UI task, thus reducing boilerplate:

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
   
   // update progress UI from background thread
   runOnUiThread[| progressBar.progress = 10 ] 
   
   return retVal // return keyword is optional
],[result|
   // this runs in the UI thread, progressDialog automatically dismissed afterwards
   toast("Got back: " + result)
])
```

No ```onProgressUpdate`` method is needed, since it is trivial to use the ```runOnUiThread``` method instead, as shown above.  Handling errors in a background task is made easy: you can simply pass a third lambda function that will be executed (in the UI thread) if an error occurs during the background task:

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

AsyncTaskLoaders and LoaderCallbacks
------------------------------------

If you prefer to tightly bind your background tasks to the Activity's or Fragment's lifecycle, then you can use `BgLoader` to get things done.

```xtend
new BgLoader<String>([|
   // this runs in the background thread, e.g. http call
],
[
   // this is responsible for clean up duties
   // e.g. to prevent memory leaks
])
```

The result can be fetched by extending your Activity or Fragment with a LoaderCallback. Setting up the callback and the loader requires plenty of boilerplate code.

It requires the following actions:

* Create an integer ID for the LoaderManager to identify a Loader with
* Write code to initialize a loader
* Setup the callback to receive the results from the Loader

All of this is taken care of by the `@AndroidLoader` annotation.
All you need to do is place this annotation on top of your Fragment or Activity and implement `LoaderManager.Callbacks`. 

Also, use your IDE's auto-implement function to generate the other 2 callback methods, i.e. `onLoadFinished` and `onLoaderReset`.

You're free to implement as many Loaders as you require. You may use your own Loader implementation, it's not necessary to use `BgLoader` with `@AndroidLoader`.

```xtend
@AndroidLoader
class MyActivity extends Activity implements LoaderManager.LoaderCallbacks {

	var Loader<MyBean> loader = new MyLoader<MyBean>(this)
	var MyBean bean = null
	
	override onLoadFinished(Loader loader, Object data) {
		bean = new MyBean(data)
	}

	override onLoaderReset(Loader loader) {
	}
	
}
```

Shared Preferences
------------------

If you are using ```SharedPreferences```, and you have a ```PreferenceActivity``` to allow the user to change app settings, then the ```BasePreferences``` class and ```@AndroidPreference``` annotation makes it super-easy to access the settings in your activity:

Create a ```Settings``` class:
```xtend
@AndroidPreference class Settings {
   boolean enabled = true // maps to preference "enabled"
   String authToken = ""  // maps to preference "auth_token"
}
```

The ```@AndroidPreference``` annotation will automatically make the class extend ```BasePreferences```, add getters/setters for each *private* and *non-annotated* field that maps by name to the appropriate resource in your settings XML file, and finally creates a static getter method named ```get[Your class name]``` that gives you the syntactic sugar to use it in any activity or fragment, as follows:

Now you can use the Settings class in any Activity:
```xtend
import static extension Settings.*

// elsewhere in activity or fragment
if (settings.enabled) {
   settings.authToken = "new auth token" // How cool is this?
}
```

Whoa! Where did the ```settings``` object/keyword come from in the code above? It is a reference to the static ```getSettings(Context context)``` method that was automatically added to the ```Settings``` class by the annotation, and then statically imported as an extension method. In Xtend:

```xtend
// this
Settings.getSettings(context).enabled = true

// can be reduced to this by import static extension Settings.*
getSettings(context).enabled = true

// which is the same as this (extension method)
context.getSettings().enabled = true

// which, in an activity is the same as
this.getSettings().enabled = true

// since "this" is implicit, that becomes
getSettings().enabled = true

// and Xtend gives further syntax sugar for that, so it becomes
settings.enabled = true
```

Outside an activity or fragment, when a ```Context``` object is available, you can simply append the context object as follows:
```xtend
import static extension Settings.*

// elsewhere in the service/receiver
if (context.settings.enabled) {
   context.settings.authToken = "new auth token"
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
@OnCreate def init(Bundle instanceState) {
	var List<User> users = getUsers(...) // load the beans from somewhere
	var adapter = new BeanAdapter<User>(this, R.layout.row_user, users)
	userList.adapter = adapter // assuming the ListView is R.id.user_list
}
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
   
   // another method to provide the same syntax to fragments
   def static getDb(Fragment fragment) {
      return getDb(fragment.activity)
   }     
}
```
Note that DbService ultimately extends ```android.database.sqlite.SQLiteOpenHelper```, so you can use your normal Android database code too.

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

Creating a JSON bean is done using the ```@AndroidJson``` annotation, as in this example:

```xtend
@AndroidJson class NewsItem {
	String url
	String title
	long id
	boolean published
}
```

The annotation creates a constructor (that takes the JSONObject), and generates lazy-parsing getters for each *private* and *non-annotated* field. You can then load JSON into the bean and use it, as in this example:

```xtend
var jsonResponse = '''{"url":"http://one.com", "title": "One", "id": 1, "published": true}'''
var newsItem = new NewsItem(new JSONObject(jsonResponse))
toast(newsItem.title) // JSON parsed here and cached for later use
```

Nested JSON beans are supported (you can have a field that is another bean annotated with the ```@AndroidJson``` annotation). See the 
[JsonTest](../../XtendroidTest/XtendroidTestCasesTest/src/org/xtendroid/xtendroidtest/test/JsonTest.xtend) for more.

In addition to using it at the class-level, you can also use it at the field-level to specify additional parameters, like date format or property name, as in this example:

```xtend
@AndroidJson JsonData {
	String title
	
	@AndroidJson("yyyy-MM-dd") // date format
	Date createdAt
	
	@AndroidJson("createdBy") // we want to map "createdBy" json property to "author" field
	String author	
}
```

Note: The ```@JsonProperty``` annotation has been deprecated in favour of ```@AndroidJson```.

Enum types
----------

There is an annotation to generate enum types or reuse pre-defined enum types, that generates the convenience methods to convert Strings to enum types.

Like this:

```xtend
enum ABCEnum
{
	a,b,c
}

class MyBean
{
	@EnumProperty(enumType=ABCEnum) // pre-defined
	var String alpha
	
	
	@EnumProperty(name="DEFEnum", values=#["d","e","f"])
	var String delta
}
```

Later on you can use the generated methods as extension methods, this is especially handy when you're converting string to enums, e.g. from a JSON object.

Custom Views and ViewGroups
---------------------------

The annotation `@CustomView` and `@CustomViewGroup` are capable of generating the boilerplate code involved with creating custom views.

`@CustomViewGroup` will create getters and setters for the `@+id/...` ids for the nested views.

Both annotations setup the required constructors for custom views.

Setting up a custom `ViewGroup` is slightly more involved. So this is how you set it up:

```xtend
@CustomViewGroup(layout = R.layout.my_merge_layout)
abstract class MyCustomViewGroup extends RelativeLayout
{
	def abstract void showWithData(Payload input)

	def void init(Context context) {
		// ... set defaults .text, .textColor etc.
	}
}
```

For example, this class is defined as an abstract class containing an abstract method, but these will no longer be abstract, after the annotation has done its work.

The abstract method, will try to match the names of the ids, with members of the `Payload` bean. In the non-abstract resulting method of `showWithData`. This method name is just an example, nhe abstract method can assume any name. This method can be used to inject `String` values to `TextView`s and resource ids to `ImageView`s, contained in the custom `ViewGroup`.

For instance, the `Payload` type in this example could be a bean annotated with `@AndroidJson`.

Any number of methods containing one single parameter accepting a `Context` object, will be automagically invoked in the generated constructors. This can be used to initialize the custom `View` or `ViewGroup`.

All of the methods mentioned above are not required, to use both annotations.

BaseAdapter
-----------

Implementing BaseAdapters with custom views has never been so easy.

```xtend
@AndroidAdapter
class MyAdapter extends BaseAdapter {
	var List<Payload> data
	var MyViewGroup showWithData
}
```

The constructor is generated, and all the other things required, to use a working BaseAdapter.

The member `showWithData` is a placeholder for the name of the method that will be used to inject data into the custom ViewGroup, i.e. MyViewGroup object in the previous example.

You can use an `@Accessor` or `@Property` annotation to access the data.

Parcelables
-----------

Currently, the `@AndroidParcelable` is a type-level (read: class) annotation that ensures that all the member fields will be serialized using the android Parcel way of serializing stuff.

All you need to do is just slap the annotation on top of the bean, and pass the Parcelable through an Intent.

There are plans to change `@AndroidParcelable` to also become a member-level type annotation.

Intents and Bundles
-------------------

The member-level `@BundleProperty` annotation, will create a convenience methods for extracting a value from a Bundle or Intent.

If a `@BundleProperty` is applied to a member of an Activity then the generated convenience method will be applied to the intent of the Activity.

If applied to a Fragment, then it will be applied to the Bundle (through the `getArguments` method).

If applied to a bean or a Service or any other type other than an Activity or Fragment, then the annotation will attempt to find an Intent among the members and do the same.

```xtend
class MyActivity extends Activity 
{
	@BundleProperty
	String myString
}

class MyFragment extends Fragment
{
	@BundleProperty
	int myInt // the member name is the name of the key in the Bundle
}

```

It's important to define the type of the member, so the correct methods will be invoked to fetch the value contained within the Bundle.

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
