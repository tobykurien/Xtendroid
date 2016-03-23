package org.xtendroid.xtendroidtest.models

import java.util.Date
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class ManyItem {
	long id
	Date createdAt
	String itemName
	long itemOrder
}