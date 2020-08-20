# Summary

[Counterexamples in Type Systems](title.md)
[Introduction](intro.md)

<!-- These need sorting -->

  - [Polymorphic references]() <!--polymorphic-references.md-->
  - [Covariant containers](general-covariance.md)
  - [Incomplete variance checking](incomplete-variance.md)

  - [Curry's paradox]() <!--currys-paradox.md-->

  - [Eventually, nothing](eventually-nothing.md)
  - [Self-justifying facts](self-justification.md)
  - [Null evidence]() <!--null-evidence.md-->

  - [Some kinds of Anything](anythings.md)
  - [Any (single) thing](anything-once.md)

  - [The avoidance problem](avoidance.md)

  - [Mutable matching](mutable-matching.md)

  - [Runtime type misinformation](runtime-misinformation.md)

  - [Distinctness I: Injectivity](distinctness-injectivity.md)
  - [Distinctness II: Recursion](distinctness-recursion.md)

  - [Overloading and polymorphism](overloading-polymorphism.md)

  - [Side-effects in types](side-effect-types.md)

  - [Subtyping vs. inheritance](subtyping-vs-inheritance.md)

  - [Suspicious subterms](suspicious-subterms.md)

  - [Privacy violation](privacy-violation.md)

  - [Underdetermined recursion](underdetermined-recursion.md)

  - [A little knowledge...](little-knowledge.md)

  - [There's only one Leibniz](only-one-leibniz.md)

<!--

  - Large injective type constructors ((Set -> Set) -> Set)
    Anticlassical and unsound with impredicativity
    See Russel O'Connor's post:
    https://coq-club.inria.narkive.com/iDuSeltD/agda-with-the-excluded-middle-is-inconsistent
    and also:
    https://github.com/leanprover/lean/issues/654
    https://gist.github.com/leodemoura/0c88341bb585bf9a72e6
    https://github.com/idris-lang/Idris-dev/issues/3687
    https://lists.chalmers.se/pipermail/agda/2010/001530.html
    https://lists.chalmers.se/pipermail/agda/2010/001565.html
    https://lists.chalmers.se/pipermail/agda/2010/001526.html

  - Non-strictly positive types
    + impredicativity (COLOG'88 Coquand)
    "Example: Non strictly positive occurrence"
    https://coq.inria.fr/refman/language/core/inductive.html#correctness-rules
    
  - Type:Type and Girard's
    http://okmij.org/ftp/Haskell/impredicativity-bites.html
    Leo's OCaml impl.
    Hurken's?

  - Impredicative bounded quantification
    [2] Bounded quantification is undecidable, Pierce
    http://www.cis.upenn.edu/~bcpierce/papers/fsubpopl.ps
    (example by Ghelli on page 4)
    Example in Java?
    generics in C#/Java/Scala:
    https://www.microsoft.com/en-us/research/publication/on-decidability-of-nominal-subtyping-with-variance/
    https://arxiv.org/abs/1605.05274

  - Linking code compiled with different type-system options
    pull gasche's -rectypes example out of distinctness
    https://github.com/ocaml/ocaml/issues/7113#issuecomment-473054796 (safe-string)
    https://github.com/agda/agda/issues/2487 - cubical vs. K

  - Abstraction vs. global coherence
    Haskell example of optimisation level affecting outcome
    "orphan instances"
    https://stackoverflow.com/questions/34645745/can-i-magic-up-type-equality-from-a-functional-dependency
    https://web.archive.org/web/20071111130403/http://modula3.elegosoft.com/pm3/pkg/modula3/src/discussion/partialRev.html
    https://wiki.haskell.org/Orphan_instance

  - Type well-formedness:
    https://github.com/rust-lang/rust/issues/25860
    implicit conversions (subtyping) between types with different well-formedness constraints
    lets you conclude the well-formedness constraints from no evidence.
    similar to some interesection type bugs, I think
    

"Injective type families for Haskell", Eisenberg.
(ctrl-F "unsound")

Quotient types:
  - http://strictlypositive.org/Ripley.pdf, 2
  - https://lists.chalmers.se/pipermail/agda/2012/004052.html

Conor's ripley (embiggening definitional equality)
http://strictlypositive.org/Ripley.pdf
1. Codata
3. (0 -> A)

Large eliminations are bad:
p70 of TAPL2  (coquand 1986)

p88 of TAPL2 (effects)


Berardi's paradox and others in the coq stdlib

https://coq.inria.fr/cocorico/CoqTerminationDiscussion

"specialization" in rust:
https://aturon.github.io/blog/2017/07/08/lifetime-dispatch/

rust JoinGuard
https://github.com/rust-lang/rust/issues/24292

more rust:
https://github.com/rust-lang/rust/issues/26656

http://permalink.gmane.org/gmane.comp.lang.haskell.cafe/77116
http://lambda-the-ultimate.org/node/4031



GADTs and subtyping
An invariant case of a covariant definition allows constructing
a covariant array, hilarity ensues.
https://issues.scala-lang.org/browse/SI-6944
https://issues.scala-lang.org/browse/SI-7952
https://issues.scala-lang.org/browse/SI-8241

singleton elimination?
https://github.com/leanprover/lean/issues/654


Recursive type definitions can cause unsatisfiable constraint cycles.
I don't know whether this is specific to subtyping.
https://issues.scala-lang.org/browse/SI-9715


Something complicated here.
I think it's interaction between first-class/path-dependent types,
existentials, overloading, and subtyping.
https://issues.scala-lang.org/browse/SI-7278
https://issues.scala-lang.org/browse/SI-1557
https://groups.google.com/forum/#!topic/scala-language/vQYwywr0LL4/discussion (best explanation)

hack variance bug:
https://github.com/facebook/hhvm/issues/7216

This bug is a mix of variance-checking and scope-checking.
Types that don't escpe don't need variance-checking, but verify that they don't escape!
  https://github.com/scala/bug/issues/5060 
 


intersection types and effects
http://www.cs.cmu.edu/~fp/papers/icfp00.pdf
NB: mitchell's distributivity is unsound with effects

failure of normalization in impredicative type theory
with proof-irrelevant propositional equality
andreas abel and thierry coquand

recursive cows:
https://github.com/effect-handlers/effects-rosetta-stone/tree/master/examples/recursive-cow


wtf wtf wtf
https://github.com/lampepfl/dotty/issues/50
scroll for namin/tiark comments

I tink this is intersection types?
The existence of an intersection can imply that two types are compatible
but null / nonterminating evidence can fuck it up


mix of intersection-ish types and negation-as-failure distinctness
https://github.com/ocaml/ocaml/issues/7269

loads here:
https://github.com/lampepfl/dotty/search?q=unsound&type=Issues
https://github.com/facebook/hhvm/issues?q=is%3Aissue+author%3Aacrylic-origami+
https://youtrack.jetbrains.com/issues?q=looks%20like:%20KT-7972

https://youtrack.jetbrains.com/issue/KT-7972

girard1971.v

comments from jeremy:

2. I think another issue around that time was compilation in an
inconsistent context, e.g. accepting the following kinds of program:

      let foo : (int, string) eql -> unit =
       fun Refl -> 1 + "two"

but I don't have a reference to hand.  Relatedly, there's care taken
in the OCaml compiler not to lift assumptions about types (e.g. for
address typing) across matches, but again I don't know the history
offhand.

6. There's an unsound interaction between generative and applicative
functors as implemented in Moscow ML, involving a notion of generative
signatures:
    https://www.seas.upenn.edu/~sweirich/types/archive/1999-2003/msg01136.html

7.  I'm not sure about the explanation in "side-effects in types"
because (1) Russo's example doesn't involve side effects (2) OCaml
does allow type expressions that (look like they) can cause mutation,
such as F(X).t.  It seems that the issue isn't side effects, but types
that can depend on value-level computation.  (OCaml actually allows
these, too, but they have to be in generative functors, so that the
types produced each time the computation is run are considered
distinct.)

-->