package org.xtendroid.xtendroidtest.models

import org.xtendroid.json.JsonProperty

class NewsItem {
	@JsonProperty String url
	@JsonProperty String title
	@JsonProperty long id
	@JsonProperty boolean published
}