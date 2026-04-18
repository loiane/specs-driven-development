# ADR-001: Use ArchUnit (alone) for module boundaries

- **Status:** accepted
- **Date:** 2025-01-15
- **Deciders:** spring-architect, tech lead

## Context

The `checkout` service is being structured around top-level packages
(`giftcard`, `order`, `shared`) that act as bounded contexts. We need a way
to enforce that:

1. One module never imports from another module's `internal` sub-package.
2. There are no cyclic dependencies between top-level packages.
3. Allowed dependencies (e.g. `order` → `giftcard.api`) are documented and
   verified at build time.

## Options considered

1. **No enforcement** — rely on code review only. Rejected: violations leak
   in over time, especially under deadline pressure.
2. **Custom build script** — write a Groovy/Bash check that scans imports.
   Rejected: yet another DSL to maintain.
3. **Spring Modulith** — annotation + verifier; pleasant developer experience
   but adds a runtime dependency, ties module declaration to package-info
   files, and overlaps with what ArchUnit already does.
4. **ArchUnit alone** — pure-test dependency, expressive enough to encode
   "internal sub-packages are private", "no cycles", and explicit allowed
   dependency arrows.

## Decision

Adopt **option 4: ArchUnit only**. Each bounded context is a top-level
package under `com.example.checkout`. Within each module, an `internal`
sub-package holds package-private implementation; an `api` sub-package holds
the published surface. The harness's architecture gate (layer 4) runs the
following rules in `ArchitectureTests`:

- `giftcardInternalIsHidden` — no class outside `..giftcard.internal..`
  may depend on classes inside it.
- `giftcardDoesNotDependOnOrder` — directional dependency only.
- `noCyclesBetweenTopLevelPackages` — `slices().matching("com.example.checkout.(*)..").should().beFreeOfCycles()`.

These rules ship with the existing ArchUnit dependency (already in the
parent POM). No new runtime dependency.

## Consequences

- **Positive**: zero runtime cost; a single source for architecture rules;
  freezing baseline is supported for brownfield; rules read like English.
- **Negative**: module boundaries are expressed in test code rather than in
  package-info files; new modules require explicit ArchUnit additions.
- **Follow-up**: encode the rule set in the `archunit-rules` skill so future
  features get the same defaults.
