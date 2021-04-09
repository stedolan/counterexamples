# Some kinds of Anything

TAGS: subtyping, polymorphism

In type systems with polymorphism and subtyping, there are four
different meanings that the phrase "any type" could have:

  - **Top type $⊤$**

    The top type is a supertype of every type. Any value can be
    turned into a value of type $⊤$, but given a value of type $⊤$
    there's not much you can do with it.

  - **Bottom type $⊥$**

    The bottom type is a subtype of every type. A value of type $⊥$
    can be turned into a value of any type, but there's no way
    to construct a value of type $⊥$. (If there is, the type system is
    broken. See [Eventually, nothing](eventually-nothing.md) for one
    example).

  - **Universal type $∀α . \; \dots$**

    A value of a universal type $∀α. φ(α)$ can be used at type $φ(X)$,
    for any type $X$. To construct one, the value must typecheck with
    an unknown abstract type $α$.

  - **Existential type $∃α . \; \dots$**

    A value of an existential type $∃α. φ(α)$ can be constructed from
    a value of type $φ(X)$, for any type $X$. To use one, the use must
    typecheck with an unknown abstract type $α$.

There are a couple of relationships between these types:

  - $⊥ = ∀α. α$

    $⊥$ is the type that can be used at any type, but cannot be constructed.

  - $⊤ = ∃α. α$

    $⊤$ is the type that can be constructed from any type, but cannot be used.

In some systems, these relationships extend to more complicated types
as well, for instance with a covariant type $\n{List}[A]$ of immutable
lists with elements of type $A$:

  - $\n{List}[⊥] = ∀α. \n{List}[α]$

    The elements of a single list $l$ cannot simultaneously be of
    every possible type $α$. Such a list must be empty, which is the
    same thing as being a list of $⊥$.

  - $\n{List}[⊤] = ∃α. \n{List}[α]$

    If a list contains elements of an unknown type $α$, then there is
    nothing useful we can do with them. The situtation is the same as
    if we had a list of $⊤$.

The extent to which languages implement these rules varies. Sometimes[^garrigue],
they are used to justify converting $List[⊥]$ to
$∀α.List[α]$. Sometimes[^mlsub], they are used to justify considering those
two as different spellings of the same type. Other times, they are not
used, but are definable in the language.

However, if implementing these rules it is crucial to keep track of
variance. Consider the type $∃α. (\n{List}[α] → \n{Int})$: this is a
function that accepts lists of some particular unknown type. It could
be, for instance, the $\n{sum}$ function of type $\n{List}[\n{Int}] →
\n{Int}$.

It is unsound to treat this the same as $\n{List}[⊤] → \n{Int}$,
as that would allow us to pass a list of, say, strings to the
$\n{sum}$ function. In fact, since all of the occurrences of $α$ are
contravariant (that is, to the left of a single function arrow), this
type is equivalent to $\n{List}[⊥] → \n{Int}$.

Scala supports subtyping and polymorphism, and several versions of the
language[^scala1][^scala2] had this soundness issue, where $∃α. φ(α)$ was converted to
$φ(⊤)$ (spelled $φ(\n{Any})$ in Scala), without regard for the variance
of $φ$.
```scala
// Counterexample by Paul Chiusano
/* The 'coinductive' view of streams, represented as their unfold. */
trait Stream[+A]
case class Unfold[S,+A](s: S, f: S => Option[(A,S)]) extends Stream[A]

object Stream {
  def fromList[A](a: List[A]): Stream[A] = 
    Unfold(a, (l:List[A]) => l.headOption.map((_,l.tail)))
}

/* If I have a Stream[Int], and I match and obtain an Unfold(s, f),
   the type of (s,f) should be (S, S => Option[(A,S)]) forSome { type S }.
   But Scala just promotes everything to Any: */
val res0 = Stream.fromList(List(1,2,3,4))
val res1 = res0 match { case Unfold(s, f) => s }
// res1: Any = List(1, 2, 3, 4)

/* Notice that the type of s is Any.
   Likewise, the type of f is also wrong, it accepts an Any: */

val res2 = res0 match { case Unfold(s, f) => f }
// res2: Any => Option[(Int, Any)] = <function1>

/* Since f expects Any, we can give it a String and get a runtime error: */

res0 match { case Unfold(s, f) => f("a string!") } // crashes
```


[^garrigue]: [Relaxing the Value Restriction](https://caml.inria.fr/pub/papers/garrigue-value_restriction-fiwflp04.pdf), Jacques Garrigue (2004)

[^mlsub]: [Polymorphism, subtyping, and type inference in MLsub](https://dl.acm.org/doi/abs/10.1145/3009837.3009882), Stephen Dolan and Alan Mycroft (2017)

[^scala1]: <https://github.com/scala/bug/issues/5189> (2011)

[^scala2]: <https://github.com/scala/bug/issues/6680> (2012)
