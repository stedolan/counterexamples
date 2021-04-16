# Under false pretenses

TAGS: empty-types, equality

The empty type $0$ has no values, so a variable $x : 0$ can never be
supplied. So, any code within the scope of such a variable can never
be executed. (For a lazy language like Haskell, read "underneath a
case split on" instead of "within the scope of").

In such unreachable scopes, many type systems become a little
strange. This strangeness is not by itself a problem, as it can only
arise in unreachable code, but care must be taken to keep it contained.

For example, it is possible in such a scope to construct an expression
of a equality type, "proving" that $\n{Int}$ and $\n{String}$ are
equal:

```ocaml
type empty = |
type (_,_) eq =
  Refl : ('a, 'a) eq
let f (x : empty) =
  let eq : (int, string) eq = match x with _ -> . in
  ...
```
```haskell
{-# LANGUAGE EmptyCase #-}
data Empty
data Eq a b where
  Refl :: Eq a a

f :: Empty -> ...
f x = ...
  where
    eq : Eq Int String
    eq = case x of {}
```

If use of `eq` introduces the equation $\n{Int} = \n{String}$, then
you may end up with nonsensical expressions such as `20 - "hello"`
becoming well-typed. This can interfere with compiler optimisations:
the *constant folding* optimisation eagerly computes arithmetic
operations whose arguments are constant, and may not be able to
handle, say, subtraction of a string from an integer, even in dead
code. Generally, hoisting optimisations (those which move an
expression to an earlier position) must be treated carefully, as they
risk moving a nonsensical computation from dead code to code that
actually runs.

In type systems based on Martin-Löf's Intensional Type Theory, a more
subtle issue can arise. ITT-based systems have a relation $A ≡ B$
called *definitional equality* (or *judgemental equality*).
Definitional equality determines which expressions are considered
"obviously equal" (that is, can be substituted for each other in any
context with no explicit coercion required), and part of the design of
an ITT-based type system is to decide which rules can be included in
$≡$ while keeping the relation decidable.

In the presence of an empty type $0$, it is tempting to make any two
functions $f, g : 0 → A$ definitionally equal, as there is only one
possible function from $0$ to any type. However, as noted by
McBride[^ripley], this choice breaks decidability of $≡$, because
under the scope of a variable $x : 0$, we have:
$$
\n{true} ≡ (λ (y : 0). \n{true}) x ≡ (λ (y : 0). \n{false}) x ≡ \n{false}
$$

So, in order to decide whether $\n{true} ≡ \n{false}$, we would first
need to decide whether the type of any variable in scope is or can be
converted to $0$, which is not in general decidable.

[^ripley]: [Grins from my Ripley
Cupboard](http://strictlypositive.org/Ripley.pdf), Conor McBride,
2009.
