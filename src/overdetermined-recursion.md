# Overdetermined recursion

TAGS: recursive-types

While the previous example ([Underdetermined
recursion](underdetermined-recursion.md)) was concerned with recursive
type defintions that have multiple valid interpretations, here the
problem is recursive type definitions that have no valid
interpretations at all.

When type systems allow constraints on type parameters, type
declarations must be checked to see that the constraints are
valid. For instance, Scala correctly rejects the following type
declaration:
```scala
type A >: String <: Int
// Error: lower bound String does not conform to upper bound Int
```
This purports to declare a type `A` which is both a subtype of
`Int` and a supertype of `String`, but this would incorrectly imply
that `String` was a subtype of `Int`.

However, a similar example is accepted[^scala], if the invalid declaration is
split across two recursive definitions:
```scala
// Counterexample by Nada Amin
trait O { type A >: Any <: B; type B >: A <: Nothing }
val o = new O {}
def id(a: Any): Nothing = (a: o.B)
id("Boom")
```

The `Any <: B` check that is required by the declaration of `A`
passes, because `Any <: A` (by the declaration of `A`) and `A <: B`
(by the declaration of `B`). In effect, circular reasoning occurs
here, where each half of the recursive definition is used to justify
the other.

[^scala]: <https://github.com/scala/bug/issues/9715> (2016)