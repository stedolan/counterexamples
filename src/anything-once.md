# Any (single) thing

When typechecking a language with polymorphism (generics), it is
usually up to the compiler to fill in the type parameters when a
polymorphic function / generic method is called.  For instance, given
polymorphic function `id` of type $∀α. α → α$, it can equally be
called as `id(5)` and `id("hello")`, and the compiler will work out
the correct value of $α$ in both cases.

However, for any single call to `id` there is only one $α$ to choose,
and the compiler must choose consistently. The expression `id("hello")
+ 5` is a type error, even though instantiating $α$ to `string` and
`int` are both fine.

In practice, this means that whenever the compiler chooses a type
parameter it must record that choice and check compatibility with any
other use of the parameter. Early versions of Generic Java[^java] and certain
versions of Scala[^scala] failed to do this in all cases, leading to unsoundness.

```java
// Counterexample by Alan Jeffrey
public class Problem {
    // This code compiles, but produces a ClassCastException when executed
    // even though there are no explicit casts in the program.
    
    public static void main (String [] args) {
        Integer x = new Integer (5);
        String y = castit (x);
        System.out.println (y);
    }

    static <A,B> A castit (B x) {
        // This method casts any type to any other type.
        // Oh dear.  This shouldn't type check, but does
        // because build () returns a type Ref<*>
        // which is a subtype of RWRef<A,B>.
        final RWRef<A,B> r = build ();
        r.set (x);
        return r.get ();
    }

    static <A> Ref<A> build () {
        return new Ref<A> ();
    }
}

interface RWRef<A,B> {
    public A get ();
    public void set (B x);
}

class Ref<A> implements RWRef <A,A> {
    A contents;
    public void set (A x) { contents = x; }
    public A get () { return contents; }
}
```
```scala
// Counterexample by Stephen Compall
trait Magic {
  type S
  def init: S
  def step(s: S): String
}

case class Pair[A](left: A, right: A)

object Main extends App {
  type Aux[A] = Magic {type S = A}

  // I can't call this one from outerd,
  def outertp[A](p: Pair[Aux[A]]) =
    p.right.step(p.left.init)

  // but I can call this one.
  def outere(p: Pair[Aux[E]] forSome {type E}) =
    outertp(p)

  // This one means the left and the right may have *different* S.  I
  // shouldn't be able to call outere with p.
  def outerd(p: Pair[Magic]) =
    outere(p)

  def boom =
    outerd(Pair(new Magic {
                  type S = String
                  def init = "hi"
                  def step(s: S) = s.reverse
                },
                new Magic {
                  type S = Int
                  def init = 42
                  def step(s: S) = (s - 3).toString
                }))
  boom
}
```

[^java]: [Generic Java type inference is unsound](https://www.seas.upenn.edu/~sweirich/types/archive/1999-2003/msg00849.html) (TYPES mailing list), Alan Jeffrey (2001)

[^scala]: <https://github.com/scala/bug/issues/9410> (2015)
