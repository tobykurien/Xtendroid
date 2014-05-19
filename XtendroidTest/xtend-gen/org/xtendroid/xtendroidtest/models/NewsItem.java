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
  
  public String getUrl() throws JSONException {
    return _jsonObj.getString("url");
  }
  
  public String getTitle() throws JSONException {
    return _jsonObj.getString("title");
  }
  
  public long getId() throws JSONException {
    return _jsonObj.getLong("id");
  }
  
  public boolean isPublished() throws JSONException {
    return _jsonObj.getBoolean("published");
  }
}
