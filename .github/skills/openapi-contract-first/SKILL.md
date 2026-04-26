---
name: openapi-contract-first
description: Contract-first OpenAPI workflow — author or update the spec, run the diff gate, regenerate types, write the controller. Use when adding or changing an HTTP endpoint.
when_to_use:
  - Phase 3 (Plan) — sketching the OpenAPI delta in `03-design.md`.
  - Phase 4 (Build) — generating types and writing the controller.
  - Phase 6 (Validate) — running `openapi-diff` and reading its report.
authoritative_references:
  - https://springdoc.org/
  - https://github.com/OpenAPITools/openapi-generator
  - https://github.com/OpenAPITools/openapi-diff
---

# OpenAPI contract-first

## Workflow

1. Edit `src/main/resources/openapi/openapi.yaml` (or whatever the project's path is — detect via `detect-stack.sh`).
2. Run the **OpenAPI diff** against the previous version (committed in `_baseline.json`).
3. If breaking, either:
   - Pick a non-breaking alternative (additive field, new endpoint, version the path), OR
   - File an ADR (`adr/NNN-breaking-api-change.md`) and proceed.
4. Generate DTOs (records) via `openapi-generator` Maven plugin.
5. Write the controller; the slice test (`@WebMvcTest`) consumes the generated request/response records.

## Breaking vs non-breaking

Non-breaking (no ADR required):

- Adding a new endpoint.
- Adding an **optional** request field.
- Adding a response field (clients should ignore unknown).
- Loosening a constraint (`min: 1` → `min: 0`).
- Adding a new enum value, **only if** the consumer contract documents that they tolerate unknowns.

Breaking (ADR required):

- Removing or renaming any field.
- Changing a type (`integer` → `string`).
- Tightening a constraint.
- Changing a path or HTTP method.
- Changing an HTTP status for an existing condition.
- Adding a required request field.
- Removing an enum value.

## Springdoc check

If springdoc is on the classpath, also run a **runtime vs static** check: start the app, fetch `/v3/api-docs`, diff against `openapi.yaml`. They must match. The skill's hook for this is `openapi-runtime-vs-static`.

## Generation hint

Configure `openapi-generator` to:

- `generatorName: spring`
- `library: spring-boot`
- `useSpringBoot3: true` (works for Boot 4 too at the time of writing)
- `interfaceOnly: true` (we write the controller; generator only produces interface + DTOs)
- `useTags: true`
- `dateLibrary: java8` (i.e. `java.time`)
- `useJakartaEe: true`
- DTOs as records: `serializationLibrary: jackson`, `additionalModelTypeAnnotations: ""`, and prefer Java records via the `useRecord` flag where supported.

## Worked example

Adding `POST /checkout/{orderId}/gift-card`:

```yaml
paths:
  /checkout/{orderId}/gift-card:
    post:
      operationId: applyGiftCard
      tags: [Checkout]
      parameters:
        - name: orderId
          in: path
          required: true
          schema: { type: string, format: uuid }
      requestBody:
        required: true
        content:
          application/json:
            schema: { $ref: '#/components/schemas/ApplyGiftCardRequest' }
      responses:
        '200':
          description: Applied
          content:
            application/json:
              schema: { $ref: '#/components/schemas/ApplyGiftCardResponse' }
        '404': { $ref: '#/components/responses/NotFound' }
        '409': { $ref: '#/components/responses/Conflict' }
components:
  schemas:
    ApplyGiftCardRequest:
      type: object
      required: [code, orderTotalCents]
      properties:
        code: { type: string, minLength: 1 }
        orderTotalCents: { type: integer, format: int32, minimum: 0 }
```

## Anti-patterns

- Hand-writing DTOs that drift from the spec.
- Using `application/x-www-form-urlencoded` for new APIs.
- `additionalProperties: true` on response schemas (loses type safety on the client).
- Returning 200 for errors with a status field in the body.
- One giant `OpenAPI.yaml` with no tags or grouping.
