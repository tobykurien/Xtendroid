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
	
	val String sql
	val Map<String, ? extends Object> values
	val BaseDbService db
	val Class<T> bean
	
	// buffer to hold window of retrieved data
	val List<T> buffer
	
	var private int size
	var int head = 0
	var int tail = 0
	
	new(String sql, Map<String, ? extends Object> values, BaseDbService db, Class<T> bean) {
		this.sql = sql
		this.values = values
		this.db = db	
		this.bean = bean
		
		buffer = new ArrayList<T>(BATCH_SIZE)
		
		// get the size of the data
		var t = new Thread [|
			var res = db.executeForMap("select count(*) as cnt from " + sql, values)
			size = Integer.parseInt(res.get("cnt") as String)
		]
		t.start
		t.join
	}	

	override size() {
		size
	}
	
	
	override isEmpty() {
		size > 0
	}

	/**
	 * NOTE: work in progress, no optimizations yet
	 */
	override get(int idx) {
		if (idx < 0) throw new ArrayIndexOutOfBoundsException('''Index «idx», Size «size»''')
		if (idx >= size) throw new ArrayIndexOutOfBoundsException('''Index «idx», Size «size»''')

		if (idx < head || idx >= tail) {
			head = idx - (BATCH_SIZE/2)
			if (head < 0) head = 0
			tail = idx + (BATCH_SIZE/2)
			loadBatch
		}
		
		if (head <= idx && idx <= tail) {
			// we have the data in our buffer
			return buffer.get(idx - head)
		}		
	}

	def void loadBatch() {
		var t = new Thread [|
			// load the batch we need
			//Log.d("lazylist", "Fetching " + " limit " + head + "," + (tail - head))
			db.executeForBeanList(
				"select * from " + sql + " limit " + head + "," + (tail - head), 
				values, bean, buffer)
		]
		t.start
		t.join
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