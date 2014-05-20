package org.xtendroid.xtendroidtest.models;

import org.json.JSONException;
import org.json.JSONObject;
import org.xtendroid.json.JsonProperty;

@SuppressWarnings("all")
public class NewsItem {
  @JsonProperty
  private String _url;
  
  @JsonProperty
  private String _title;
  
  @JsonProperty
  private long _id;
  
  @JsonProperty
  private boolean _published;
  
  protected final JSONObject _jsonObj;
  
  public NewsItem(final JSONObject jsonObj) {
    this._jsonObj = jsonObj;
  }
  
  protected Boolean _urlLoaded = false;
  
  public String getUrl() throws JSONException {
    if (!_urlLoaded) {
       _url = _jsonObj.getString("url");
       _urlLoaded = true;
    }
    return _url;
  }
  
  protected Boolean _titleLoaded = false;
  
  public String getTitle() throws JSONException {
    if (!_titleLoaded) {
       _title = _jsonObj.getString("title");
       _titleLoaded = true;
    }
    return _title;
  }
  
  protected Boolean _idLoaded = false;
  
  public long getId() throws JSONException {
    if (!_idLoaded) {
       _id = _jsonObj.getLong("id");
       _idLoaded = true;
    }
    return _id;
  }
  
  protected Boolean _publishedLoaded = false;
  
  public boolean isPublished() throws JSONException {
    if (!_publishedLoaded) {
       _published = _jsonObj.getBoolean("published");
       _publishedLoaded = true;
    }
    return _published;
  }
}
