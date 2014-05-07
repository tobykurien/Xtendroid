package org.xtendroid.utils

import java.util.Date

/**
 * Time functions to make it easier to work with java.util.Date. Example:
 * 
 * import static extension org.xtendroid.utils.TimeUtils.*
 * 
 * var yesterday = 24.hours.ago
 * var tomorrow = 24.hours.fromNow
 * var futureDate = now + 48.days + 20.hours + 2.seconds
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
		new Date(System.currentTimeMillis)
	}

	def static operator_plus(Date date1, Date date2) {
		date1.time + date2.time
	}

	def static operator_minus(Date date1, Date date2) {
		date1.time - date2.time
	}

	def static operator_plus(Date date1, long time2) {
		new Date(date1.time + time2)
	}

	def static operator_plus(long date1, Date time2) {
		new Date(date1 + time2.time)
	}

	def static operator_minus(Date date1, long time2) {
		new Date(date1.time - time2)
	}

	def static operator_minus(long date1, Date time2) {
		new Date(date1 - time2.time)
	}
}
