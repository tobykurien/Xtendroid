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
import android.os.Parcelable
import android.os.Bundle
import static android.text.TextUtils.*

@AndroidParcelable
class AddMyOwnBlankCtor
{
   String meh
   Parcelable peh
   new () {}
}

@AndroidParcelable
class UseGeneratedCtor
{
   String meh
   Parcelable peh

   // TODO issue #98, temporary bandage, while I fix the other issues
   new () {}
}

@AndroidFragment
class TestBundlePropertyFragment extends Fragment
{
   @BundleProperty
   String meh

   @BundleProperty
   Parcelable addMyOwnBlankCtor

   @BundleProperty
   Parcelable useGeneratedCtor

   // Parcelable subtype test
   @BundleProperty
   UseGeneratedCtor parcelableSubType

   @BundleProperty
   Bundle beh

}

@AndroidActivity
class TestBundlePropertyActivity extends Activity
{
   @BundleProperty
   String meh

   @BundleProperty
   Parcelable addMyOwnBlankCtor

   @BundleProperty
   Parcelable UseGeneratedCtor

   // Parcelable subtype test
   @BundleProperty
   UseGeneratedCtor parcelableSubType

   @BundleProperty
   Bundle beh

}
/*
class TestBundlePropertyPojoWithUndecoratedIntent // Service ... whateva
{
   val intent = new Intent

   @BundleProperty
   String meh

   @BundleProperty
   Parcelable addMyOwnBlankCtor

   @BundleProperty
   Parcelable UseGeneratedCtor

   // Parcelable subtype test
   @BundleProperty
   UseGeneratedCtor parcelableSubType

   @BundleProperty
   Bundle beh

}

class TestBundlePropertyPojoWithUndecoratedBundle
{
   val bundle = new Bundle

   @BundleProperty
   String meh

   @BundleProperty
   Parcelable addMyOwnBlankCtor

   @BundleProperty
   Parcelable UseGeneratedCtor

   // Parcelable subtype test
   @BundleProperty
   UseGeneratedCtor parcelableSubType

   @BundleProperty
   Bundle beh

}

class TestBundlePropertyPojoWithUndecoratedMix
{
   val bundle = new Bundle
   val intent = new Intent

   @BundleProperty
   String meh

   @BundleProperty
   Parcelable addMyOwnBlankCtor

   @BundleProperty
   Parcelable UseGeneratedCtor

   // Parcelable subtype test
   @BundleProperty
   UseGeneratedCtor parcelableSubType

   @BundleProperty
   Bundle beh

}
*/
/**
 * Test the Xtendroid database service
 */
@MediumTest
class ParcelableAndBundlePropertyTest extends AndroidTestCase {

   /**
      Issue #96: The generated putXXX() method must first check if getArguments() is null, and if it is, then simply setArguments(new Bundle()). This allows code like this:
      Fixed. Added a check.
    */
   def testAutoCreateBundleAndPutStuff()
   {
      val fragment = new TestBundlePropertyFragment
      fragment.putMeh("Meh")
      fragment.putBeh(new Bundle)
      assertTrue("This fragment will not crash", fragment.arguments != null)

      val activity = new TestBundlePropertyActivity
      activity.putMeh("Meh")
      assertTrue("This activity will not crash", !activity.meh.isEmpty) // chainable by design

      /*
      // The annotation scan does not work for some reason
      val pojo = new TestBundlePropertyPojoWithUndecoratedIntent
      pojo.putMeh("Meh")
      assertTrue("This pojo will not crash", pojo.meh != null) // chainable by design
      */
   }

   /**
    * Issue #97: @org.xtendroid.parcel.AndroidParcelable forcefully adds a blank constructor and doesn't allow you to add your own
    */
   def testAddMyOwnBlankCtor() {
      assertTrue("Use your own blank Parcelable subtype's ctor", new AddMyOwnBlankCtor != null)
   }

   // TODO this works due to temporary bandage, while I fix the other issues
   def testTheGeneratedCtor() {
      assertTrue("Use the generated Parcelable subtype's ctor", new UseGeneratedCtor != null)
   }

   /**
    * Issue #98: The method put(String, Parcelable) is undefined for the type Parcelable
    * Fixed. I accidentally outcommented a part of the code 2 years ago.
    */
   def testPutParcelableInBundle() {
      val a = new TestBundlePropertyFragment
      a.putAddMyOwnBlankCtor(new AddMyOwnBlankCtor as Parcelable)

      val b = new TestBundlePropertyActivity
      b.putAddMyOwnBlankCtor(new AddMyOwnBlankCtor as Parcelable)

      val intent = new Intent
      val bundle = new Bundle

      val result = new Bundle
      result.putBoolean("bool", true);

      TestBundlePropertyFragment.putBeh(bundle, result)
      TestBundlePropertyFragment.putBeh(intent, result)

      assertTrue("Bundles are not null", bundle.getBundle("beh").getBoolean("bool")
         && intent.getBundleExtra("beh").getBoolean("bool"))

      result.putBoolean("bool", false)

      TestBundlePropertyActivity.putBeh(bundle, result)
      TestBundlePropertyActivity.putBeh(intent, result)

      assertFalse("Bundles are not null", bundle.getBundle("beh").getBoolean("bool"))
      assertFalse("Bundles are not null", intent.getBundleExtra("beh").getBoolean("bool"))


      /*
      (new TestBundlePropertyPojoUndecoratedBundle).putParcelableSubType(new UseGeneratedCtor)
      (new TestBundlePropertyPojoUndecoratedIntent).putParcelableSubType(new UseGeneratedCtor)
      (new TestBundlePropertyPojoUndecoratedMix)   .putParcelableSubType(new UseGeneratedCtor) // TODO check that this doesn't even compile
      */
   }

   def testPutParcelableInBundlePartDeux()
   {
      (new TestBundlePropertyFragment).putParcelableSubType(new UseGeneratedCtor)
      (new TestBundlePropertyActivity).putParcelableSubType(new UseGeneratedCtor)
      /*
      (new TestBundlePropertyPojoUndecoratedBundle).putParcelableSubType(new UseGeneratedCtor)
      (new TestBundlePropertyPojoUndecoratedIntent).putParcelableSubType(new UseGeneratedCtor)
      (new TestBundlePropertyPojoUndecoratedMix)   .putParcelableSubType(new UseGeneratedCtor) // TODO check that this doesn't even compile
      */
   }

}