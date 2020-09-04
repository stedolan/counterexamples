# Some kinds of Anything

TAGS: subtyping, polymorphism

In type systems with polymorphism and subtyping, there are four
different meanings that the phrase "any type" could have:

  - **Top type $⊤$**

    The top type is a supertype of every type. Any value can be
    turned into a value of type $⊤$, but given a value of type $⊤$
    there's not much you can do with it.

  - **Bottom type $⊥$**

    The bottom type is a subtype of every type. A value of type $⊥$
    can be turned into a value of any type, but there's no way
    to construct a value of type $⊥$. (If there is, the type system is
    broken. See [Eventually, nothing](eventually-nothing.md) for one
    example).

  - **Universal type $∀α . \; \dots$**

    A value of a universal type $∀α. φ(α)$ can be used at type $φ(X)$,
    for any type $X$. To construct one, the value must typecheck with
    an unknown abstract type $α$.

  - **Existential type $∃α . \; \dots$**

    A value of an existential type $∃α. φ(α)$ can be constructed from
    a value of type $φ(X)$, for any type $X$. To use one, the use must
    typecheck with an unknown abstract type $α$.

There are a couple of relationships between these types:

  - $⊥ = ∀α. α$

    $⊥$ is the type that can be used at any type, but cannot be constructed.

  - $⊤ = ∃α. α$

    $⊤$ is the type that can be constructed from any type, but cannot be used.

In some systems, these relationships extend to more complicated types
as well, for instance with a covariant type $\n{List}[A]$ of immutable
lists with elements of type $A$:

  - $\n{List}[⊥] = ∀α. \n{List}[α]$

    The elements of a single list $l$ cannot simultaneously be of
    every possible type $α$. Such a list must be empty, which is the
    same thing as being a list of $⊥$.

  - $\n{List}[⊤] = ∃α. \n{List}[α]$

    If a list contains elements of an unknown type $α$, then there is
    nothing useful we can do with them. The situtation is the same as
    if we had a list of $⊤$.

The extent to which languages implement these rules varies. Sometimes,
they are used to justify converting $List[⊥]$ to
$∀α.List[α]$. Sometimes, they are used to justify considering those
two as different spellings of the same type. Other times, they are not
used, but are definable in the language.

However, if implementing these rules it is crucial to keep track of
variance. Consider the type $∃α. (\n{List}[α] → \n{Int})$: this is a
function that accepts lists of some particular unknown type. It could
be, for instance, the $\n{sum}$ function of type $\n{List}[\n{Int}] →
\n{Int}$.

It is unsound to treat this the same as $\n{List}[⊤] → \n{Int}$,
as that would allow us to pass a list of, say, strings to the
$\n{sum}$ function. In fact, since all of the occurrences of $α$ are
contravariant (that is, to the left of a single function arrow), this
type is equivalent to $\n{List}[⊥] → \n{Int}$.

Scala supports subtyping and polymorphism, and several versions of the
language had this soundness issue, where $∃α. φ(α)$ was converted to
$φ(⊤)$ (spelled $φ(\n{Any})$ in Scala), without regard for the variance
of $φ$.


<!-- FIXME: cite garrigue, me -->

<!--
FIXME: cite & include code for counterexample
Scala replaces existentials with Any
which is obviously wrong in negative positions (should be Nothing)
https://issues.scala-lang.org/browse/SI-6680
https://github.com/lampepfl/dotty/issues/1870
https://issues.scala-lang.org/browse/SI-7886
https://issues.scala-lang.org/browse/SI-8737?focusedCommentId=75392&page=com.atlassian.jira.plugin.system.issuetabpanels:comment-tabpanel#comment-75392
https://issues.scala-lang.org/browse/SI-5189
-->
