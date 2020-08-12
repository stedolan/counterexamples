# Polymorphic references and the value restriction

Polymorphism, as found in ML and Haskell (and in C# and Java where
it's called "generics"[^1]) lets the same definition be reused with
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
variable $α$, and the type variable $α$ is not used outside the type
of $e$, then the value of $e$ can be reused with different types
substituted for $α$.

# The problem

The justification for the polymorphism rule is that different uses of
$e$ can use different types for $α$, since nothing outside the type of
$e$ depends on which type is chosen.

But if $e$ can allocate mutable state (say, a mutable reference cell,
or a mutable array), then different uses of $e$ can share state:
```ocaml
(* Rejected by OCaml due to the value restriction *)
let r = ref [] in (* r : ∀ α . α list ref *)
r := [0]; (* using r as an int list ref *)
print_string (List.hd !r) (* using r as a string list ref *)
(* Crash! *)
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
```
The first time this function is called, it returns its argument. On
all subsequent calls, it returns whatever it was called with first.

If we naively implemented the polymorphism rule above, we'd end up
giving this function the type:
$$
f : ∀ α . α → α
$$
which would crash the second time we called it (if the type didn't
match the first).

?? frontier

# Solution 1: separating pure from effectful types

# Solution 2: the value restriction

# Solution 3: separating pure from effectful computations


newIORef :: IO (IORef a)

(>>=) :: IO a → (a → IO b) → IO b

I need an          IO (∀ a . IORef a)
but I have a ∀ a . IO (IORef a)



[^1]: The word "polymorphism" has too many meanings.

???

FIXME: disambig polymorphism

FIXME: everything


<!--

call/cc has the same problem:

http://www.seas.upenn.edu/~sweirich/types/archive/1991/msg00034.html

-->