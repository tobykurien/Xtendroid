package org.xtendroid.xtendroidtest.test

import android.test.AndroidTestCase
import java.util.Date

import android.test.suitebuilder.annotation.MediumTest
import org.xtendroid.parcel.AndroidParcelable
import org.xtendroid.annotations.BundleProperty
import org.xtendroid.app.AndroidActivity
import android.app.Activity
import android.app.Fragment
import org.xtendroid.annotations.AndroidFragment
import android.content.Intent

@AndroidParcelable
class AddMyOwnBlankCtor
{
   new () {}
}

@AndroidParcelable
class UseGeneratedCtor
{
   String meh
}

@AndroidFragment
class TestBundlePropertyFragment extends Fragment
{
   @BundleProperty
   String meh
}

@AndroidActivity
class TestBundlePropertyActivity extends Activity
{
   @BundleProperty
   String meh
}

class TestBundlePropertyPojo // Service ... whateva
{
   val intent = new Intent

   @BundleProperty
   String meh
}

/**
 * Test the Xtendroid database service
 */
@MediumTest
class ParcelableTest extends AndroidTestCase {

   /**
      Issue #96: The generated putXXX() method must first check if getArguments() is null, and if it is, then simply setArguments(new Bundle()). This allows code like this:
    */
   def testAutoCreateBundle()
   {
      val fragment = new TestBundlePropertyFragment
      assertTrue("This fragment will not crash", fragment.arguments != null)
      fragment.putMeh("Meh")

      val activity = new TestBundlePropertyActivity
      assertTrue("This activity will not crash", activity.putMeh("Meh") != null) // chainable by design

      val pojo = new TestBundlePropertyPojo
      assertTrue("", pojo.putMeh("Meh") != null) // chainable by design

   }

   /**
    * Issue #98: The method put(String, Parcelable) is undefined for the type Bundle
    */
   def testPutStringInParcelable() {

   }

   /**
    * Issue #98: @org.xtendroid.parcel.AndroidParcelable forcefully adds a blank constructor and doesn't allow you to add your own
    */
   def testAddMyOwnBlankCtor() {
      assertTrue("Use your own blank Parcelable subtype's ctor", new AddMyOwnBlankCtor != null)
   }

   def testTheGeneratedCtor() {
      assertTrue("Use the generated Parcelable subtype's ctor", new UseGeneratedCtor != null)
   }
}