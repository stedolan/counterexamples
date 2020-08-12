# Curry's paradox



In the simply-typed lambda calculus (which has only function types and
a base type), infinite loops are impossible and all programs halt. So,
we might expect the same to be true in languages that extend the
simply-typed lambda calculus with more features (such as Haskell and
ML), as long as we avoid constructs like while loops and recursive
functions.


Surprisingly, this turns out not to be the case. In most languages
that allow user-defined data types, you can build a nonterminating
program out of just functions and one user-defined type.

In most programming languages, 



<!-- FIXME: write this -->