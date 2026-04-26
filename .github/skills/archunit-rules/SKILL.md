---
name: archunit-rules
description: Encode architecture invariants as ArchUnit rules. Use when defining or reviewing layer boundaries, package dependencies, naming conventions, or cross-module access.
when_to_use:
  - Phase 5 (Test) — adding architectural cross-cutting suites.
  - Brownfield onboarding — capturing the architecture as it currently exists, then ratcheting it.
  - Any review where a `.internal.` import is suspect.
authoritative_references:
  - https://www.archunit.org/userguide/html/000_Index.html
---

# ArchUnit rules

## Default rule set (greenfield)

These rules assume **package-by-feature with typed sub-packages**
(see `spring-boot-4-conventions`): each top-level package under the application
root is a feature/domain with an `api` (published) sub-package and private
impl sub-packages (`internal/`, `model/`, `repository/`, `service/`).
There are **no** top-level `controller` / `service` / `repository` packages.

Place these in `src/test/java/.../arch/ArchitectureTest.java`:

```java
@AnalyzeClasses(packages = "com.example.shop", importOptions = ImportOption.DoNotIncludeTests.class)
class ArchitectureTest {

    // Other features depend only on a feature's api package, never on its private impl packages.
    @ArchTest
    static final ArchRule internalIsPrivateToItsFeature =
        slices().matching("com.example.shop.(*)..")
                .should().notDependOnEachOther()
                .ignoreDependency(
                    JavaClass.Predicates.resideInAPackage("..internal.."),
                    JavaClass.Predicates.resideInAPackage("..api.."));

    // No class outside a feature may reach into its private sub-packages.
    @ArchTest
    static final ArchRule no_internal_access_across_features =
        noClasses().that().resideOutsideOfPackages(
                "..(*).internal..",
                "..(*).model..",
                "..(*).repository..",
                "..(*).service..")
               .should().dependOnClassesThat().resideInAnyPackage(
                "..internal..",
                "..model..",
                "..repository..",
                "..service..");

    @ArchTest
    static final ArchRule no_field_injection =
        noFields().should().beAnnotatedWith("org.springframework.beans.factory.annotation.Autowired");

    // Forbid by-layer packages at the application root level only.
    @ArchTest
    static final ArchRule no_by_layer_root_packages =
        noClasses().should().resideInAnyPackage(
            "com.example.shop.controller..",
            "com.example.shop.service..",
            "com.example.shop.repository..",
            "com.example.shop.model..",
            "com.example.shop.dto..",
            "com.example.shop.util..");

    // Entities must live in a feature's model or internal sub-package (never at root or in api).
    @ArchTest
    static final ArchRule entities_in_feature_private_package =
        classes().that().areAnnotatedWith("jakarta.persistence.Entity")
                 .should().resideInAnyPackage("..internal..", "..model..");

    @ArchTest
    static final ArchRule no_cycles_between_features =
        slices().matching("com.example.shop.(*)..").should().beFreeOfCycles();
}
```

The `no_internal_access_across_features` and `no_cycles_between_features`
rules together give you "module boundaries" without any extra runtime
dependency: each feature is a top-level package, its private sub-packages
(`internal`, `model`, `repository`, `service`) are inaccessible from other
features, and cycles between features are forbidden.

Run as part of the **architecture gate** (layer 4 of the harness).

## Brownfield ratchet

When a project has pre-existing violations, do **not** weaken the rule. Instead:

1. Run the rule once and capture violators.
2. Add `.allowEmptyShould(true)` is NOT acceptable.
3. Use `freezing` mode:

```java
@ArchTest
static final ArchRule no_field_injection =
    Architectures.layeredArchitecture()...;

// frozen
@ArchTest
static final ArchRule no_field_injection_frozen =
    FreezingArchRule.freeze(no_field_injection);
```

This freezes existing violations into a `archunit_store/` baseline, so new code is held to the rule, but old code is not blocking. New violations fail the build.

## Custom rules to add per project

- **Naming**: services end with `Service`, repositories with `Repository`, controllers with `Controller`.
- **No `java.util.Date` / `java.text.SimpleDateFormat`** — use `java.time`.
- **No `System.out` / `System.err`** in production code.
- **No `@Transactional` on controllers**.
- **No `@Autowired` constructor (it is implicit)**.
- **No Lombok**: `noClasses().should().dependOnClassesThat().resideInAPackage("lombok..")`. On brownfield repos with existing Lombok usage, freeze the rule with `FreezingArchRule.freeze(...)` so new code is held to the ban while legacy code stays green.

## Self-check

- [ ] At least the default ArchUnit rules above are present (including the cycle and internal-access rules that enforce module boundaries).
- [ ] Brownfield violations are frozen, not waived.
- [ ] No `@Disabled` `ArchTest`.
