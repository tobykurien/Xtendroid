package org.xtendroid.xtendroidtest.test;

import android.test.AndroidTestCase;
import com.google.common.base.Objects;
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
    Date date3 = new Date();
    long _hours_3 = org.xtendroid.utils.TimeUtils.hours(2);
    Date date4 = org.xtendroid.utils.TimeUtils.operator_plus(date3, _hours_3);
    long _time = date4.getTime();
    Date date5 = new Date(_time);
    long _time_1 = date3.getTime();
    long _time_2 = date4.getTime();
    long _minus_2 = (_time_1 - _time_2);
    long _hours_4 = org.xtendroid.utils.TimeUtils.hours(2);
    long _minus_3 = (-_hours_4);
    Assert.assertEquals(_minus_2, _minus_3);
    boolean _equals = Objects.equal(date4, date5);
    Assert.assertTrue(_equals);
  }
}
