# Privacy violation

With declaration-site variance (see [Covariant
containers](covariant-containers.md)), a generic class can be declared
to be covariant in its type parameter, as long as the type parameter
is only used in output positions:
```csharp
class Box<+X> {
  // allowed, X is an output (covariant)
  public X get() { ... }

  // disallowed, X is an input (contravariant)
  public void set(X x) { ... }
}
```

Since variance checking is verifying subtyping, a property of the
public interface to a class, it should in principle be fine to allow
methods that use `X` contravariantly (like `set` above), provided that
they are marked `private` and therefore do not form part of the
interface.

Whether or not this is sound hinges on exactly what the `private`
modifier means: is it private to the _object_ or private to the
_class_? Conventionally, many object-oriented languages choose
class-private, allowing access to private fields of an object of class
`A` from any method of class `A`, regardless of whether the object
being accessed was `this` or any other.

Choosing class-private makes the private variance check unsound, as
pointed out by Emir et al.[^csharp] in their paper introducing
declaration-site variance for C#. (The same issue later reappeared in
Hack[^hack]).
```csharp
// Counterexample by Emir et al.
class Bad<+X> {
  private X item;
  public void BadAccess(Bad<string> bs) {
    Bad<object> bo = bs;
    bo.item = new Button(); // we just wrote a button as a string
  }
}
```
```hack
// Counterexample by Andrew Kennedy
class Box<+T> {
  // OK, we've got a private field whose type involves the covariant T
  public function __construct(private T $elem) {
  }

  // As usual, a (safe) getter method
  public function get(): T { return $this->elem; }

  // Private gives us access to arbitrary instances of Box, even in static
  // methods. Note the use of covariant subtyping to put a string in
  // a Box<mixed>
  public static function updateAsString(Box<mixed> $x, string $s) : void {
    $x->elem = $s;
  }

  // We can now use this method to overwrite an integer with a string
  // but return it as an integer
  public static function morphIntToString(int $i) : int {
    $x = new Box($i);
    Box::updateAsString($x, 'hey you turned me into a string');
    return $x->get();
  }

  // Actually do it
  public static function useBox(): void {
    $i = Box::morphIntToString(23);
    echo('this should be an integer: ' . $i);
  }
}
```

Scala supports both `private` (class-private) and `private[this]`
(object-private), with different variance checking. It also supports
`protected[this]`, an "object-protected" qualifier in which a field is
accessible only via `this`, but both by the class itself and its
subclasses.

Scala's `protected[this]` has the same variance-checking as
`private[this]`, allowing non-covariant uses of a type parameter in a
`protected[this]` field, even from within a class marked as
covariant. This is an extraordinarily subtle feature, and Scala's
current implementation has a number of soundness issues.

First, Scala supports a form of multiple inheritance via "traits". A
class can inherit from a covariant trait in multiple ways, and the two
copies of the trait's interface are merged. This merging can be justified by
covariance, but `protected[this]` allows classes to provide
non-covariant features to subclasses. This is unsound, as different
traits in the inheritance heirarchy can see different values of the
type parameter in non-covariant ways[^scala1]:

```scala
// Counterexample by Jason Zaugg
trait A[+X] {
  protected[this] def f(x: X): X = x
}

trait B extends A[B] {
  def kaboom = f(new B {})
}

// protected[this] disables variance checking
// of the signature of `f`.
//
// C's parent list unifies A[B] with A[C]
//
// The protected[this] loophole is widely used
// in the collections, every newBuilder method
// would fail variance checking otherwise.
class C extends B with A[C] {
  override protected[this] def f(c: C) = c
}

// java.lang.ClassCastException: B$$anon$1 cannot be cast to C
//  at C.f(<console>:15)
new C().kaboom
```

Second, Scala allows `protected[this]` to apply also to abstract type
members, which can be exposed by a subclass[^scala2]:
```scala
// Counterexample by Derek Lam
abstract class Base[+T] {
  protected[this] type TSeq <: MutableList[T]
  val v: TSeq
}

class Sub extends Base[Int] {
  type TSeq = MutableList[Int]
  val v = MutableList(42)
}

val x = new Sub()
(x: Base[Any]).v += "string!"
x.v.last + 42
// java.lang.ClassCastException: java.lang.String cannot be cast to java.lang.Integer
```

[^csharp]:
[Variance and Generalized Constraints for C# Generics](https://www.microsoft.com/en-us/research/publication/variance-and-generalized-constraints-for-c-generics/) (ECOOP '06), 
Burak Emir, Andrew Kennedy, Claudio Russo, Dachuan Yu (2006)

[^hack]: <https://github.com/facebook/hhvm/issues/7216#issuecomment-235726828> (2016)

[^scala1]: <https://github.com/scala/bug/issues/7093> (2013)

[^scala2]: <https://github.com/scala/scala-dev/issues/370> (2017)