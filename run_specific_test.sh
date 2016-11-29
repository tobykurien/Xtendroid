#!/bin/sh

# Compile and run a specific test from XtendroidTestCases 
# e.g. ./run_specific_test.sh JsonTest

./gradlew -q XtendroidTest:assembleDebug XtendroidTest:installDebugAndroidTest && 
   adb shell am instrument -w -e debug false -e class org.xtendroid.xtendroidtest.test.$1 org.xtendroid.xtendroidtest.test/android.support.test.runner.AndroidJUnitRunner
