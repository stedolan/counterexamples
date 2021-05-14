# Introduction

Welcome to *Counterexamples in Type Systems*, a compendium of horrible
programs that crash, segfault or otherwise explode.

The "counterexamples" here are programs that go wrong in ways that
should be impossible: corrupt memory in Rust, produce
`ClassCastException` in cast-free Java, segfault in Haskell, and so
on. This book is a collection of such counterexamples, each with some
explanation of what went wrong and references to the languages or
systems in which the problem occurred.

It's intended as a resource for researchers, designers and
implementors of static type systems, as well as programmers interested
in how type systems fit together (or don't).


## Type systems

For the purposes of this book, a "type system" is a system that does
local checks of a program's source code, in order to establish some
global property about the program's behaviour. The local checks
usually assign a type to each variable and verify that they are used
only in contexts appropriate to their type, while the global property
varies but is generally some sort of safety property: the absence of
memory corruption, use-after-free errors, and the like.

This is intentionally a fairly narrow definition. Some examples of
things that are not "type systems":

  - **Linters**: Linters do local checks of a programs's source code,
    but don't try to establish any global property. Just because a
    program passes a linter's checks does not imply anything definite
    about its behaviour.

  - **Python's type system**: Dynamic languages like Python do local
    type checks to establish global safety properties. However, the
    type checks are not done purely on the program's source code
    before running it, but examine the actual runtime inputs as well.

  - **C++'s type system**: C++ (among other unsafe languages) has a
    type system that does many local checks of a programs's source
    code. However, passing these checks does not establish anything
    definite about a program's behaviour: many C++ programs pass all
    of the compiler's type checking, and yet exhibit use-after-free
    errors, memory corruption, and arbitrary behaviour when run.

  - **Some program analysis tools**: Some static program analysis
    tools do only global checks (requiring the whole program's source
    code to be available at once), while others detect certain issues
    but do not attempt to establish any global property when no issues
    are found. Still others do fit the definition of "type system",
    though: the line here is blurry.

This is not to say that there's something wrong with the above tools,
but they're not what this book is about. Some examples of things that
do fit the definition are the type systems of languages like Java,
Haskell and Rust.


## Soundness and counterexamples

Type systems make the claim that any program that passes the local
type checks will definitely have the global safety properties. A type
system is *sound* if this claim is true, and to say that a system is
*unsound* is to say that there exists some program which passes all
type checks, and yet whose behaviour violates the global safety
properties (corrupts memory, crashes unexpectedly, etc.). A
*counterexample* is such a program, exhibiting a *soundness bug*.

Different languages enforce different properties, so exactly what
"soundness" means varies somewhat. For instance, a global property
established by the Coq type system is that all programs halt. So, a
program that looped infinitely would be a counterexample in Coq, but
not in Java, which makes no such claim.

The goal of this book is to collect such counterexamples, especially
those that crop up in similar forms across multiple languages. These
fall into a couple of broad categories:

 - **Missing checks**: The simplest sort of soundness bug is when some
   important type check is missing from the type checker. Usually,
   these are straightforward bugs, easily fixed once discovered,
   highly specific to a particular compiler, and not very interesting.
   However, certain missing checks are common mistakes that keep
   coming up across many different type checkers and languages, and a
   few of these are included here: for instance, missing [variance
   checks](incomplete-variance.md) or [scope checks](scope-escape.md).

 - **Feature interactions**: Often, two type system features which are
   perfectly sound when used in isolation have some tricky
   interaction when used together. Examples of this include mixtures
   of [polymorphism and mutability](polymorphic-references.md) or
   [polymorphism and overloading](overloading-polymorphism.md) or
   [intersections and mutability](intersecting-references.md).

 - **Subtle differences**: If two parts of a type system use different
   but similar versions of the same concept, the gap between them can
   often cause soundness bugs. For instance, does "private" mean
   [private to an object or private to a class](privacy-violation.md)?
   Does "unequal" mean ["not provably equal" or "provably
   distinct"](distinctness-injectivity.md)?


## Organisation (or lack thereof)

Since so many of the counterexamples here depend on interactions
between disparate parts of a complex type system, it would be tricky
to separate them all into distinct coherent topics, and no attempt to
do so has been made.

Instead, each entry is tagged with the type system features involved,
and in lieu of a table of contents there is an [index and
glossary](glossary.md) listing the features and the counterexamples in
which they appear.

The entries themselves are mostly independent, and it should be
possible to read them in any order. However, a few of them do refer to
previous entries, and some attempt was made to put the simpler entries
earlier, so if you do intend to read the whole thing then going start
to finish is best.



## A note on sources

While much type system research appears in formal academic
publications, it is relatively rare (but not unheard of!) to publish a
paper about an unsound system.

So, as well as academic papers, many of the counterexamples here are
drawn from unpublished notes, the archives of the
[TYPES](https://lists.seas.upenn.edu/mailman/listinfo/types-list)
forum, blogs by programming language researchers, designers and
implementors, and language-specific bugtrackers, forums and mailing
lists.  A major reason for the existence of this book is to collect
these various sources together.

In particular, compiler bugtrackers are a major source of the
counterexamples reproduced here. Try not to read too much into how
often different bugtrackers show up: while it is tempting to assume
that the more often a compiler appears, the buggier it is, this would
be wrong for several reasons:

  - the author works professionally on OCaml, so it is somewhat
    over-represented due to familiarity,

  - the same applies to other languages that the author likes or at
    least vaguely understand,s and

  - languages whose community does a good job of publicly tracking,
    explaining, and writing up issues that arise are also
    over-represented.
