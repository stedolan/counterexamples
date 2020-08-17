# Distinctness II: Recursion

(This is the same sort of problem as [the previous
counterexample](distinctness-injectivity.md), so read that first for
context.)

When checking distinctness of two types that contain type variables, a
straightforward approach is to attempt to unify them and see whether
there is a common unifier. (Be careful! It is easy to [assume
injectivity](distinctness-injectivity.md) this way).

Unification can fail because of the _occurs check_, under which a type
variable cannot be unified with a type mentioning the same
variable. For instance, $α$ and $α → α$ fail to unify because of this
check.

So, if using unification to check distictness, it is natural to
believe that $α$ and $α → α$ are distinct, regardless of what $α$ is.
However, this is only sound if there are no infinite or recursive
types in the language: if a type $T$ could be constructed equal to $T
→ T$, then $α$ and $α → α$ would no longer be distinct.

Even when they are not directly supported, it is easy for infinite or
recursive types to sneak into the language, which creates a soundness
issue in languages checking distinctness by unification. This occurred
in both Haskell[^haskell] and OCaml[^ocaml1], for the same reason: if the definition of a
recursive type is split across module boundaries (multiple files with
type families in Haskell, or a single recursive module in OCaml), then
the typechecker will never see the construction of the whole recursive
type and so cannot reject it. This allows a counterexample to
distinctness, which can be exploited either via a Haskell type family
or and OCaml GADT match.
```haskell
-- Counterexample by Akio Takano
-- Base.hs
{-# LANGUAGE TypeFamilies #-}
module Base where

-- This program demonstrates how Int can be cast to (IO String)
-- using GHC 7.6.3.
type family F a
type instance F (a -> a) = Int
type instance F (a -> a -> a) = IO String

-- Given this type family F, it is sufficient to prove
-- (LA -> LA) ~ (LA -> LA -> LA)
-- for some LA. This needs to be done in such a way that
-- GHC does not notice LA is an infinite type, otherwise
-- it will complain.
--
-- This can be done by using 2 auxiliary modules, each of which
-- provides a fragment of the proof using different partial knowledge
-- about the definition of LA.
--
-- LA -> LA
-- = {LA~LB->LB} -- only Int_T.hs knows this
-- LA -> LB -> LB
-- = {LA~LB}     -- only T_IOString.hs knows this
-- LA -> LA -> LA
type family LA
type family LB
data T = T (F (LA -> LB -> LB))

-- Int_T.hs
{-# LANGUAGE TypeFamilies, UndecidableInstances #-}
module Int_T where
import Base
type instance LA = LB -> LB

int_t0 :: Int -> T
int_t0 = T

-- T_IOString.hs
{-# LANGUAGE TypeFamilies, UndecidableInstances #-}
module T_IOString where
import Base
type instance LB = LA

t_ioString :: T -> IO String
t_ioString (T x) = x

-- Main.hs
import Int_T
import T_IOString

main :: IO ()
main = t_ioString (int_t0 100) >>= print
```
```ocaml
(* Counterexample by Stephen Dolan *)
type (_, _) eqp = Y : ('a, 'a) eqp | N : string -> ('a, 'b) eqp
let f : ('a list, 'a) eqp -> unit = function N s -> print_string s

(* Using recursive modules, we can construct a type t = t list,
   even without -rectypes: *)

module rec A : sig
  type t = B.t list
end = struct
  type t = B.t list
end and B : sig
  type t
  val eq : (B.t list, t) eqp
end = struct
  type t = A.t
  let eq = Y
end

(* The expression f B.eq segfaults *)
```

Another instance of this bug also occurred in OCaml: OCaml
explicitly supports recursive types when the `-rectypes` option is
passed to the compiler. However, when the type checker accepts options
such that affect typechecking, it is important to ensure that code
compiled with `-rectypes` (which allows recursive types) cannot be
linked with code compiled without (which assumes recursive types are
absent). Otherwise, unsoundness results:[^ocaml2]

```ocaml
(* Counterexample by Gabriel Scherer and Benoît Vaugon *)
(* blah.ml, compiled without -rectypes *)
type ('a, 'b, 'c) eqtest =
  | Refl : ('a, 'a, float) eqtest
  | Diff : ('a, 'b, int) eqtest

let test : type a b . (unit -> a, a, b) eqtest -> b = function
  | Diff -> 42

(* bluh.ml, compiled with -rectypes *)
let () =
  print_float Blah.(test (Refl : (unit -> 'a as 'a, 'a, _) eqtest))
```

[^haskell]: <https://ghc.haskell.org/trac/ghc/ticket/8162> (2013)

[^ocaml1]: <https://github.com/ocaml/ocaml/issues/6993> (2015)

[^ocaml2]: <https://github.com/ocaml/ocaml/issues/6405> (2014)

<!-- FIXME:
 two points not well made:
  distinction between "not provably equal" and "provably distinct"
    negation-as-failure doesn't cut it under abstraction!
  linking with different type options is bad in general, not just here
-->