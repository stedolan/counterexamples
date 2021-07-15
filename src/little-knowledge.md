# A little knowledge...

TAGS: abstract-types

The general principle broken by this counterexample is not soundness
but *monotonicity*: given more knowledge about the program, the
compiler should do a better job compiling it.

The concrete instance of this principle here is to do with abstract
types: if the implementation of a previously-hidden abstract type is
exposed, no program that previously typechecked should now fail to.

Violating this property does not cause crashes, but is
confusing. Refactoring becomes tricky if loosening abstraction
boundaries can cause programs to stop working.

This property does not hold in OCaml for several reasons.

The first reason arises from OCaml's optimized representation of
records containing only floating-point numbers (which are usually
boxed in OCaml). Since this representation is incompatible with the
normal one, it is possible for a program to depend on the optimisation
_not_ being applied:

```ocaml
module F : sig
 (* Deleting '= float' on the line below
    makes this program compile *)
 type t = float
end = struct
 type t = float
end

module M : sig
 type t
 type r = { foo : t }
end = struct
 type t = F.t
 type r = { foo : t }
end
```

The second reason arises from OCaml's _relaxed value
restriction_[^garrigue], which distinguishes parameterised types based
on whether their parameters appear in
negative positions (to the left of an odd number of function arrows),
positive positions (to the left of an even number of function arrows), or
strictly positive positions (not to the left of any function arrows).

The relaxed value restriction generalizes type variables occurring
in strictly positive positions, but not in positive positions
(or negative positions) in general.  Since making a type abstract
can turn its parameter from positive to strictly-positive, the relaxed
value restriction is at odds with monotonicity.


```ocaml
module M :
sig
 (* Deleting '= ('a -> unit) -> unit' on the line
    below makes this program compile *)
  type +'a t = ('a -> unit) -> unit
  val f : unit -> 'a t
end =
struct
  type +'a t = ('a -> unit) -> unit
  let f () _ = ()
end

let f : int M.t * string M.t = let y = M.f () in (y, y)
```

The third reason arises from OCaml's notion of *compatibility*, which
relates partially-known types that may later be revealed to be
identical.  For example, if `s` and `t` are abstract, then the types
`int * s` and `t * float` are compatible, since replacing `s` with
`float` and `t` with `int` will make them identical; in contrast, `s
option` and `t list` are not compatible.

Since making a type abstract makes it compatible with any other type,
compatibility conflicts with monotonicity.  In the example below, the
function with GADT parameter type `(s, M.t) eql` is only accepted if
`s` and `M.t` are compatible, which is the case if `t` is kept
abstract in the interface of the module `M`, but not otherwise.

```
type s = A
module M :
sig
 (* Deleting '= B' on the line below
    makes this program compile *)
  type t = B
end =
struct
  type t = B
end
type (_,_) eql = Refl : ('a, 'a) eql
let f : (s, M.t) eql -> unit = function Refl -> ()
```

The fourth reason arises from OCaml's support for *labeled arguments*,
which give callers the choice of distinguishing function arguments by
position or by name.  For example, a function `f` of type `x:int ->
y:int -> int` can be equivalently called as `f ~x:3 ~y:4`, as `f ~y:4
~x:3`, or as `f 3 4`

Assigning positional arguments to labeled parameters involves
examining the type of the function, so labeled arguments can interact
poorly with polymorphism.  A function `f` of type `x:'a list -> 'a list` can
be equivalently called either as `f []` or as `f ~x:[]`, but when a
single-argument function of type `x:('a -> 'a) -> ('a -> 'a)` is
applied to an unlabeled argument, OCaml treats it as the second argument.

Since making a type abstract can hide the fact that it is a function type,
labeled arguments conflict with monotonicity:

```ocaml
module M :
sig
 (* Deleting "= 'a -> 'a" on the line below
    makes this program compile *)
  type 'a t = 'a -> 'a
  val x : 'a t
end =
struct
  type 'a t = 'a -> 'a
  let x v = v
end

let f : x:'a M.t -> 'a M.t =
  fun ~x -> x

let v : int M.t = f M.x
```

[^garrigue]: [Relaxing the Value Restriction](https://caml.inria.fr/pub/papers/garrigue-value_restriction-fiwflp04.pdf), Jacques Garrigue (2004)
