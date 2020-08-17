# A little knowledge...

The general principle broken by this counterexample is not soundness
but *monotonicity*: given more knowledge about the program, the
compiler should do a better job compiling it.

The concrete instance of this principle here is to do with abstract
types: if the implementation of a previously-hidden abstract type is
exposed, no program that previously typechecked should now fail to.

Violating this property does not cause crashes, but is
confusing. Refactoring becomes tricky if loosening abstraction
boundaries can cause programs to stop working.

This property does not hold in OCaml, due to an optimisation that uses
a special representation for a record containing only floating-point
numbers (which are usually boxed in OCaml). However, since this
representation is incompatible with the normal one, it is possible for
a program to depend on the optimisation _not_ being applied:

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
