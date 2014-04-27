package org.xtendroid.xtendroidtest.test;

import android.test.AndroidTestCase;
import java.util.Date;
import junit.framework.Assert;

@SuppressWarnings("all")
public class TimeUtils extends AndroidTestCase {
  public void testOne() {
    Date date1 = org.xtendroid.utils.TimeUtils.now();
    Date _now = org.xtendroid.utils.TimeUtils.now();
    long _hours = org.xtendroid.utils.TimeUtils.hours(24);
    Date date2 = org.xtendroid.utils.TimeUtils.operator_plus(_now, _hours);
    long _minus = org.xtendroid.utils.TimeUtils.operator_minus(date2, date1);
    long _hours_1 = org.xtendroid.utils.TimeUtils.hours(24);
    Assert.assertEquals(_minus, _hours_1);
    long _hour = org.xtendroid.utils.TimeUtils.hour(1);
    Date _minus_1 = org.xtendroid.utils.TimeUtils.operator_minus(date2, _hour);
    long _hours_2 = org.xtendroid.utils.TimeUtils.hours(23);
    Date _plus = org.xtendroid.utils.TimeUtils.operator_plus(date1, _hours_2);
    Assert.assertEquals(_minus_1, _plus);
  }
}
