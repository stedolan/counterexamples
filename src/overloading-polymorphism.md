# Overloading and polymorphism

TAGS: polymorphism, overloading

Polymorphism allows a single method to work with an arbitrary,
unknown type, while overloading allows one of multiple methods to be
selected by examining the types of the parameters. With overloading,
the parameter types become part of the name of the method. With
polymorphism, the parameter types might not be known.

The two features are in direct conflict, because the information that
overloading requires is unavailable in a polymorphic context. Attempts
to combine them are tricky, as this counterexample in Java[^java]
shows:
```java
// Counterexample by Hiromasa Kido
class A{
       public int compareTo(Object o){ return 0; }
}
class B extends A implements Comparable<B>{
       public int compareTo(B b){ return 0; }
       public static void main(String[] argv){
               System.out.println(new B().compareTo(new Object()));
       }
}
```

On earlier versions of Java, this program crashed with a
`ClassCastException`, despite containing no casts. The issue is that
in order to implement `B`'s `compareTo(B)`, the compiler inserts a
"bridge method" `compareTo(Object)` containing a cast to `B`. The
bridge method is necessary because
the `compareTo` method is specified by `Comparable`, and other users
of the `Comparable` interface will select the `compareTo(Object)`
overload, as they do not necessarily know about `B`.  However, this
bridge method accidentally overrides `A`'s `compareTo(Object)` method,
and gets called from `main` instead, and the cast
fails.

In current Java, bridge methods still exist, but the program
above is rejected.

Scala[^scala] suffers a related issue, also caused by an
interaction of overloading and polymorphism. Scala allows a mixture of
structural and nominal typing. An object can be given a structural
type that exposes only some of its capabilities, including exposing
only special cases of polymorphic methods:
```scala
// Counterexample by Paul Phillips
object Test {
  class MyGraph[V <: Any] {
    def addVertex(v: V): Boolean = true
  }

  type DuckGraph = {
    def addVertex(vertex: Int): Boolean
  }
  
  def fail(graph: DuckGraph) = graph addVertex 1

  def main(args: Array[String]): Unit = {
    fail(new MyGraph[Int])
  }
}
```
However, overloading causes this program to fail, by attempting to find a
nonexistent `addVertex(Int)` method, even though the underlying polymorphic method has
signature `addVertex(Object)`.


[^java]: [Java generics unsoundness?](http://lists.seas.upenn.edu/pipermail/types-list/2006/001091.html)
 (TYPES mailing list), Eijiro Sumii (2006)

[^scala]: <https://github.com/scala/bug/issues/2672> (2009)