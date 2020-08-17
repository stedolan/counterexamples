# Self-justifying facts

While the `Empty` type of the previous counterexample has no values at
all, there are types whose emptiness depends on their parameters. The
canonical example is the equality type, expressible as a GADT in
Haskell or OCaml or as an inductive family in Coq or Agda (among
others):
```ocaml
type (_, _) eq =
  Refl : ('a, 'a) eq
```
```haskell
data Eq a b where
  Refl :: Eq a a
```
```coq
Inductive eq {S : Set} : S -> S -> Prop :=
  Refl a : eq a a.
```
```agda
data Eq {S : Set} : S -> S -> Set where
  refl : (a : S) -> Eq a a
```

The type `(a, b) eq` witnesses equality: it is nonempty if `a` and `b`
are the same type, and empty if they are distinct. Values of type `(a,
b) eq` constitute evidence that `a` and `b` are in fact the same, and
can be used e.g. to turn an `a` into a `b`.

For an arbitrary type `a`, we have no way of making an `(int, a) eq`:
for all we know `a` might be `string`. The only way to construct a
value of the `eq` type is using `Refl`, which demands the parameters
be equal.

However, if we are given a `p : (int, a) eq`, then we can use this
evidence that they are equal to construct another `(int, a) eq`:
```ocaml
match p with Refl -> Refl
```
```haskell
case p of Refl -> Refl
```
```coq
match p with Refl -> Refl
```
```agda
eta :: {a : Set} -> Eq Int a -> Eq Int a
eta Refl = Refl
```

<!-- FIXME: expand to fuller counterex? Not much longer -->

This says that we can conclude that `int` and `a` are equal, given
evidence that `int` and `a` are equal, which is true enough. The
problem arises when this sort of reasoning is combined with
recursion. For instance, in OCaml[^ocamlbug]:
```ocaml
let rec p : (int, a) eq =
  match p with
  | Refl -> Refl
```
This reasoning is circular: it constructs evidence that
`int` and `a` are equal by assuming that they are, and using that
assumption to prove that they are.

OCaml has a check to ensure that recursive definitions are
well-formed, but as in the previous counterexample this can interact
badly with optimisations. In versions of OCaml prior to 4.06.0, the
check for recursive well-formedness occurred _after_ an optimisation
that deleted `match` statements that only had a single possible outcome.

But after the `match` in the definition of `p` is deleted, it _passes_ the
recursive well-formedness check, as their are no remaining uses of `p`
in its own definition. This allowed the creation of `(int, string)
eq`, which is unsound.

[^ocamlbug]: <https://github.com/ocaml/ocaml/issues/7215> (2016)
