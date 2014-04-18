package org.xtendroid.xtendroidtest.models;

import java.util.Date;

@SuppressWarnings("all")
public class User {
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
  
  private String _firstName;
  
  public String getFirstName() {
    return this._firstName;
  }
  
  public void setFirstName(final String firstName) {
    this._firstName = firstName;
  }
  
  private String _lastName;
  
  public String getLastName() {
    return this._lastName;
  }
  
  public void setLastName(final String lastName) {
    this._lastName = lastName;
  }
  
  private String _userName;
  
  public String getUserName() {
    return this._userName;
  }
  
  public void setUserName(final String userName) {
    this._userName = userName;
  }
  
  private boolean _active;
  
  public boolean isActive() {
    return this._active;
  }
  
  public void setActive(final boolean active) {
    this._active = active;
  }
  
  private Date _expiryDate;
  
  public Date getExpiryDate() {
    return this._expiryDate;
  }
  
  public void setExpiryDate(final Date expiryDate) {
    this._expiryDate = expiryDate;
  }
}
