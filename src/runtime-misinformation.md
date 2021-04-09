# Runtime type misinformation

TAGS: typecase

The typing judgement $e : A$ is a static, syntactic judgement based on
the syntax of $e$ and $A$. Sometimes, it would be useful to have a
runtime counterpart, allowing expressions like $e \;?\; A$ which
evaluate to `true` if at runtime the expression $e$ evaluates to a
value of type $A$. This "$?$" operator goes by various names, including
`typecase` and `instanceof`.

In any but the simplest type systems, this is fraught with
difficulties.  The trouble is that advanced type systems can make
finer distinctions than are visible at runtime, so the runtime type
check has incomplete information.

For example, using `newtype` in Haskell it is possible to define a
type `EscapedString` as a new type based on `String`:
```haskell
newtype EscapedString = EscapedString String
```

Crucially, unlike type aliases (`type` in Haskell, or `typedef` in
C/C++) the two types `String` and `EscapedString` are distinct for
type checking purposes, causing a type error whenever one is used
where the other is expected and ensuring that a forgotten escaping or
unescaping causes a compile failure.

This extra checking has no runtime cost, because `newtype`s in Haskell
(and opaque types in ML, and similar features) introduce no extra
wrappers: the `String` and `EscapedString` have the same
representation.

This is fundamentally incompatible with typecase. The expression `e ?
EscapedString` cannot be expected to return `true` on escaped strings
and `false` on unescaped ones, because at runtime there is no
distinction between them. The situation gets even worse with more
advanced type systems, since whether $e$ has type $A$ may not even be
decidable at runtime.

It is possible to mix typecase with advanced type systems by limiting
the typecase operator to those types for which sufficient runtime
information is available, either by distinguishing static types from
dynamic tags (e.g. ML's `exn`, OCaml's open types), or by specifying
the subset of static types that have dynamically-checkable
representations (e.g. Haskell's `Typeable`, Scala's "checkable types").

When this is not done carefully, unsoundness results, in which a
runtime tests identifies two types that are statically known to be
distinct. This problem has occurred in Scala[^scala] (where the types
checked in patterns did not always match the static ones) and some
cases remain in Dotty[^dotty]. The problem also occurs in Hack[^hhvm]
(where information about generics was erased at runtime, so typecase
returned `true` if asked whether a list of ints was a `List<string>`),
in Flow[^flow] (which also performs typecase on erased generics),
and in Kotlin[^kotlin] (where inner classes share runtime information,
even if they depend on generic parameters that may vary).

Java has an issue similar to those in Hack and Kotlin, where
`instanceof` checks ignore generic parameters, but avoids unsoundness
by limiting which classes can be used for comparison.

```scala
// Counterexample by David R. MacIver
object Test extends Application {
    case class L();
    object N extends L();

    def empty(xs : L) : Unit = xs match {
        case x@N => println(x); println(x);
    }

    empty(L())
}
/*
The compiler inserts a cast of xs to N.type, which is unsound:
The pattern match will succeed for any L, because N == L().
*/
```
```hack
// Counterexample by Andrew Kennedy
function mycast<T>(mixed $x, classname<T> $t) : T {
  if ($x instanceof $t) { return $x; }
  else throw new Exception("Type didn't match");
}
function expectListOfString(List<string> $x) { ... }

// If I write expectListOfString(mycast($y, List::class))
// but with $y having type List<int> then no exception will
// get thrown at runtime (because of generics erasure).
```
```flow
// Counterexample by William Chargin
// @flow
class Box<T> {
  +field: T;
  constructor(x) {
    this.field = x;
  }
}

function asBox<T>(x: T | Box<T>): Box<T> {
  if (x instanceof Box) {
    // Here, `x` is refined to be `Box<T>`. This is unsound: `T` could
    // well be `Box<U>` for some other `U`. Example below.
    return x;
  } else {
    // whatever
    return new Box(x);
  }
}

const stringStringBox: Box<Box<string>> = asBox(new Box("wat"));  // unsound!
stringStringBox.field.field.substr(0);  // runtime error
```
```kotlin
// Counterexample by Vladimir Reshetnikov
class A<T>(var value: T) {
    fun replaceValue(x: Any) : Any {
        class C(var v: T)
        if(x is C) {
            value = x.v
            return x
        }

        return C(value)
    }
}

fun main(args: Array<String>) {
    val a = A("string")
    a.replaceValue(A(0).replaceValue("something not of type C"))

    // a.value has type String, but now contains integer 0
    val s = a.value // crashes
}
```
```java
// This function would do an unsound conversion from Integer to String
// because the cls.cast always passes: it's only checking List
static String bad(Class<List<String>> cls) {
    List<Integer> i = Arrays.asList(42);
    List<String> badList = cls.cast(i);
    String badString = badList.get(0);
    return badString;
}

// But Java provides no way to get a Class<List<String>>.
// (Arrays.asList("a").getClass() is a Class<? extends List>)
```

[^scala]: <https://github.com/scala/bug/issues/1503> (2008)

[^dotty]: <https://github.com/lampepfl/dotty/issues/9359> (2020)

[^hhvm]: <https://github.com/facebook/hhvm/pull/7632> (2017)

[^flow]: <https://github.com/facebook/flow/issues/6741> (2018)

[^kotlin]: <https://youtrack.jetbrains.com/issue/KT-9584> (2015)
