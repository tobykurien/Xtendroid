#!/bin/sh
adb shell am instrument -w -e debug false -e class org.xtendroid.xtendroidtest.test.$1 org.xtendroid.xtendroidtest.test/android.support.test.runner.AndroidJUnitRunner

