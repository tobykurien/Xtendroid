package org.xtendroid.utils

import java.util.Date

/**
 * Time functions to make it easier to work with java.util.Date. Example:
 * 
 * import static extension org.xtendroid.utils.TimeUtils.*
 * 
 * var myDate = 3.days.ago
 * var tomorrow = 1.day.fromNow
 * System.out.println(myDate)
 */
class TimeUtils {
   def public static second(long value) {
      seconds(value)
   }
      
   def public static seconds(long value) {
      value * 1000
   }

   def public static minute(long value) {
      minutes(value)
   }
   
   def public static minutes(long value) {
      value * 1000 * 60
   }

   def public static hour(long value) {
      hours(value)
   }
   
   def public static hours(long value) {
      value * 1000 * 60 * 60
   }

   def public static day(long value) {
      days(value)
   }

   def public static days(long value) {
      value * 1000 * 60 * 60 * 24
   }

   def public static week(long value) {
      weeks(value)
   }

   def public static weeks(long value) {
      value * 1000 * 60 * 60 * 24 * 7
   }

   def public static ago(long valueMs) {
      new Date(System.currentTimeMillis - valueMs)
   }

   def public static fromNow(long valueMs) {
      new Date(System.currentTimeMillis + valueMs)
   }
   
   def public static now() {
      System.currentTimeMillis
   }
}