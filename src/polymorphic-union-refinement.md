# Polymorphic union refinement

TAGS: polymorphism, typecase

Untagged union types are types of the form $A ∨ B$ that contain values
that are either of type $A$ or of type $B$, with no "tag" information to
denote which is which:
$$
\frac{Γ ⊢ e : A}{Γ ⊢ e : A ∨ B} \qquad \frac{Γ ⊢ e : B}{Γ ⊢ e : A ∨ B}
$$

Operationally, there is no obvious way to use an untagged union type:
unlike a *disjoint union* type, which contains an additional tag bit,
there is no general-purpose `match` expression that can extract either
the $A$ or the $B$.

For languages with runtime type introspection, some systems of
*refinement types* enable consumption of union types. If $x : A ∨ B$ is
found via a runtime type test to not be of type $A$, then it may be used
at type $B$. For instance, the following programs are valid Flow and
also valid TypeScript:
```typescript
function numberwang(x: number | string): string {
  if (typeof x === "number") {
    // in this block, `x: number`
    return `half of ${x * 2}`;
  } else {
    // in this block, `x: string`
    return `a string with ${x.length} characters`;
  }
}
```
```typescript
class Dog {
  name: string;
  constructor(name: string) { this.name = name; }
}
class Car {
  wheels: number;
  constructor(wheels: number) { this.wheels = wheels; }
}

function description(x: Dog | Car): string {
  if (x instanceof Dog) {
    // in this block, `x: Dog`
    return `the dog ${x.name}`;
  } else {
    // in this block, `x: Car`
    return `a car with ${x.wheels} wheels`;
  }
}
```

However, runtime type tests are not always so simple. The following code
also typechecks in both Flow and TypeScript, yet does not necessarily
return an `Array<T>`[^flowbug]:
```typescript
function orSingleton<T>(x: T | Array<T>): Array<T> {
  if (x instanceof Array) {
    return x;
  }
  return [x];
}
```

While `x instanceof Array` does imply that `x: Array<E>` for some `E`,
it does not imply specifically that `x: Array<T>`, even when it is known
that `x: T | Array<T>`. The problem is that `T` could itself be
`Array<U>` for some type `U`, so `x: Array<U> | Array<Array<U>>` is an
instance of `Array` in either case:
```typescript
// Purports to be the identity function, but fails when `x` happens to
// be an array.
function id<T>(x: T): T {
  const singletonArray: T[] = orSingleton(x);
  return singletonArray[0];
}

const digits: number[] = id([3, 1, 4]);
// unsound: `digits` is actually `3`
digits.includes(4);  // TypeError: digits.includes is not a function
```

In some sense, the core issue here is the refinement itself. A runtime
check that `x instanceof Array` says nothing about the element type of
the array, just as a runtime check that `typeof x === "function"` says
nothing about the domain or codomain. The untagged union type offers
a way to exploit this flaw.

By contrast, Typed Racket also supports refinements of union types, but
behaves correctly here:
```racket
#lang typed/racket

(: valid-refinement (All (T) (U Number (Boxof T)) (-> Number T) -> T))
(define (valid-refinement x from-number)
  (if (box? x)
      (unbox x)  ;; works: must be a `Boxof T` (good)
      (from-number x)))

(: invalid-refinement (All (T) (U T (Boxof T)) -> T))
(define (invalid-refinement x)
  (if (box? x)
      (unbox x)  ;; type error here: could be a box of something else (good!)
      x))
```

In Flow and TypeScript, this issue is resolved by using tagged
(disjoint) unions instead of untagged unions:
```typescript
type ElementOrArray<T> =
  {type: "ELEMENT", value: T} | {type: "ARRAY", array: T[]};

function orSingleton<T>(x: ElementOrArray<T>): T[] {
  if (x.type === "ARRAY") {
    return x.array;
  }
  return [x.value];
}

// Actually the identity function.
function id<T>(x: T): T {
  const singletonArray: T[] = orSingleton({type: "ELEMENT", value: x});
  return singletonArray[0];
}
```

Since each variant of `ElementOrArray<T>` includes a distinct `type`
tag, there is no ambiguity in `orSingleton`, and the required changes to
`id` fix the bug.

In JavaScript, all values are in fact tagged as one of `"string"`,
`"number"`, `"object"`, or a few other options, and the `typeof`
operator exposes this tag at runtime. Thus, "untagged" unions like
`number | null` or `boolean | string`, where every variant has a
distinct value tag, are actually tagged unions, and may still be used
safely.

[^flowbug]: [Refinement with `instanceof` and generic unions is unsound](https://github.com/facebook/flow/issues/6741), Flow issue #6741 (2018)
