# The avoidance problem

TAGS: scoping, subtyping

A type system which infers types can occasionally find itself having
inferred a type that refers to something (a type, module, etc.) which
is about to go out of scope. Referring to things which are no longer
in scope is ill-formed, and doing it generally leads to unsoundness
(see [Scope escape](scope-escape.md)).

So, the type system must approximate the desired type, using only
what's still in scope and avoiding the names going out of scope, which
is known as the *avoidance problem*. This is hard, and in most type
systems there is no general way to do it, and some systems employ
fragile heuristics.

An example of this due to Dreyer[^dreyer] can be found in OCaml, when a
parameterised module is instantiated with an anonymous module:
```ocaml
module type S = sig type t end
module F (X : S) = struct type u = X.t type v = X.t end
module AppF = F((struct type t = int end : S))
```
Here OCaml infers the following module signature for `AppF`:
```ocaml
module AppF : sig type u type v end
```
The type `X.t` is no longer in scope as the anonymous module
substituted for `X` has no name. So the signature is approximated by
leaving the types abstract. However, if the definition of `F` is
changed to an equivalent form:
```ocaml
module G (X : S) = struct type u = X.t type v = u end
```
then the inferred module signature changes to the non-equivalent:
```ocaml
module AppG : sig type u type v = u end
```
The approximation process fails to respect equivalences between module
signatures, which is typical of heuristic solutions to the avoidance
problem.

A well-behaved solution to the avoidance problem is to introduce
existential types when necessary to give names to values that have
gone out of scope. In the above example, that would lead to a
signature like $∃\n{X} : \n{S}.\;\{ {\tt type}\;{\tt u} = \n{X}.{\tt t};\; {\tt type}\; {\tt v} = \n{X}.{\tt t} \}$.
The details of when and how to introduce such existentials can be
quite tricky, see Crary[^crary] for a recent approach.


Languages with subtyping and top/bottom types $\n{Any}$ and $\n{Nothing}$ can
sometimes use a different solution to the avoidance problem: types that go out
of scope are approximated as $\n{Any}$ when used covariantly (as an
output) and $\n{Nothing}$ when used contravariantly (as an input). For
instance, when the type $A$ goes out of scope, a function of type
$\n{List}[A] → \n{List}[A]$ becomes $\n{List}[\n{Nothing}] → \n{List}[\n{Any}]$.

Scala uses this approach. However, due to the presence of constraints
in Scala types (a type $T[A]$ may be well-defined only for some $A$),
it is not always valid to replace occurrences of $A$ with $\n{Any}$ or
$\n{Nothing}$.  This caused a bug in Scala[^scala], where invalid types were
sometimes inferred:
```scala
// Counterexample by Guillaume Martres
class Contra[-T >: Null]

object Test {
  def foo = {
    class A
    new Contra[A]
  }
}
// The inferred type of foo is Contra[Nothing],
// but this isn't a legal type
```


[^dreyer]: Fig 4.12 on p. 79 of [Understanding and Evolving the ML
Module System](https://people.mpi-sws.org/~dreyer/thesis/main.pdf), Derek
Dreyer (2005)

[^crary]: [A Focused Solution to the Avoidance Problem](https://www.cs.cmu.edu/~crary/papers/2020/exsig.pdf), Karl Crary (2020)

[^scala]: <https://github.com/lampepfl/dotty/issues/6205> (2019)
