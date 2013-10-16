package org.xtendroid.utils;

import java.lang.reflect.Method;

@SuppressWarnings("all")
public class Utils {
  /**
   * Convert Java bean getter name into resource name format, i.e.
   * getFirstName -> first_name
   * isToast -> toast
   */
  public static String toResourceName(final Method m) {
    String _xblockexpression = null;
    {
      String name = m.getName();
      String _name = m.getName();
      boolean _startsWith = _name.startsWith("get");
      if (_startsWith) {
        String _name_1 = m.getName();
        String _substring = _name_1.substring(3);
        name = _substring;
      } else {
        String _name_2 = m.getName();
        boolean _startsWith_1 = _name_2.startsWith("is");
        if (_startsWith_1) {
          String _name_3 = m.getName();
          String _substring_1 = _name_3.substring(2);
          name = _substring_1;
        }
      }
      String _resourceName = Utils.toResourceName(name);
      _xblockexpression = (_resourceName);
    }
    return _xblockexpression;
  }
  
  /**
   * Convert from Java-style camel case to resource-style lowercase with underscores, e.g.
   * FirstName -> first_name
   */
  public static String toResourceName(final String name) {
    String _replaceAll = name.replaceAll("(?=[\\p{Lu}])", "_");
    String _lowerCase = _replaceAll.toLowerCase();
    String _replaceAll_1 = _lowerCase.replaceAll("^_", "");
    return _replaceAll_1;
  }
  
  /**
   * Uppercase first letter for using a resource as getter/setter
   */
  public static String upperCaseFirst(final String str) {
    char _charAt = str.charAt(0);
    char _upperCase = Character.toUpperCase(_charAt);
    String _substring = str.substring(1);
    String _plus = (Character.valueOf(_upperCase) + _substring);
    return _plus;
  }
}
