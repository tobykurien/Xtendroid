package org.xtendroid.xtendroidtest.models;

import org.eclipse.xtext.xbase.lib.Exceptions;
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
  private String _content;
  
  public String toString() {
    try {
      String _url = this.getUrl();
      String _plus = (_url + "\r\n");
      String _content = this.getContent();
      return (_plus + _content);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
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
  
  public String getContent() throws JSONException {
    return _jsonObj.getString("content");
  }
}
