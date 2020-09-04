# Large injections

TAGS: injectivity

There are two distinct points of view one can have about type definitions:

  - **Types are found**: there is a pre-existing universe containing
    all possible types/sets/etc. and type definitions give a short
    name to some member of this universe.

  - **Types are made**: each type definition grows the universe of
    types, and types do not exist until they are defined.

While abstract, the distinction can be relevant to the design of a
type system. For example, if there are two identical definitions of
types $S$ and $T$, then the "found" viewpoint would suggest that $S =
T$ (they denote the same set), but the "made" viewpoint would suggest
that $S ≠ T$ (they are separate definitions). (By taking the name to
be part of the definition, you can also hold the "found" viewpoint and
assume $S ≠ T$. Convincing yourself that $S = T$ under the "made"
viewpoint is harder, though)

A more subtle case arises around injectivity of type constructors.
Suppose the type being defined is a type constructor $F[-]$. Under the
"made" viewpoint, this makes a different new type $F[X]$ for each
possible $X$. Since all of the $F[X]$ are different, $F$ is injective:
$$
F[X] = F[Y] \qquad\text{implies}\qquad X = Y
$$
By contrast, under the "found" viewpoint it's not immediately clear
whether $F$ is injective.

The type systems of several languages and proof assistants took the
"made" viewpoint, and assumed all type constructors to be injective.
This is in conflict with Cantor's theorem[^cantor] from set theory
(which is firmly in the "found" camp), which states that there can be
no injection from the powerset of a set to the set itself (the
powerset is "larger"). In particular, the function space $\n{Set} →
\n{Set}$ must be larger than $\n{Set}$.

Chung Kil Hur[^agda] used this fact to prove a contradiction in Agda, under
the assumptions of classical logic that Cantor's theorem
requires. Agda allows the definition of an injective type constructor
in `Set` with a parameter in `Set → Set`, yet also admits Cantor's
proof that no such injective type function exists:
```agda
-- Counterexample by Chung Kil Hur
module cantor where

data Empty : Set where

data One : Set where
  one : One

data coprod (A : Set1) (B : Set1) : Set1 where
  inl : ∀ (a : A) -> coprod A B
  inr : ∀ (b : B) -> coprod A B

postulate exmid : ∀ (A : Set1) -> coprod A (A -> Empty)

data Eq1 {A : Set1} (x : A) : A -> Set1 where
  refleq1 : Eq1 x x

cast : ∀ { A B } -> Eq1 A B -> A -> B
cast refleq1 a = a

Eq1cong : ∀ {f g : Set -> Set} a -> Eq1 f g -> Eq1 (f a) (g a)
Eq1cong a refleq1 = refleq1

Eq1sym : ∀ {A : Set1} { x y : A } -> Eq1 x y -> Eq1 y x
Eq1sym refleq1 = refleq1

Eq1trans : ∀ {A : Set1} { x y z : A } -> Eq1 x y -> Eq1 y z -> Eq1 x z
Eq1trans refleq1 refleq1 = refleq1

data I : (Set -> Set) -> Set where

Iinj : ∀ { x y : Set -> Set } -> Eq1 (I x) (I y) -> Eq1 x y
Iinj refleq1 = refleq1

data invimageI (a : Set) : Set1 where
  invelmtI : forall x -> (Eq1 (I x) a) -> invimageI a

J : Set -> (Set -> Set)
J a with exmid (invimageI a)
J a | inl (invelmtI x y) = x
J a | inr b = λ x → Empty

data invimageJ (x : Set -> Set) : Set1 where
  invelmtJ : forall a -> (Eq1 (J a) x) -> invimageJ x

IJIeqI : ∀ x -> Eq1 (I (J (I x))) (I x)
IJIeqI x with exmid (invimageI (I x))
IJIeqI x | inl (invelmtI x' y) = y
IJIeqI x | inr b with b (invelmtI x refleq1)
IJIeqI x | inr b | ()

J_srj : ∀ (x : Set -> Set) -> invimageJ x
J_srj x = invelmtJ (I x) (Iinj (IJIeqI x))

cantor : Set -> Set
cantor a with exmid (Eq1 (J a a) Empty)
cantor a | inl a' = One
cantor a | inr b = Empty

OneNeqEmpty : Eq1 One Empty -> Empty
OneNeqEmpty p = cast p one

cantorone : ∀ a -> Eq1 (J a a) Empty -> Eq1 (cantor a) One
cantorone a p with exmid (Eq1 (J a a) Empty)
cantorone a p | inl a' = refleq1
cantorone a p | inr b with b p
cantorone a p | inr b | ()

cantorempty : ∀ a -> (Eq1 (J a a) Empty -> Empty) -> Eq1 (cantor a) Empty
cantorempty a p with exmid (Eq1 (J a a) Empty)
cantorempty a p | inl a' with p a'
cantorempty a p | inl a' | ()
cantorempty a p | inr b = refleq1

cantorcase : ∀ a -> Eq1 cantor (J a) -> Empty
cantorcase a pf with exmid (Eq1 (J a a) Empty)
cantorcase a pf | inl a' =
  OneNeqEmpty (Eq1trans (Eq1trans (Eq1sym (cantorone a a')) (Eq1cong a pf)) a')
cantorcase a pf | inr b =
  b (Eq1trans (Eq1sym (Eq1cong a pf)) (cantorempty a b))

absurd : Empty
absurd with (J_srj cantor)
absurd | invelmtJ a y = cantorcase a (Eq1sym y)
```

Without use of classical logic assumptions, Alexandre Miquel and
Russell O'Connor[^coq] discovered a related issue with
impredicativity.  Impredicativity allows a type to be defined,
quantifying over a universe that includes the type being defined. The
canonical example of an impredicative definition is "the smallest set
$S$ such that ...", where "smallest" quantifies over all sets,
including $S$.  Since it assumes a predefined universe to quantify
over, this puts impredicativity firmly in the "found" camp, and it
turns out to be incompatible with injectivity.

The issue was first demonstrated in Coq[^coq] (which has an
impredicative universe `Prop`), although did not cause a soundness
issue there as Coq does not assume injectivity. However, the
counterexample was later translated to Lean[^lean] and Idris[^idris],
which did make the injectivity assumption and were shown unsound.
```coq
-- Counterexample by Alexandre Miquel
Inductive I : (Prop -> Prop) -> Prop := .

Axiom inj_I : forall x y, I x = I y -> x = y.

Definition R (x : Prop) := forall p, x = I p -> ~ p x.

Lemma R_eqv :
  forall p, R (I p) <-> ~ p (I p).
Proof.
  split; intros.
  unfold R; apply H.
  reflexivity.
  unfold R; intros q H0.
  rewrite <- (inj_I p q H0).
  assumption.
Qed.

Lemma R_eqv_not_R :
  R (I R) <-> ~ R (I R).
Proof (R_eqv R).

Lemma absurd : False.
Proof.
  destruct R_eqv_not_R.
  exact (H (H0 (fun x => H x x)) (H0 (fun x => H x x))).
Qed.
```
```lean
-- Counterexample by Leonardo de Moura
open eq

inductive I (F : Type₁ → Prop) : Type₁ :=
mk : I F

axiom InjI : ∀ {x y}, I x = I y → x = y

definition P (x : Type₁) : Prop := ∃ a, I a = x ∧ (a x → false).

definition p := I P

lemma false_of_Pp (H : P p) : false :=
obtain a Ha0 Ha1, from H,
  subst (InjI Ha0) Ha1 H

lemma contradiction : false :=
have Pp : P p, from exists.intro P (and.intro rfl false_of_Pp),
false_of_Pp Pp
```
```idris
-- Counterexample by David Thrane Christiansen
module ProveVoid

%default total

data In : (f : Type -> Type) -> Type where
  MkIn : In f

-- This step requires definitional type constructor injectivity and is
-- the source of the problem.
injIn : In x = In y -> x = y
injIn Refl = Refl

P : Type -> Type
P x = (a : (Type -> Type) ** (In a = x, a x -> Void))

inP : Type
inP = In P

oops : P ProveVoid.inP -> Void
oops (a ** (Ha0, Ha1)) =
  let ohNo : (P (In P) -> Void) = replace {P=\ x => x (In P) -> Void} (injIn Ha0) Ha1
  in ohNo (P ** (Refl, ohNo))

total -- for extra oumph!
ohNo : Void
ohNo =
  let foo : P ProveVoid.inP = (P ** (Refl, oops))
  in oops foo
```

[^cantor]: <https://en.wikipedia.org/wiki/Cantor%27s_theorem>

[^agda]: [Agda with excluded middle is inconsistent](https://lists.chalmers.se/pipermail/agda/2010/001526.html) (Agda mailing list), Chung Kil Hur (2010). See also [related discussion on coq-club mailing list](https://coq-club.inria.narkive.com/iDuSeltD/agda-with-the-excluded-middle-is-inconsistent).

[^coq]: [Re: [Coq-Club] Agda with the excluded middle is inconsistent](https://lists.chalmers.se/pipermail/agda/2010/001565.html) (Agda mailing list), Chung Kil Hur (2010)

[^lean]: <https://github.com/leanprover/lean/issues/654> (2015)

[^idris]: <https://github.com/idris-lang/Idris-dev/issues/3687> (2017)
