# Intersecting references

TAGS: mutation, subtyping

Intersection types are types of the form $A ∧ B$ which contain those
values that are both of type $A$ and of type $B$. Given such a value,
it can be used as either one of the types:
$$
\frac{Γ ⊢ e : A ∧ B}{Γ ⊢ e : A} \qquad \frac{Γ ⊢ e : A ∧ B}{Γ ⊢ e : B}
$$

Languages differ in how intersection types may be constructed. The
first style is that an expression has type $A ∧ B$ if it has both
types, possibly by separate derivations:
$$
\frac{Γ ⊢ e : A \qquad Γ ⊢ e : B}{Γ ⊢ e : A ∧ B}
$$

The second style is to use subtyping, and define $A ∧ B$ as a meet in
the subtyping order, so that:
$$
X ≤ A ∧ B \;\;\text{ iff }\;\; X ≤ A \text{ and } X ≤ B
$$

In this style, an expression $e$ can be given type $A ∧ B$ by first
typechecking it with some type $X$ which is a subtype of both, and
then using the above rule and subtyping to give it type $A ∧ B$.

The crucial difference is that in the first style, the two typing
derivations for $Γ ⊢ e : A$ and $Γ ⊢ e : B$ may be entirely different.
This brings suprising complexity: for instance, in both the
Coppo-Dezani[^cdtypes] and Barendregt-Coppo-Dezani[^bcdtypes] systems
(both simply typed lambda calculi with intersection types), type
checking is undecidable as a term is typeable iff its execution
terminates!

The counterexample here, however, is about the interaction between
these types and mutability, a phenomenon pointed out by Davies and
Pfenning[^intereffects]. First, a naive implementation of ML-style
references is unsound:
```ML
(* Counterexample by Rowan Davies and Frank Pfenning *)
(* Suppose we have types nat and pos,
   where nat is nonnegative integers
   and pos is its subtype of positive integers *)
let x : nat ref ∧ pos ref = ref 0 in
let () = (x := 0) in   (* typechecks: x is a nat ref *)
let z : pos = !x in    (* typechecks: x is a pos ref *)
z : pos                (* now we have the positive number zero *)
```

Despite the lack of the $∀$ symbol, this is essentially the same
problem as in [Polymorphic references](polymorphic-references.md): the
same single reference is used at two different types. The same
solutions apply, in particular, the value restriction.

However, there is a further potential source of unsoundness. In many
systems with subtyping and intersection types, it is conventional to have:
$$
(A → B) ∧ (A → C) ≤ A → (B ∧ C)
$$

That is, a value which is both a function that returns $B$ and a
function that returns $C$ must be a function which returns values that
are both $B$ and $C$.

Even in the presence of the value restriction, type systems with
intersection types and the above rule are unsound:
```ML
(* Counterexample by Rowan Davies and Frank Pfenning *)
let f : (unit → nat ref) ∧ (unit → pos ref) =
  fun () → ref 1 in        (* passes the value restriction *)
let f' : unit → (nat ref ∧ pos ref) =
  f in                     (* uses the above rule *)
let x : nat ref ∧ pos ref = f ()
let () = (x := 0) in
let z : pos = !x in
z : pos                    (* same problem as before *)
```

Note that both of these counterexamples rely on the first style of
intersection types above, where intersections can be introduced with
two different typing derivations. They do not arise if intersections
are available only through subtyping, as in the second style.

[^cdtypes]: [An extension of the basic functionality theory for the
λ-calculus](https://projecteuclid.org/euclid.ndjfl/1093883253),
M. Coppo and M. Dezani-Ciancaglini (1980)

[^bcdtypes]: [A filter lambda model and the completeness of type
assignment](https://www.jstor.org/stable/2273659?seq=1#metadata_info_tab_contents),
Barendregt, Coppo and Dezani-Ciancaglini (1983)

[^intereffects]: [Intersection Types and Computational Effects](https://dl.acm.org/doi/abs/10.1145/351240.351259), Rowan Davies and Frank Pfenning (2000)