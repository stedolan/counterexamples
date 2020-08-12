# Avoidance problem

A type system which infers types can occasionally find itself having
inferred a type that refers to something (a type, module, etc.) which
is about to go out of scope. Referring to things which are no longer
in scope is ill-formed, and doing it generally leads to unsoundness.

So, the type system must approximate the desired type, using only
what's still in scope and avoiding the names going out of scope, which
is known as the *avoidance problem*. This is hard, and in most type
systems there is no general way to do it. Some systems employ
heuristics, but these heuristics are necessarily fragile.

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

[^dreyer]: Fig 4.12 on p. 79 of [Understanding and Evolving the ML
Module System](https://www.cs.cmu.edu/~rwh/theses/dreyer.pdf), Derek
Dreyer (2005)
