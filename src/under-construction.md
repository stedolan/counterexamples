# Objects under construction

TAGS: mutation

There are two common styles for creating a new object or record. In
the first style, common in functional languages, the programmer
creates a new record by specifying the value of all of its fields in a
single expression:
```ocaml
type t = { foo : int; bar : string }
let make () = { foo = 42; bar = "hello" }
```

In the second style, common in imperative and object-oriented
languages, the programmer creates a new record by first allocating a
blank record, and then filling its fields in one-by-one using
mutation:
```c
struct t { int foo; const char* bar; };
struct t* x = malloc(sizeof(struct t));
x->foo = 42;
x->bar = "hello";
```
```java
class T {
  int foo;
  String bar;
  T () { this.foo = 42; this.bar = "hello"; }
}
```

In the first style, the record is fully constructed as soon as it is
available, and no intermediate states are visible. By contrast, the
second style allows intermediate states to be observed, which can have
confusing or unsound consequences.

For instance, Java allows fields to be marked `final`, which disallows
non-constructor assignments to the field, as in the following class:
```java
class A {
  private final int x;
  public void printX() { System.out.println(x); }
  public A () { printX(); this.x = 42; printX(); }
}
```

A Java programmer might believe that the `printX` method will always
print the same value, but this is not the case as it may be invoked
while the object is still under construction.

This caused a soundness issue in Kotlin's non-null checking[^kotlin], when a
non-nullable field was observed to be null during initialisation.

```kotlin
// Counterexample by Joshua Rosen
class Foo {
    val nonNull: String

    init {
        this.crash()
        nonNull = "Initialized"
    }

    fun crash() {
        nonNull.startsWith("foo") // crashes
    }
}

fun main(args: Array<String>) {
    Foo()
}
```

In Java, it's additionally possible for `final` fields to never be
initialised, because a reference to an uninitialised object can leak
out via an exception:
```java
class Ex extends RuntimeException {
    public Object o;
    public Ex(Object a) { this.o = a; }
    static int leak(Object x) { throw new Ex(x); }
}

class A {
    public final int leak = Ex.leak(this);
    public final int thing = Integer.parseInt("42");
}

public class Test {
    static A make() {
        try {
            return new A();
        } catch (Ex x) {
            return (A)x.o;
        }
    }
    public static void main(String []args){
       A a = make();
       // a is uninitialised: its 'thing' field is zero
       System.out.println(a.thing);
    }
}
```


[^kotlin]: <https://youtrack.jetbrains.com/issue/KT-10455> (2015)