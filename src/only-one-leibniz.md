# There's only one Leibniz

TAGS: equality

Leibniz's characterisation of what it means for $A$ to equal $B$ is
that if $P(A)$ holds for any property <nobr>$P$,</nobr> then so does $P(B)$. In
other words, equality is the relation that allows substitution of $B$
for $A$ in any context.

There can only be one reflexive relation with this substitution
property.  If we have two substitutive reflexive relations $\sim$ and
$\simeq$, then as soon as $A \sim B$ we can substitute the second
occurrence of $A$ for $B$ in $A \simeq A$, so
necessarily $A \simeq B$ too.

Haskell[^haskell] had a soundness issue that arose from trying to have
two distinct equality-like relations[^conor]. Haskell supports
`newtype`, a mechanism for creating a new copy $T'$ of a
previously-defined type $T$, and the `GeneralizedNewtypeDeriving`
mechanism allowed any typeclass that had been implemented for $T$ to be
automatically derived for $T'$.

`GeneralizedNewtypeDeriving` was therefore a form of substitution in
an arbitrary context, which was in conflict with the equality relation
in the rest of Haskell's type system, which considered $T$ and $T'$
distinct. In particular, type families are allowed to distinguish $T$
and $T'$, leading to this counterexample:
```haskell
-- Counterexample by Stefan O'Rear
{-# OPTIONS_GHC -ftype-families #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
data family Z :: * -> *

newtype Moo = Moo Int

newtype instance Z Int = ZI Double
newtype instance Z Moo = ZM (Int,Int)

newtype Moo = Moo Int deriving(IsInt)
class IsInt t where
    isInt :: c Int -> c t
instance IsInt Int where isInt = id
main = case isInt (ZI 4.0) of
         ZM tu -> print tu -- segfaults
```

The fix in Haskell was to introduce *roles*[^roles], implicitly
annotating each type and type parameter according to whether it was
used in a context allowing $T = T'$ (the *representational role*,
allowing efficient coercions between newtypes and their underlying
types) or an a context assuming $T \neq T'$ (the *nominal role*, used
in type families). For more on roles, see the GHC wiki[^rolewiki].


[^haskell]: <https://ghc.haskell.org/trac/ghc/ticket/1496> (2007)

[^conor]: The characterisation of this issue as two conflicting equalities is [due to Conor McBride](https://www.reddit.com/r/haskell/comments/y8kca/generalizednewtypederiving_is_very_very_unsafe/c5tawm8/)

[^roles]: [Safe Zero-cost Coercions for Haskell](https://dl.acm.org/doi/abs/10.1145/2628136.2628141) (ICFP '14), Joachim Breitner, Richard A. Eisenberg, Simon Peyton Jones, Stephanie Weirich (2014)

[^rolewiki]: <https://gitlab.haskell.org/ghc/ghc/-/wikis/roles>
