package org.xtendroid.db

import java.util.ArrayList
import java.util.Collection
import java.util.List
import java.util.Map

/**
 * An List that lazily loads items from a query and loads a batch of beans
 * at-a-time. This is ideal for an Adapter that can scroll through an infinite list 
 * of items from the database, without running out of memory. Multi-threading is also 
 * handled, so that queries are not performed on the UI thread, even if called from the 
 * UI Thread.
 */
class LazyList<T> implements List<T> {
	// How many items to load in each batch fetch
	val static int BATCH_SIZE = 100
	// How close to the edge of a window to get before pre-fetching nearest window
	val static int WINDOW_PREFETCH_THRESHOLD = BATCH_SIZE/20
	
	val String sql
	val Map<String, ? extends Object> values
	val BaseDbService db
	val Class<T> bean
	
	// buffers to hold window of retrieved data
	val List<T> bufPrev
	val List<T> bufCurrent
	val List<T> bufNext
	val int size
	var int head = 0
	var int tail = 0
	
	new(String sql, Map<String, ? extends Object> values, BaseDbService db, Class<T> bean) {
		this.sql = sql
		this.values = values
		this.db = db	
		this.bean = bean
		
		bufPrev = new ArrayList<T>(BATCH_SIZE)
		bufCurrent = new ArrayList<T>(BATCH_SIZE)
		bufNext = new ArrayList<T>(BATCH_SIZE)
		
		// get the size of the data
		var res = db.executeForMap("select count(*) as cnt from " + sql, values)
		size = Integer.parseInt(res.get("cnt") as String)
	}	

	override size() {
		size
	}
	
	
	override isEmpty() {
		size > 0
	}

	override get(int idx) {
		if (idx <= (head - WINDOW_PREFETCH_THRESHOLD)) {
			// prefetch previous data
		}
		
		if (idx >= (head + WINDOW_PREFETCH_THRESHOLD)) {
			// prefetch next data
		}
		
		if (head == tail) {
			// we need to load the data
			head = idx
			tail = idx + BATCH_SIZE
			var data = db.executeForBeanList("select * from " + sql, values, bean)
			bufCurrent.clear
		   for(b: data) {
		   	bufCurrent.add(b)
		   }
		}
		
		if (idx >= head && idx <= tail) {
			// we have the data
			return bufCurrent.get(idx - head)
		}
	}
	
	/* ------- The following methods are unsupported ------------ */	
	override add(T arg0) {
		throw new UnsupportedOperationException("Operation not supported for LazyList")
	}
	
	override add(int arg0, T arg1) {
		throw new UnsupportedOperationException("Operation not supported for LazyList")
	}
	
	override addAll(Collection<? extends T> arg0) {
		throw new UnsupportedOperationException("Operation not supported for LazyList")
	}
	
	override addAll(int arg0, Collection<? extends T> arg1) {
		throw new UnsupportedOperationException("Operation not supported for LazyList")
	}
	
	override clear() {
		throw new UnsupportedOperationException("Operation not supported for LazyList")
	}
	
	override contains(Object arg0) {
		throw new UnsupportedOperationException("Operation not supported for LazyList")
	}
	
	override containsAll(Collection<?> arg0) {
		throw new UnsupportedOperationException("Operation not supported for LazyList")
	}

	override indexOf(Object arg0) {
		throw new UnsupportedOperationException("Operation not supported for LazyList")
	}
		
	override iterator() {
		throw new UnsupportedOperationException("Operation not supported for LazyList")
	}
	
	override lastIndexOf(Object arg0) {
		throw new UnsupportedOperationException("Operation not supported for LazyList")
	}
	
	override listIterator() {
		throw new UnsupportedOperationException("Operation not supported for LazyList")
	}
	
	override listIterator(int arg0) {
		throw new UnsupportedOperationException("Operation not supported for LazyList")
	}
	
	override remove(int arg0) {
		throw new UnsupportedOperationException("Operation not supported for LazyList")
	}
	
	override remove(Object arg0) {
		throw new UnsupportedOperationException("Operation not supported for LazyList")
	}
	
	override removeAll(Collection<?> arg0) {
		throw new UnsupportedOperationException("Operation not supported for LazyList")
	}
	
	override retainAll(Collection<?> arg0) {
		throw new UnsupportedOperationException("Operation not supported for LazyList")
	}
	
	override set(int arg0, T arg1) {
		throw new UnsupportedOperationException("Operation not supported for LazyList")
	}
	
	override subList(int arg0, int arg1) {
		throw new UnsupportedOperationException("Operation not supported for LazyList")
	}
	
	override toArray() {
		throw new UnsupportedOperationException("Operation not supported for LazyList")
	}
	
	override <T> toArray(T[] arg0) {
		throw new UnsupportedOperationException("Operation not supported for LazyList")
	}
	
}