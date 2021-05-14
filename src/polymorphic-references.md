# Polymorphic references

TAGS: polymorphism, mutation

Polymorphism, as found in ML and Haskell (and in C# and Java where
it's called "generics") lets the same definition be reused with
multiple different unrelated types. For instance, here's a polymorphic
function that creates a single-element list:
```ocaml
let singleton x = [x]
```
```java
static <A> List<A> singleton(A x) {
    return Arrays.asList(x);
}
```

The same `singleton` function can be used to turn an integer into a
list of integers, and also to turn a string into a list of strings.

The standard typing rule for polymorphism is:

$$
\frac{Γ ⊢ e : A}{Γ ⊢ e : ∀α . A} \text{ if $α$ not free in $Γ$}
$$

That is, if an expression $e$ has a type $A$ which mentions a type
variable $α$, and the type variable $α$ is used only in the type
$A$, then the value of $e$ can be reused with different types
substituted for <nobr>$α$.</nobr>
The justification is that different uses of $e$ can use different
types for $α$, since nothing outside the type of $e$ depends on which
type is chosen. This process is called _generalising_ the type variable $α$.

But if $e$ can allocate mutable state (say, a mutable reference cell,
or a mutable array), then different uses of $e$ can share state:
```ocaml
let r = ref [] in           (* r : ∀ α . α list ref *)
r := [0];                   (* using r as an int list ref *)
print_string (List.hd !r)   (* using r as a string list ref *)
(* Crash! (Well, it would, if the OCaml compiler allowed this) *)
```

One obvious-but-broken solution is to disallow polymorphism when the
type of $e$ mentions types with mutable state. This doesn't work:
because functions can hide types in their closures, the problem occurs
even when the type of $e$ doesn't mention mutable state:
```ocaml
let f =
  let r = ref None in
  fun x ->
    match !r with
    | None -> r := Some x; x
    | Some x -> x
(* The value restriction means f is not polymorphic,
   but if it were then this would crash: *)
let _ =
  let _ = f 42 in
  print_string (f "hello")
```

This problem originated in the ML family of languages, as these were
the first to combine mutable references and polymorphism. A related
problem appeared in Standard ML of New Jersey's implementation of
`call/cc`[^callcc], which like mutable references allows multiple uses of an
expression to share state (by sharing the continuation). Recently, an
instance of this problem arose in OCaml, due to an incorrect
typechecker refactoring[^ocaml411]. The problem has also appeared in
Elm[^elm], using channels to provide the shared mutable state.

```sml
(* Counterexample by Bob Harper and Mark Lillibridge *)
fun left (x,y) = x;
fun right (x,y) = y;

let val later = (callcc (fn k =>
	(fn x => x,
         fn f => throw k (f, fn f => ()))))
in
	print (left(later)"hello world!\n");
	right(later)(fn x => x+2)
end
```
```ocaml
(* Counterexample by Thierry Martinez *)
let f x =
  let ref : type a . a option ref = ref None in
  ref := Some x;
  Option.get !ref

let () = print_string (f 0)
```
```elm
-- Counterexample by Izaak Meckler
import Signal
import Html
import Html.Attributes(style)
import Html.Events(..)
import Maybe

c = Signal.channel Nothing

s : Signal Int
s = Signal.map (Maybe.withDefault 0) (Signal.subscribe c)

draw x =
  Html.div
  [ onClick (Signal.send c (Just "I am not an Int"))
  , style [("width", "100px"), ("height", "100px")]
  ]
  [ Html.text (toString (x + 1)) ]
  |> Html.toElement 100 100

main = Signal.map draw s
```


There are several solutions:

  - **Separate pure and effectful types**

    The original solution chosen in Standard ML distinguishes
    *applicative* type variables from *imperative* type variables.
    Only applicative variables can be generalised, and only imperative
    variables can be used in the type of mutable references. There are
    several variants of this system, from Tofte's original one to
    extensions used in SML/NJ by MacQueen and
    others. Greiner[^greiner] has a survey of the variants.

    This approach has the disadvantage that internal use of mutation
    cannot be hidden: a polymorphic sorting function that internally
    uses temporary mutable storage cannot be given the same type as
    one that does not.

    Leroy and Weis[^leroy] propose a related approach that avoids
    generalising type variables that may be used in mutable
    references, without needing to distinguish two classes of type
    variables.  However, to avoid the issue above of functions hiding
    types in their closure, their solution must distinguish two
    different sorts of function type according to whether their
    closure may contain mutable references.

  - **The value restriction**

    A simpler solution was proposed by Wright[^wright] and is now used
    in most implementations of ML: generalisation of an expression's
    type only happens if the expression is a *syntactic value*, a
    class that contains e.g. function definitions and tuple
    constructions, but not function calls or anything that could
    possibly allocate a mutable reference.

    This solution is much simpler than the type-based approaches, but
    in some cases less powerful: notably, a partial application of a
    curried function cannot be generalised without manually eta-expanding.

    In effect, this is also the solution used by e.g. Java and C#: in these
    languages, only methods may be given generic types, not
    fields. This ensures that generalisation only occurs on function
    definitions.

  - **Effect typing**

    Type-and-effect systems have a typing judgement $Γ ⊢ e : A\, !\,
    Δ$, where $Δ$ is the *effect*, representing effects that occur as
    part of evaluating $e$. The typing rule for polymorphism in such
    systems can generalise a type variable $α$ only if it does not
    appear in $Γ$ *or* $Δ$. If allocating a new mutable reference of
    type $T$ results in an effect mentioning $T$ appearing in $Δ$,
    then polymorphic mutable references cannot be created.

  - **Effect marking**

    Instead of a full-blown type-and-effect system, polymorphic
    mutable references can be avoided using a type-level marker on
    computations that may perform any effects at all, and then
    disabling polymorphism on effectful computations.

    This is the approach taken by Haskell with its monadic encoding of
    effectful computations in the type `IO a`. Values of this type
    represent "IO actions" - computations that, when performed, yield
    results of type `a`, possibly causing some side-effects as
    well. Polymorphism is available as usual when constructing IO
    actions, but the type of an IO action's result (as used in `do`
    notation or via monadic combinators) cannot be generalised.
    Haskell's `do` notation for monadic computation does support a
    `let` syntax, but its typing is quite different from ordinary
    `let`, and it does not allow introducing polymorphism even with an
    explicit annotation.

    This mechanism allows Haskell to distinguish the following two types:

    ```haskell
    good :: forall a . IO (IORef (Maybe a))
    bad  :: IO (forall a . IORef (Maybe a))
    ```

    Here, `good` is an IO action which allocates a mutable reference
    of an arbitrary type (fine, implementable as `newIORef Nothing`),
    while `bad` is an IO action which allocations a polymorphic
    mutable reference (unsound). Note that the only distinction
    between these two is the placement of `IO`.

    This reliance on marking `IO` is why Haskell's `unsafePerformIO`
    is actually unsafe, as it can be used to strip the `IO` marker and
    create polymorphic mutable references:
    ```haskell
    import Data.IORef
    import System.IO.Unsafe
    badref :: IORef (Maybe a)
    badref = unsafePerformIO (newIORef Nothing)
    main = do
      writeIORef badref (Just 42)
      Just x <- readIORef badref
      putStrLn (x 1)
    ```


[^callcc]: [ML with callcc is unsound](http://www.seas.upenn.edu/~sweirich/types/archive/1991/msg00034.html) (TYPES mailing list) Bob Harper and Mark Lillibridge (1991)

[^ocaml411]: <https://github.com/ocaml/ocaml/issues/9856> (2020)

[^elm]: <https://github.com/elm/compiler/issues/889> (2015)

[^greiner]: [Weak Polymorphism Can Be Sound](https://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.37.5096&rank=1), John Greiner (1996)

[^leroy]: [Polymorphic type inference and assignment](https://hal.inria.fr/hal-01499974/), Xavier Leroy and
Pierre Weis (1991)

[^wright]: [Simple Imperative Polymorphism](https://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.37.5096&rank=1), Andrew Wright (1995)
