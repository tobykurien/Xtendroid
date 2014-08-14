Work in progress
================

- [Enum types](#enum-types)

Enum types
----------

The `@EnumProperty` annotation allows you to generate enum types or reuse pre-defined enum types, and generates the convenience methods to convert Strings to enum types.

Like this:

```xtend
enum ABCEnum {
   a,b,c
}

class MyBean {
   @EnumProperty(enumType=ABCEnum) // pre-defined
   var String alpha

   @EnumProperty(name="DEFEnum", values=#["d","e","f"])
   var String delta
}
```

Now you can use the generated methods as extension methods:

```xtend
alpha = ABCEnum.a.toString
delta = DEFEnum.d.toString

assertEquals(DEFEnum.toDEFEnumValue(delta), DEFEnum.d)
```

This is especially handy when you're converting string to enums, e.g. from a JSON object.
