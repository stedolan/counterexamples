# Index and Glossary

### Polymorphism

The word "polymorphism" can refer to several different things. Here,
it means "parametric polymorphism": types like $∀α .\; α → α$,
allowing the same value to be used at many possible types,
parameterised by a type variable. This feature is sometimes called
"generics".

Other meanings include "subtype polymorphism" (see
[subtyping](#subtyping)) and "ad-hoc polymorphism" (see
[overloading](#overloading)).

[#polymorphism]

### Subtyping

Subtyping allows a value of a more specific type to be supplied where
a value of a more general type was expected, without the two types
having to be exactly equal.

[#subtyping]

### Overloading

An *overloaded function* has several different versions all with the
same name, where the language picks the right one to call by examining
the types of its arguments at each call site.

[#overloading]

### Recursive types

Recursive types are types whose definition refers to themselves,
either by using their own name during their definition, or by using
explicit fixpoint operators like $μ$-types.

[#recursive-types]

### Variance

Types that take parameters (like $\n{List}[A]$) may have subtyping
relationships that depend on the subtyping relationships of their
parameters: for instance, $\n{List}[A]$ is a subtype of $\n{List}[B]$
only if $A$ is a subtype of $B$. The manner in which the parameter's
subtyping affects the whole type's subtyping is called *variance*.

[#variance]

### Mutation

The presence of mutable values (reference cells, mutable arrays, etc.)
in a language means that there are expressions which, when evaluated
twice, yield different values both times (which can have consequences
for the type system).

[#mutation]

### Scoping

When types are types defined locally to a module, function or
block, the compiler must check do not accidentally leak out
of their scope.

[#scoping]

### Typecase

*Typecase* refers to any runtime test that checks types. Several other
 names for this feature exist: `instanceof`, downcasting, matching on types.

[#typecase]

### Empty types

An empty type is a type that has no values, and can represent the
return type of a function that never returns or the element type of a
list that is always empty. These are not to be confused with *unit
types* like C's `void` or Haskell's `()`, which are types that have a
single value (and consequently carry no *information*).

[#empty-types]

### Equality

Determining whether two types are equal is a surprisingly tricky
business, especially in a language with advanced type system features
(e.g. dependent types).

[#equality]

### Injectivity

A parameterised type like $\n{List}[A]$ is said to be *injective* if
$\n{List}[A] = \n{List}[B]$ implies $A = B$. All, some or none of a
language's parameterised types may have this property.

[#injectivity]

### Totality

In a *total* language, all programs terminate, and unbounded recursion
or infinite looping is impossible. Enforcing this property places a
significant extra burden on the type checker.

[#totality]

### Abstract types

An abstract type is one whose implementation is hidden: the type may
in fact be implemented directly as another type, but this fact is not
exposed.

[#abstract-types]

### Impredicativity

A type system is *predicative* if definitions can never be referred
to, even indirectly,   before they are defined. In particular,
polymorphic types $∀α. \dots$ are predicative only if $α$ ranges over
types not including the polymorphic type being defined. Predicative
systems usually have restricted polymorphism (in $∀α. \dots$, $α$ may
range only over types that do not themselves use $∀$, or there may be
a system of stratified levels of $∀$-usage). One hallmark of
impredicative systems is unrestricted $∀$ (present in e.g. System F)

[#impredicativity]