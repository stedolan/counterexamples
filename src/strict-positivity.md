# Positivity, strict and otherwise

TAGS: recursive-types, totality, impredicativity

In a total language, type definitions that refer to themselves must be restricted:
```coq
-- rejected by Coq
Inductive bad := r (c : bad -> nat).
```
```agda
-- rejected by Agda
data Bad : Set where
  r : (Bad → ℕ) → Curry
```

Here, the type `bad` is defined recursively as consisting of a
function that accepts `bad` as an input. Allowing these _negative_
definitions leads to [Curry's paradox](currys-paradox.md), and breaks
totality.

The situation is more complicated if the recursive reference is
underneath two function arrows:
```coq
-- also rejected by Coq
Inductive bad2 := r (c : (bad2 -> nat) -> nat).
```
```agda
-- also rejected by Agda
data Bad2 : Set where
  r : ((Bad2 → ℕ) → ℕ) → Bad2
```

This is not negative recursion: `bad2` is not defined in terms of
functions that accept `bad2` values as an input, but in terms of
functions that may provide `bad2` values to their argument. This is
said to be positive recursion (since all recursive references to `bad2`
occur to the left of an _even_ number of function arrows), but not
*strictly positive* (wherein all recursive references occur to the
left of _zero_ function arrows).

Recursive definitions which are positive yet not strictly positive can
cause issues, as pointed out by Coquand and Paulin[^colog88]. Their
counterexample was translated into modern Coq by Sjöberg[^sjöberg],
and reproduced here:
```coq
(* Counterexample by Thierry Coquand and Christine Paulin
   Translated into Coq by Vilhelm Sjöberg *)

(* Phi is a positive, but not strictly positive, operator. *)
Definition Phi (a : Type) := (a -> Prop) -> Prop.

(* If we were allowed to form the inductive type
     Inductive A: Type :=
       introA : Phi A -> A.
   then among other things, we would get the following. *)
Axiom A : Type.
Axiom introA : Phi A -> A.
Axiom matchA : A -> Phi A.
Axiom beta : forall x, matchA (introA x) = x.

(* In particular, introA is an injection. *)
Lemma introA_injective : forall p p', introA p = introA p' -> p = p'.
Proof.
  intros.
  assert (matchA (introA p) = (matchA (introA p'))) as H1 by congruence.
  now repeat rewrite beta in H1.
Qed.

(* However, ... *) 

(* Proposition: For any type A, there cannot be an injection
   from Phi(A) to A. *)

(* For any type X, there is an injection from X to (X->Prop),
   which is λx.(λy.x=y) . *)
Definition i {X:Type} : X -> (X -> Prop) := 
  fun x y => x=y.

Lemma i_injective : forall X (x x' :X), i x = i x' -> x = x'.
Proof.
  intros.
  assert (i x x = i x' x) as H1 by congruence.
  compute in H1.
  symmetry.
  rewrite <- H1.
  reflexivity.
Qed.  

(* Hence, by composition, we get an injection f from A->Prop to A. *)
Definition f : (A->Prop) -> A 
  := fun p => introA (i p).

Lemma f_injective : forall p p', f p = f p' -> p = p'.
Proof.
  unfold f. intros.
  apply introA_injective in H. apply i_injective in H. assumption.
Qed.

(* We are now back to the usual Cantor-Russel paradox. *)
(* We can define *)
Definition P0 : A -> Prop
  := fun x => 
       exists (P:A->Prop), f P = x /\ ~ P x.
  (* i.e., P0 x := x codes a set P such that x∉P. *)

Definition x0 := f P0.

(* We have (P0 x0) iff ~(P0 x0) *)
Lemma bad : (P0 x0) <-> ~(P0 x0).
Proof.
split.
  * intros [P [H1 H2]] H.
    change x0 with (f P0) in H1.
    apply f_injective in H1. rewrite H1 in H2.
    auto.
  * intros.
    exists P0. auto.
Qed.

(* Hence a contradiction. *)
Theorem worse : False.
  pose bad. tauto.
Qed.
```

<!-- FIXME: "recursive" vs. "inductive" terminology -->

This counterexample uses three ingredients: non-strictly-positive
definitions, impredicativity (the ability for definitions of terms in
`Prop` to quantify over all of `Prop`) and a universe type (the
ability to refer to `Prop` itself as a type). It appears that all
three are necessary:

  - The Calculus of Inductive Constructions, upon which Coq is based,
    is total, and has an impredicative `Prop` and a universe type for
    `Prop`, but requires all inductive definitions to be strictly
    positive.

  - System F is impredicative, and can encode (or be extended with)
    non-strictly-positive inductive types while remaining total (see
    Berger et al.[^hofmann] for an example), but lacks a universe type.

  - The combination of non-strictly-positive inductive types and
    universe types is an unusual one, but poses no theoretical
    problems in the absence of impredicativity. See for instance the
    constructions of Abel[^abel] or Blanqui[^blanqui].





[^colog88]: Section 3.1 of "Inductively defined types", Thierry Coquand and Christine Paulin, 1988.

[^sjöberg]: [Why must inductive types be strictly positive?](http://vilhelms.github.io/posts/why-must-inductive-types-be-strictly-positive/), Vilhelm Sjöberg (2015) 

[^hofmann]: [Martin Hofmann’s Case for Non-Strictly Positive Data Types](https://hal.archives-ouvertes.fr/hal-02365814), Ulrich Berger, Ralph Matthes and Anton Setzer (2018)

[^abel]: Section 7.1 of [A Semantic Analysis of Structural Recursion](http://www.cs.cmu.edu/~abel/publications.html), Andreas Abel (1999)

[^blanqui]: [Inductive types in the Calculus of Algebraic Constructions](https://arxiv.org/abs/cs/0610070), Frédéric Blanqui (2006)