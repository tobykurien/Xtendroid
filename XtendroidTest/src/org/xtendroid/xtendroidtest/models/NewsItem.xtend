package org.xtendroid.xtendroidtest.models

import org.xtendroid.json.AndroidJson

@AndroidJson class NewsItem {
	String url
	String title
	long id
	boolean published
}