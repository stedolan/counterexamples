# Summary

[Counterexamples in Type Systems](title.md)
[Introduction](intro.md)

  - [Polymorphic references](polymorphic-references.md)
  - [Covariance everywhere](general-covariance.md)
  - [Curry's paradox](currys-paradox.md)

  - [Eventually, nothing](eventually-nothing.md)
  - [Self-justifying facts](self-justification.md)
  - [Null evidence](null-evidence.md)

  - [Some kinds of Anything](anythings.md)
  - [Any (single) thing](anything-once.md)

  - [The avoidance problem](avoidance.md)

  - [Mutable matching](mutable-matching.md)

  - [Runtime misinformation](runtime-misinformation.md)

  - [Distinctness I: Injectivity](distinctness-injectivity.md)
  - [Distinctness II: Recursion](distinctness-recursion.md)

<!--

"Injective type families for Haskell", Eisenberg.
(ctrl-F "unsound")


equirecursive uniqueness:
  uniqueness / nonuniqueness is roughly equi / iso
  if assuming uniqueness, don't check contractivity



An Injection from Set->Set to Set seems to be bad in two different ways.
There are proofs that it's anticlassical, and proofs that it's inconsistent.
The inconsistency proofs might rely on impredicativity?
I don't see why the anticlassical proofs aren't already proofs of false.
Well, because I don't have double-negation-shift for Set!

more injective nonsense:
https://github.com/leanprover/lean/issues/654
https://gist.github.com/leodemoura/0c88341bb585bf9a72e6
https://github.com/idris-lang/Idris-dev/issues/3687
https://lists.chalmers.se/pipermail/agda/2010/001530.html
http://comments.gmane.org/gmane.science.mathematics.logic.coq.club/4348
https://lists.chalmers.se/pipermail/agda/2010/001565.html
https://lists.chalmers.se/pipermail/agda/2010/001526.html

Recursive types:
  - non-strictly-positive types + impredicativity (COLOG'88 Coquand)
  - contractivity + higher-kinded types

Impredicativity:
  - Type:Type (Girard's paradox. Leo's OCaml impl.)
  - http://okmij.org/ftp/Haskell/impredicativity-bites.html

Subtyping:
  - impredicativity: undecidable Fsub (java example?)
    [2] Bounded quantification is undecidable, Pierce
    http://www.cis.upenn.edu/~bcpierce/papers/fsubpopl.ps
    (example by Ghelli on page 4)

Quotient types:
  - http://strictlypositive.org/Ripley.pdf, 2
  - https://lists.chalmers.se/pipermail/agda/2012/004052.html


  

GeneralizedNewtypeDeriving and roles
https://ghc.haskell.org/trac/ghc/ticket/1496
https://ghc.haskell.org/trac/ghc/ticket/2721


Conor's ripley (embiggening definitional equality)
http://strictlypositive.org/Ripley.pdf
1. Codata
3. (0 -> A)

Large eliminations are bad:
p70 of TAPL2  (coquand 1986)

p88 of TAPL2 (effects)
p312,336 of TAPL2 (first-class module projections, generativity)

Berardi's paradox and others in the coq stdlib

https://coq.inria.fr/cocorico/CoqTerminationDiscussion

"specialization" in rust:
https://aturon.github.io/blog/2017/07/08/lifetime-dispatch/

rust JoinGuard
https://github.com/rust-lang/rust/issues/24292

more rust:
https://github.com/rust-lang/rust/issues/26656
https://github.com/rust-lang/rust/issues/25860

http://permalink.gmane.org/gmane.comp.lang.haskell.cafe/77116
http://lambda-the-ultimate.org/node/4031

(False -> False) = True
https://sympa.inria.fr/sympa/arc/coq-club/2013-12/msg00119.html
https://sympa.inria.fr/sympa/arc/coq-club/2013-12/msg00189.html

GADTs and subtyping
https://issues.scala-lang.org/browse/SI-8563
An invariant case of a covariant definition allows constructing
a covariant array, hilarity ensues.
https://issues.scala-lang.org/browse/SI-6944
https://issues.scala-lang.org/browse/SI-7952
https://issues.scala-lang.org/browse/SI-8241

generics in C#/Java/Scala:
https://www.microsoft.com/en-us/research/publication/on-decidability-of-nominal-subtyping-with-variance/
https://arxiv.org/abs/1605.05274

Generativity and modules
Fig. 4.4 of Claudio Russo's thesis (pg. 114)
Fig. 7.12/Ex. 7.4.1 (unpacking first-class mods) (pg. 270)

first class modules / side effects / something
write a function which returns a type
but has an internal state bit, which it flips
when called twice it returns two incompatible types
which must not be regarded as equivalent
https://issues.scala-lang.org/browse/SI-2079

Something similar:
the ability to create new values of a first-class type
must be very careful about how the abstract types are bound
https://issues.scala-lang.org/browse/SI-515

The interaction of Java overloading and generics is weird.
Inserting "bridge methods" breaks things:
https://issues.scala-lang.org/browse/SI-9912
http://www.concurrentaffair.org/2006/10/10/java-generics-unsound/
Structural types specialising generics break things:
https://issues.scala-lang.org/browse/SI-2672

There seem to have been a bunch of bugs with Scala not doing variance checks.
These don't seem terribly interesting, tbh.
https://issues.scala-lang.org/browse/SI-1364
https://issues.scala-lang.org/browse/SI-8737
https://issues.scala-lang.org/browse/SI-7093 (most interesting one)
https://issues.scala-lang.org/browse/SI-8737
https://issues.scala-lang.org/browse/SI-9549
https://issues.scala-lang.org/browse/SI-5060

If we have higher-kinded quantification, subtyping and variance
then we must ensure the variance advertised is not more general
than the variance implemented.
It's not enough to quantify over type constructors, I think.
We need to quantify over type constructors of given variance.
Excellent bug.
https://issues.scala-lang.org/browse/SI-2066?orig=1



In the presence of side-effects (fresh names, refs, exceptions) and first-class types, the same expression might evaluate to different types different times.
I think this is the same as several first-class module bugs (Russo's thesis?)
https://github.com/scala/bug/issues/10619
"paths" in
https://www.scala-lang.org/files/archive/spec/2.11/03-types.html
"stable identifier" in
https://issues.scala-lang.org/browse/SI-963
  - moscow ML bug
http://www.seas.upenn.edu/~sweirich/types/archive/1999-2003/msg01136.html

Recursive type definitions can cause unsatisfiable constraint cycles.
I don't know whether this is specific to subtyping.
https://issues.scala-lang.org/browse/SI-9715


Something complicated here.
I think it's interaction between first-class/path-dependent types,
existentials, overloading, and subtyping.
https://issues.scala-lang.org/browse/SI-7278
https://issues.scala-lang.org/browse/SI-1557
https://groups.google.com/forum/#!topic/scala-language/vQYwywr0LL4/discussion (best explanation)



hhvm object-private vs private, covariance
https://github.com/facebook/hhvm/issues/7216
maybe the same issue as covariance in ocaml private row types?


covariance and self types break
https://github.com/facebook/hhvm/issues/7254

intersection types and effects
http://www.cs.cmu.edu/~fp/papers/icfp00.pdf
seems sorta unsurprising given (Trevor Jim's?) result that P2 with intersections is roughly hindley-milner.


haskell abstraction and global coherence
https://stackoverflow.com/questions/34645745/can-i-magic-up-type-equality-from-a-functional-dependency


agda: subterm check and type equality (same as Denes' coq one?)
https://sympa.inria.fr/sympa/arc/coq-club/2014-03/msg00002.html
https://github.com/agda/agda/issues/1023/


failure of normalization in impredicative type theory
with proof-irrelevant propositional equality
andreas abel and thierry coquand

recursive cows:
https://github.com/effect-handlers/effects-rosetta-stone/tree/master/examples/recursive-cow


-->