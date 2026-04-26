---
name: clarity-over-cleverness
description: Apply clarity-over-cleverness rewrites — prefer code a junior engineer can read at a glance over compact-but-clever code. Use during `/build`'s simplify step and during `/code-simplify` (alias "simplify the code"). Never weakens behavior; suite must remain green.
when_to_use:
  - Phase 4 (Build) — simplify step inside `/build <task-id>`.
  - On-demand — user runs `/code-simplify` or says "simplify the code", "make this clearer", "make this readable", or "remove the cleverness".
  - During code review — flag clever code as `minor` with a suggested rewrite.
authoritative_references:
  - .windsurf/skills/spring-code-review-rubric/SKILL.md (section 8)
---

# Clarity over cleverness

## Rule of thumb

If a competent engineer who has never seen this code needs more than five seconds to understand a line, that line is a candidate for rewrite.

The bar is **not** "fewer characters". The bar is **fewer surprises**.

## Targets (apply, in order)

### 1. Untangle nested ternaries

Bad:

```java
return a ? (b ? x : y) : (c ? z : w);
```

Better:

```java
if (a) {
    return b ? x : y;
}
return c ? z : w;
```

Best (when shapes line up):

```java
return switch (state) {
    case ACTIVE -> x;
    case PAUSED -> y;
    case CLOSED -> z;
    case PENDING -> w;
};
```

### 2. Streams only when they read better than a loop

Bad (clever stream that's actually obscure):

```java
return items.stream()
    .collect(Collectors.toMap(
        Item::id,
        Function.identity(),
        (a, b) -> a.timestamp().isAfter(b.timestamp()) ? a : b));
```

Better (explicit loop, named purpose):

```java
Map<Id, Item> latestById = new HashMap<>();
for (Item it : items) {
    Item existing = latestById.get(it.id());
    if (existing == null || it.timestamp().isAfter(existing.timestamp())) {
        latestById.put(it.id(), it);
    }
}
return latestById;
```

(If the team consistently uses streams, follow the team. The point is consistency + readability, not banning streams.)

### 3. Inline once-used helpers

If a private method has exactly one caller AND the helper name doesn't add information, inline it. Reverse if a long method has a recognizable middle "phase" — extract that phase with a domain-meaningful name.

### 4. Kill option flags with one used value

Bad:

```java
public Result calculate(Input in, boolean strict, boolean retry, Mode mode) { ... }
// every caller passes (in, true, false, Mode.DEFAULT)
```

Better: drop the unused dimensions; add them back when a real second caller exists.

### 5. Replace clever names with domain names

Bad: `processX`, `handleData`, `doWork`.
Better: `redeemGiftCard`, `priceWithDiscount`, `rejectIfExpired`.

Pull names from the `01-spec.md` glossary.

### 6. Remove premature abstraction

- Interface with one implementation, one caller, no test seam → inline the implementation.
- Generic type parameter never used by more than one type → concrete type.
- Builder for an object with two fields → constructor.

### 7. Prefer early return to nested `if`

Bad:

```java
if (x != null) {
    if (x.valid()) {
        return x.value();
    }
}
return defaultValue;
```

Better:

```java
if (x == null) return defaultValue;
if (!x.valid()) return defaultValue;
return x.value();
```

## What this skill never does

- Change behavior. The full suite must stay green after each rewrite.
- Reduce coverage. If a rewrite removes a branch, also remove the test asserting that branch — and verify the AC is still covered by another test.
- Touch files outside `Files in scope`.
- Rename public API across module boundaries (that's a refactor task, not a simplify pass).

## Process inside `/build`'s simplify step

1. Re-read the diff for the task.
2. For each function changed in green/refactor, ask: would a junior reading this for the first time understand it in five seconds?
3. If no, apply the rewrites above, one at a time, running tests between each.
4. Append a `simplify` block to `05-implementation-log.md` for each substantive change with before/after snippets.

## When the user says "simplify the code"

Treat as `/code-simplify` invocation:

1. Run on the **currently open file** OR the **last-touched files in the active feature**.
2. Apply the same process.
3. Suite must stay green.
4. Show the user a diff summary; do **not** auto-commit.
