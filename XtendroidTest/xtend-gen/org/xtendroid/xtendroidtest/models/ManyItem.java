package org.xtendroid.xtendroidtest.models;

import java.util.Date;

@SuppressWarnings("all")
public class ManyItem {
  private long _id;
  
  public long getId() {
    return this._id;
  }
  
  public void setId(final long id) {
    this._id = id;
  }
  
  private Date _createdAt;
  
  public Date getCreatedAt() {
    return this._createdAt;
  }
  
  public void setCreatedAt(final Date createdAt) {
    this._createdAt = createdAt;
  }
  
  private String _itemName;
  
  public String getItemName() {
    return this._itemName;
  }
  
  public void setItemName(final String itemName) {
    this._itemName = itemName;
  }
  
  private long _itemOrder;
  
  public long getItemOrder() {
    return this._itemOrder;
  }
  
  public void setItemOrder(final long itemOrder) {
    this._itemOrder = itemOrder;
  }
}
