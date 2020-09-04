# Curry's paradox

TAGS: recursive-types

In the simply-typed lambda calculus (which has only function types and
a base type), infinite loops are impossible and all programs halt.
Surprisingly, this stops being true once recursive types are added,
even if no recursive functions or loops are present in the language.

In most languages, there are plenty of ways to write programs that do
not terminate, and finding one more is not a soundness issue. However,
in *total* languages (ones in which all programs halt), this does
present a soundness issue and the allowable forms of recursive types
must be restricted.

The recursive types in question are those that contain a function or
method which takes the same type as an argument, which can be used to
build a nonterminating computation as follows:

```haskell
newtype Curry = Curry { r :: Curry -> Int }

f c = r c c
loop = f (Curry f)
```
```ocaml
type curry = { r : curry -> int }

let f c = c.r c
let loop = f { r = f }
```
```java
interface Curry {
  public int r(Curry x);
}
static int loop() {
  Curry c = new Curry() {
    public int r(Curry x) { return x.r(x); }
  };
  return c.r(c);
}
```

In logic, this is known as Curry's paradox.[^curry1] [^curry2] (This
has nothing to do with "function currying", other than being named
after the same person.) Under the propositions-as-types viewpoint, it
causes inconsistency: by replacing `Int` with any proposition $P$
(including `False`), the `loop` function above proves $P$.

To avoid this problem, languages that aim for logical consistency
(e.g. the proof assistants Coq and Agda) ban recursive types that take
themselves as arguments to functions or methods (so-called "negative
recursion"), avoiding Curry's paradox.

(In fact, due to a different issue, banning negative recursion is
often not enough, and recursive types must be restricted further to
"strictly positive recursion" to remain consistent. See ??)



[^curry1]: <https://en.wikipedia.org/wiki/Curry%27s_paradox>

[^curry2]: <https://plato.stanford.edu/entries/curry-paradox/>
