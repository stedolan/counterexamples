# Underdetermined recursion

Most type systems permit some flavour of recursive types, allowing the
programmer to define, say, the type $\n{ListInt}$ representing lists
of integers. A $\n{ListInt}$ consists of either the empty list, or a
pair of an integer and a $\n{ListInt}$, giving the recursive equation:
$$
\n{ListInt} \cong 1 + \n{Int} × \n{ListInt}
$$
There are two ways to interpret the symbol $\cong$ above:

  - **Isorecursive types**: there is an explicitly defined
    datatype/class $\n{ListInt}$, and we must use its
    constructors/methods to convert between $\n{ListInt}$ and $1 +
    \n{Int} × \n{ListInt}$. The symbol $\cong$ is read as "is
    isomorphic to".

  - **Equirecursive types**: the types $\n{ListInt}$ and $1 + \n{Int}
    × \n{ListInt}$ are the same type, because $\n{ListInt}$ is
    identified with the infinite expansion:
    $$
    1 + \n{Int} × (1 + \n{Int} × (1 + (\n{Int} × \dots)))
    $$
    The symbol $\cong$ is read as "equals".

With equirecursive types, there can only be a single solution to a
recursive equation. If I have another type $A$ satisfying $A = 1 +
\n{Int} × A$, then the infinite expansions of $\n{ListInt}$ and $A$
are equal, so $A = \n{ListInt}$. With isorecursive types, on the other
hand, there can be two different datatypes/classes with the same
pattern of recursion, which the type system does not necessarily
consider equal.

The assumption that recursive type equations have only a single
solution can lead to unsoundness when combined with higher-kinded
types. If it is possible to abstract over a type constructor $F$ and
two types $A, B$ satisfying:
$$
\begin{aligned}A &= F[A] \\ B &= F[B] \end{aligned}
$$
then type systems equirecursive types will assume that $A = B$, since
they have the same infinite expansion $F[F[F[\dots]]]$.

This is unsound for arbitrary type-level functions $F$ because there
can be multiple solutions for $X = F[X]$. For instance:
$$
\begin{aligned}
F[X] &= X \\
A &= \n{Int} \\
B &= \n{String}
\end{aligned}
$$

This problem has arisen in OCaml[^ocaml]:
```ocaml
(* Counterexample by Stephen Dolan *)
type (_, _) eq = Eq : ('a, 'a) eq
let cast : type a b . (a, b) eq -> a -> b =
  fun Eq x -> x

module Fix (F : sig type 'a f end) = struct
  type 'a fix = ('a, 'a F.f) eq
  let uniq (type a) (type b)
    (Eq : a fix) (Eq : b fix) : (a, b) eq =
    Eq
end

module FixId = Fix (struct type 'a f = 'a end)
let bad : (int, string) eq = FixId.uniq Eq Eq
let _ = Printf.printf "Oh dear: %s" (cast bad 42)
```

[^ocaml]: <https://github.com/ocaml/ocaml/issues/6992> (2015)