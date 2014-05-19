package org.xtendroid.xtendroidtest.test

import android.test.AndroidTestCase
import android.test.suitebuilder.annotation.SmallTest
import java.util.ArrayList
import org.json.JSONObject
import org.xtendroid.xtendroidtest.models.NewsItem

@SmallTest
class JsonTest extends AndroidTestCase {
	def testJson() {
		var json = '''
			{"responseData": 
			   {"results":[
   			   {"url":"http://one.com", "title": "One", "id": 1, "published": true}, 
               {"url":"http://two.com", "title": "Two", "id": 2, "published": true}, 
               {"url":"http://three.com", "title": "Three", "id": 3, "published": true}, 
               {"url":"http://four.com", "title": "Four", "id": 4, "published": false} 
			   ]}
			}		
		'''
		
		var ret = new ArrayList<NewsItem>
		var results = new JSONObject(json)
		var items = results.getJSONObject("responseData").getJSONArray("results")
		for (i: 0..<items.length){
			ret.add(new NewsItem(items.getJSONObject(i)))
		}
		
		assertNotNull(ret)
		assertTrue(ret.length == 4)
		assertEquals(ret.get(0).url, "http://one.com")
		assertEquals(ret.get(0).title, "One")
      assertEquals(ret.get(0).id, 1)
      assertEquals(ret.get(0).published, true)
      assertEquals(ret.get(3).published, false)
	}	
}