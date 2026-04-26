---
name: spring-security-baseline
description: Minimum Spring Security 7 configuration patterns and review baseline. Use when designing or reviewing authentication, authorization, CSRF, CORS, secrets handling, or input validation.
when_to_use:
  - Phase 3 (Plan) — designing auth/authz for an endpoint.
  - Phase 7 (Code review) — security rubric of `08-code-review.md`.
authoritative_references:
  - https://docs.spring.io/spring-security/reference/index.html
  - https://owasp.org/Top10/
---

# Spring Security baseline

## What every endpoint must declare

In `03-design.md`, for each new/changed endpoint:

- **AuthN**: Anonymous? Bearer (JWT)? Session? mTLS?
- **AuthZ**: What role/scope/claim is required?
- **Input validation**: Bean Validation on the DTO (`@NotNull`, `@Size`, `@Pattern`, …) PLUS service-layer invariants.
- **Output**: Does the response include any field the caller is not allowed to see?
- **Audit**: Should this action be logged with structured fields (`actor`, `subject`, `outcome`)?

If any of these is unclear, write a `Q-NNN` — do not pick a default.

## Default `SecurityFilterChain` (resource server, JWT)

```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
class SecurityConfig {

    @Bean
    SecurityFilterChain api(HttpSecurity http) throws Exception {
        http
            .securityMatcher("/api/**")
            .authorizeHttpRequests(a -> a
                .requestMatchers("/api/public/**").permitAll()
                .anyRequest().authenticated())
            .oauth2ResourceServer(o -> o.jwt(Customizer.withDefaults()))
            .csrf(csrf -> csrf.disable())                // stateless API
            .sessionManagement(s -> s.sessionCreationPolicy(STATELESS))
            .headers(h -> h
                .contentSecurityPolicy(c -> c.policyDirectives("default-src 'none'"))
                .referrerPolicy(r -> r.policy(STRICT_ORIGIN_WHEN_CROSS_ORIGIN)));
        return http.build();
    }
}
```

CSRF is **disabled only for stateless APIs**. If sessions are used, CSRF is on.

## Method-level authorization

Prefer `@PreAuthorize` with SpEL using JWT claims:

```java
@PreAuthorize("hasAuthority('SCOPE_orders:write') and #orderId == authentication.token.claims['order_id']")
public Order apply(@PathVariable UUID orderId, @Valid @RequestBody ApplyGiftCardRequest req) { ... }
```

## Secrets

- **Never** commit secrets. Use environment variables or a secrets manager.
- `application.yml` references `${VAR}`; absence fails fast at startup.
- Tests use Testcontainers; secrets there are throwaway.

## Input validation

Two layers:

1. **Boundary** — Bean Validation on DTO + `@Valid` on controller method.
2. **Service** — re-check invariants that depend on the entity state (e.g. "card not yet redeemed" is a service-layer check, not a DTO check).

Never trust client-supplied IDs. Always re-resolve to a domain object scoped by the caller.

## Logging & observability

- Log security events at `INFO` with structured key/values: `actor=<sub>`, `action=apply_gift_card`, `outcome=denied`, `reason=card_redeemed`.
- Never log PII, secrets, full JWT, full card number. Mask: `code=ABC***`.

## Review rubric (used by code-reviewer)

- [ ] No endpoint without an explicit `requestMatchers` decision (default-deny).
- [ ] No `permitAll()` on a state-changing endpoint.
- [ ] No `@PreAuthorize` SpEL referencing user-supplied data unchecked.
- [ ] No `@CrossOrigin("*")` in production code.
- [ ] No raw SQL with string concatenation.
- [ ] No reflective bean access on user input.
- [ ] No `@JsonProperty` exposing internal entity fields.
- [ ] CSRF state matches whether the API is stateful.
- [ ] Sensitive data is masked in logs.
- [ ] OWASP Dependency Check has no new High/Critical CVEs (or one waiver per CVE in `dependency-check-suppressions.xml`).
