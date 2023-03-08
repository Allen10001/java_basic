# Reflections library 学习笔记

# 官网

https://github.com/ronmamo/reflections

## Java runtime metadata analysis

Reflections scans and indexes your project's classpath metadata, allowing reverse transitive query of the type system on runtime.

Using Reflections you can query for example:

- Subtypes of a type
- Types annotated with an annotation
- Methods with annotation, parameters, return type
- Resources found in classpath
  And more...

Note that:

- **Scanner must be configured in order to be queried, otherwise an empty result is returned**
  If not specified, default scanners will be used SubTypes, TypesAnnotated.
  For all standard scanners use `Scanners.values()`. See more scanners in the source [package](https://ronmamo.github.io/reflections/org/reflections/scanners).
- **All relevant URLs should be configured**
  Consider `.filterInputsBy()` in case too many classes are scanned.
  If required, Reflections will [expand super types](https://ronmamo.github.io/reflections/org/reflections/Reflections.html#expandSuperTypes(java.util.Map)) in order to get the transitive closure metadata without scanning large 3rd party urls.
- Classloader can optionally be used for resolving runtime classes from names.







