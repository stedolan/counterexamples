# Distinctness I: Injectivity

TAGS: injectivity

Type checkers spend much of their time verifying that pairs of types
are equal, or at least compatible, checking for instance that the type
of the argument to a function matches the type it expects.

Occasionally, they need to do the opposite, and verify that two types
are distinct. The most common case of this is allowing the programmer
to omit those cases of a pattern match which are impossible
because they would imply that two distinct types are equal. For
instance, given a value which is either a string, or evidence that
$\n{Int} = \n{String}$, then matching on this value need only handle
the first case as the second is impossible.

```ocaml
type (_,_) eq = Refl : ('a, 'a) eq
type ('a, 'b) either = Left of 'a | Right of 'b

let f (x : (string, (int,string) eq) either) =
  match x with
  | Left s -> s
  (* no case for Right, and yet the match is exhaustive *)
```
```agda
-- Agda can reason about distinctness of more than just types
open import Agda.Builtin.String
data Eq (a : String) : String -> Set where
  Refl : Eq a a

data Sum (A B : Set) : Set where
  Left : A -> Sum A B
  Right : B -> Sum A B

f : Sum String (Eq "foo" "bar") -> String
f (Left s) = s
f (Right ()) -- "()" is the absurd pattern
```

Of course, this is unsound if the type system is wrong about two types
being distinct. One common way that this can occur is when the type
system assumes that all type constructors are _injective_.

Injectivity of a type constructor $F$ means that if $F[A] = F[B]$,
then the types $A$ and $B$ are equal. Most common type constructors
(`List`, `Array` and so on) are in fact injective, so this is a
natural property to expect. However, if it is possible to define a
type constructor $F$ by $F[A] = \n{Int}$, then injectivity fails. This
issue occurred in Dotty[^dotty], a research Scala compiler, as well as in Agda[^agda]
(with the `injective-type-constructors` option). Curiously, Haskell
makes the same assumption, but without unsoundness.

```scala
// Counterexample by Aleksander Boruch-Gruszecki
object Test {
  sealed trait EQ[A, B]
  final case class Refl[T]() extends EQ[T, T]

  def absurd[F[_], X, Y](eq: EQ[F[X], F[Y]], x: X): Y = eq match {
    case Refl() => x
  }

  var ex: Exception = _
  try {
    type Unsoundness[X] = Int
    val s: String = absurd[Unsoundness, Int, String](Refl(), 0)
  } catch {
    case e: ClassCastException => ex = e
  }

  def main(args: Array[String]) =
    assert(ex != null)
}
```
```agda
-- Counterexample by Andreas Abel
{-# OPTIONS --injective-type-constructors #-}

open import Common.Prelude
open import Common.Equality

abstract
  f : Bool → Bool
  f x = true

  same : f true ≡ f false
  same = refl

not-same : f true ≡ f false → ⊥
not-same ()

absurd : ⊥
absurd = not-same same
```
```haskell
data Equ a b where
  Refl : Equ a a

-- not in fact unsound! see below
everythingIsInjective :: Equ (f a) (f b) -> Equ a b
everythingIsInjective Refl = Refl
```

The reason that it is sound for Haskell to assume an arbitrary type
constructor $F$ is injective is that it draws a distinction between
type constructors and type-level functions. The following two
declarations are distinct:
```haskell
type family Foo :: * -> *
type family Bar a :: *
```
Here, `Foo` is defined as a type constructor, something of kind `* ->
*`. This kind only contains injective type constructors (like lists,
etc.).
By constrast, `Bar` is defined as a type-level function. `Bar` is not
necessarily injective, as one can define:
```haskell
type instance Bar a = Int
```

However, `Bar` is not of kind `* -> *`, and cannot be passed as the
`f` parameter to `everythingIsInjective`:
```haskell
eqFoo :: Equ (Foo a) (Foo b) -> Equ a b
eqFoo = everythingIsInjective -- works

eqBar :: Equ (Bar a) (Bar b) -> Equ a b
eqBar = everythingIsInjective -- error
```

In fact, in Haskell there is currently no way to quantify over things
like `Bar`: Haskell's higher-kinded types only allow passing around
injective type constructors. A recent paper by Kiss et al.[^haskell] proposes adding
parameterisation by type functions to Haskell, by adding a new kind `*
=> *` which does not carry injectiveness assumptions.

[^dotty]: <https://github.com/lampepfl/dotty/issues/5658> (2018)

[^agda]: <https://github.com/agda/agda/issues/2250> (2016)

[^haskell]: [Higher-order Type-level Programming in
Haskell](https://www.microsoft.com/en-us/research/publication/higher-order-type-level-programming-in-haskell/)
(ICFP '19), Csongor Kiss, Susan Eisenbach, Tony Field, Simon Peyton
Jones (2019)
