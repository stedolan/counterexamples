# Suspicious subterms

In _total_ languages, all well-typed expressions terminate and
infinite loops are impossible. This property is relied upon by proof
assistants like Coq and Agda: if the result of a subexpression is not
needed to compute the output of a program, then the subexpression is
discarded. This is an important optimisation in a proof assistant,
because large parts of the program are often proofs about other parts
of the program, and not directly used in computations. However, this
optimisation means that any source of nontermination immediately
causes a soundness issue, of the sort described in [Eventually,
nothing](eventually-nothing.md).

To remain sound, these languages must check that all recursive
functions eventually terminate. This is usually done by checking that
when the function recurses, the argument it passes itself is a
strictly smaller part of the argument it received, making infinite
recursion impossible.

The tricky part of this is the _subterm check_, which determines
whether one expression a strictly smaller part (a "subterm") of
another. Coq, in particular, has an extensive subterm check, accepting
as subterms of `u` not just direct subterms but also:

  * `match ... with p1 -> c1 | p2 -> c2 | ... end`

    if each possible result `cN` is a subterm of `u`

  * `fun x => c`

    if the result `c` is a subterm of `u`

This resulted in unsoundness when combined with *propositional
extensionality*, an assumption widely used and available in the Coq
standard library, although not made by default. Propositional
extensionality states that two propositions which are equivalent are
also equal: roughly, this states that the only information in a
proposition carries is whether or not it is true. The details of
proofs can be discarded, identifying all true propositions with each
other, and likewise for false ones.

One particular consequence of this is that `False -> False` and `True`
become equal, as both are true. This led to an unsoundness in Coq[^coq]:
```coq
(* Counterexample by Maxime Dénès *)
Require Import ClassicalFacts.

Section func_unit_discr.
Hypothesis Heq : (False -> False) = True.
Fixpoint contradiction (u : True) : False :=
  contradiction (
    match Heq in (_ = T) return T with
    | eq_refl => fun f:False => match f with end
    end
  ).
End func_unit_discr.

Lemma foo : provable_prop_extensionality -> False.
Proof.
  intro; apply contradiction.
  apply H.
  trivial.
  trivial.
Qed.
```

The issue is that Coq's subterm check accepted the argument above as a
subterm of `u : True`, which should not have any subterms. By Coq's
definition of "subterm", the expression `match f with end` is a
subterm of `u` because each of its zero possible results is a subterm
of `u`. The fix was to restrict the subterm check in the presence of
dependent matches, like the outer `match`.

Agda's subterm checker has also been confused by dependent matching on
type equalities, as this counterexample shows[^agda]:
```agda
-- Andreas Abel, 2014-01-10
-- Code by Jesper Cockx and Conor McBride and folks from the Coq-club

{-# OPTIONS --without-K #-}

-- An empty type.

data Zero : Set where

-- A unit type as W-type.

mutual
  data WOne : Set where wrap : FOne -> WOne
  FOne = Zero -> WOne

-- Type equality.

data _<->_ (X : Set) : Set -> Set where
  Refl : X <-> X

-- This postulate is compatible with univalence:

postulate
  iso : WOne <-> FOne

-- But accepting that is incompatible with univalence:

noo : (X : Set) -> (WOne <-> X) -> X -> Zero
noo .WOne Refl (wrap f) = noo FOne iso f

-- Matching against Refl silently applies the conversion
-- FOne -> WOne to f.  But this conversion corresponds
-- to an application of wrap.  Thus, f, which is really
-- (wrap f), should not be considered a subterm of (wrap f)
-- by the termination checker.
-- At least, if we want to be compatible with univalence.

absurd : Zero
absurd = noo FOne iso (\ ())
```

Finally, both Coq and Agda had a related soundness issue using
coinductive rather than inductive types. Coinductive types contain
possibly-infinite values, and instead of the subterm check (which
verifies that recursive functions do not loop infinitely when
consuming a value) they use the _guardedness check_ (which verifies
that recursive definitions do not loop infinitely when producing a
value).

As above, the guardedness checker was confused by dependent pattern
matching on type equalities arising from propositional extensionality,
and permitted definitions that looped unproductively[^cocoq][^coagda]:
```coq
(* Counterexample by Maxime Dénès *)
CoInductive CoFalse : Prop := CF : CoFalse -> False -> CoFalse.

CoInductive Pandora : Prop := C : CoFalse -> Pandora.

Axiom prop_ext : forall P Q : Prop, (P<->Q) -> P = Q.

Lemma foo : Pandora = CoFalse.
  apply prop_ext.
  constructor.
  intro x; destruct x; assumption.
  exact C.
Qed.

CoFixpoint loop : CoFalse :=
  match foo in (_ = T) return T with eq_refl => C loop end.

Definition ff : False := match loop with CF _ t => t end.
```
```agda
-- Counterexample by Andreas Abel
open import Common.Coinduction
open import Common.Equality

prop = Set

data False : prop where

data CoFalse : prop where
  CF : False → CoFalse

data Pandora : prop where
  C : ∞ CoFalse → Pandora

postulate
  ext : (CoFalse → Pandora) → (Pandora → CoFalse) → CoFalse ≡ Pandora

out : CoFalse → False
out (CF f) = f

foo : CoFalse ≡ Pandora
foo = ext (λ{ (CF ()) }) (λ{ (C c) → CF (out (♭ c))})

loop : CoFalse
loop rewrite foo = C (♯ loop)

false : False
false = out loop
```

[^coq]: <https://sympa.inria.fr/sympa/arc/coq-club/2013-12/msg00119.html> (coq-club mailing list), Maxime Dénès (2013)

[^agda]: <https://github.com/agda/agda/issues/1023/> (2015)

[^cocoq]: <https://sympa.inria.fr/sympa/arc/coq-club/2014-02/msg00215.html> (coq-club mailing list), Maxime Dénès (2014)

[^coagda]: <https://sympa.inria.fr/sympa/arc/coq-club/2014-03/msg00020.html> (coq-club mailing list), Andreas Abel (2014)

<!--
  FIXME: is this really eventually-nothing?
   Seems more like the static-type missing gadt value version.
-->