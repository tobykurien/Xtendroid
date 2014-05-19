package org.xtendroid.xtendroidtest.test;

import android.test.AndroidTestCase;
import android.test.suitebuilder.annotation.SmallTest;
import java.util.ArrayList;
import junit.framework.Assert;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.ExclusiveRange;
import org.json.JSONArray;
import org.json.JSONObject;
import org.xtendroid.xtendroidtest.models.NewsItem;

@SmallTest
@SuppressWarnings("all")
public class JsonTest extends AndroidTestCase {
  public void testJson() {
    try {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("{\"responseData\": ");
      _builder.newLine();
      _builder.append("   ");
      _builder.append("{\"results\":[");
      _builder.newLine();
      _builder.append("   \t\t\t   ");
      _builder.append("{\"url\":\"http://one.com\", \"title\": \"One\", \"id\": 1, \"published\": true}, ");
      _builder.newLine();
      _builder.append("               ");
      _builder.append("{\"url\":\"http://two.com\", \"title\": \"Two\", \"id\": 2, \"published\": true}, ");
      _builder.newLine();
      _builder.append("               ");
      _builder.append("{\"url\":\"http://three.com\", \"title\": \"Three\", \"id\": 3, \"published\": true}, ");
      _builder.newLine();
      _builder.append("               ");
      _builder.append("{\"url\":\"http://four.com\", \"title\": \"Four\", \"id\": 4, \"published\": false} ");
      _builder.newLine();
      _builder.append("   ");
      _builder.append("]}");
      _builder.newLine();
      _builder.append("}\t\t");
      _builder.newLine();
      String json = _builder.toString();
      ArrayList<NewsItem> ret = new ArrayList<NewsItem>();
      JSONObject results = new JSONObject(json);
      JSONObject _jSONObject = results.getJSONObject("responseData");
      JSONArray items = _jSONObject.getJSONArray("results");
      int _length = items.length();
      ExclusiveRange _doubleDotLessThan = new ExclusiveRange(0, _length, true);
      for (final Integer i : _doubleDotLessThan) {
        JSONObject _jSONObject_1 = items.getJSONObject((i).intValue());
        NewsItem _newsItem = new NewsItem(_jSONObject_1);
        ret.add(_newsItem);
      }
      Assert.assertNotNull(ret);
      final ArrayList<NewsItem> _converted_ret = (ArrayList<NewsItem>)ret;
      int _length_1 = ((Object[])Conversions.unwrapArray(_converted_ret, Object.class)).length;
      boolean _equals = (_length_1 == 4);
      Assert.assertTrue(_equals);
      NewsItem _get = ret.get(0);
      String _url = _get.getUrl();
      Assert.assertEquals(_url, "http://one.com");
      NewsItem _get_1 = ret.get(0);
      String _title = _get_1.getTitle();
      Assert.assertEquals(_title, "One");
      NewsItem _get_2 = ret.get(0);
      long _id = _get_2.getId();
      Assert.assertEquals(_id, 1);
      NewsItem _get_3 = ret.get(0);
      boolean _isPublished = _get_3.isPublished();
      Assert.assertEquals(_isPublished, true);
      NewsItem _get_4 = ret.get(3);
      boolean _isPublished_1 = _get_4.isPublished();
      Assert.assertEquals(_isPublished_1, false);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
