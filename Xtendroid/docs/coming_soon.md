Work in progress
================

- [AsyncTaskLoaders and LoaderCallbacks](#asynctaskloaders-and-loadercallbacks)
- [Custom Adapter](#custom-adapter)
- [Custom Views and ViewGroups](#custom-views-and-viewgroups)
- [Enum types](#enum-types)


AsyncTaskLoaders and LoaderCallbacks
------------------------------------

If you prefer to tightly bind your background tasks to the Activity's or Fragment's lifecycle, then you can use `BgLoader` to get things done.

```xtend
new BgLoader<String>(context, [|
   // this runs in the background thread, e.g. http call
],[
   // this is responsible for clean up duties
   // e.g. to prevent memory leaks
])
```

The result can be fetched by extending your Activity or Fragment with a LoaderCallback. Setting up the callback and the loader requires plenty of boilerplate code.

It requires the following actions:

* Create an integer ID for the LoaderManager to identify a Loader with
* Write code to initialize a loader
* Setup the callback to receive the results from the Loader

All of this is taken care of by the `@AndroidLoader` annotation. All you need to do is place this annotation on top of your Fragment or Activity and implement `LoaderManager.Callbacks`.

Also, use your IDE's auto-implement function to generate the other 2 callback methods, i.e. `onLoadFinished` and `onLoaderReset`.

You're free to implement as many Loaders as you require. You may use your own Loader implementation, it's not necessary to use `BgLoader` with `@AndroidLoader`.

```xtend
@AndroidLoader
class MyActivity extends Activity
   implements LoaderManager.LoaderCallbacks<MyBean> {

	var loader = new MyLoader<MyBean>(this)
	var MyBean bean = null

	override onLoadFinished(Loader<MyBean> loader, MyBean data) {
		bean = data
	}

	override onLoaderReset(Loader loader) {
	}

}
```

Custom Adapter
--------------

Implementing a custom adapter that extends `BaseAdapter` with custom views has never been so easy.

```xtend
@AndroidAdapter class MyAdapter {
   var List<Payload> data         // first list used as adapter data
   var MyViewGroup showWithData   // "showWithData" viewgroup will display data
}
```

The constructor is generated, and all the other things required, to use a working BaseAdapter.

The member `showWithData` is a placeholder for the name of the method that will be used to inject data into the custom ViewGroup, i.e. MyViewGroup object in the previous example.

You can use an `@Accessor` or `@Property` annotation to access the data.

Custom Views and ViewGroups
---------------------------

The annotation `@CustomView` and `@CustomViewGroup` are capable of generating the boilerplate code involved with creating custom views.

`@CustomViewGroup` will create getters and setters for the `@+id/...` ids for the nested views.

Both annotations setup the required constructors for custom views.

Setting up a custom `ViewGroup` is slightly more involved. So this is how you set it up:

```xtend
@CustomViewGroup(R.layout.my_merge_layout)
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

Enum types
----------

The `@EnumProperty` annotation allows you to generate enum types or reuse pre-defined enum types, and generates the convenience methods to convert Strings to enum types.

Like this:

```xtend
enum ABCEnum {
   a,b,c
}

class MyBean {
   @EnumProperty(enumType=ABCEnum) // pre-defined
   var String alpha

   @EnumProperty(name="DEFEnum", values=#["d","e","f"])
   var String delta
}
```

Now you can use the generated methods as extension methods:

```xtend
alpha = ABCEnum.a.toString
delta = DEFEnum.d.toString

assertEquals(DEFEnum.toDEFEnumValue(delta), DEFEnum.d)
```

This is especially handy when you're converting string to enums, e.g. from a JSON object.

