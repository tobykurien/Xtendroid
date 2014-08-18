package org.xtendroid.xtendroidtest.json

import org.xtendroid.json.AndroidJson
import java.util.Date
import java.util.List

@AndroidJson
class AndroidJsonTest1 {
	Date date
	
	Date[] dateArray
	
	List<Date> dateList
}

class AndroidJsonTest2 {
	@AndroidJson
	Date date
	
	@AndroidJson
	Date[] dateArray
	
	@AndroidJson
	List<Date> dateList
}