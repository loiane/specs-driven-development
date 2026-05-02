# Spec-Driven Development in Practice

From AI-assisted coding to verifiable software delivery.

<div class="hero-meta">
  <span class="pill">Repository: specs-driven-development</span>
  <span class="pill">Audience: engineering teams and tech leads</span>
</div>

Note:
This talk is not about AI replacing engineering discipline. It is about using structured specs, explicit phase gates, and deterministic validation so teams can move faster without losing control.

---

<div class="section-label">Talk Contents</div>

## Interactive Agenda

Click-or-scan overview of the talk structure.

<div class="agenda-grid">
  <a class="agenda-card" href="#/2">
    <div class="agenda-num">01</div>
    <h3>What Is SDD?</h3>
    <p>The core idea and why it matters.</p>
  </a>
  <a class="agenda-card" href="#/4">
    <div class="agenda-num">02</div>
    <h3>Workflow</h3>
    <p>The seven phases and their handoffs.</p>
  </a>
  <a class="agenda-card" href="#/6">
    <div class="agenda-num">03</div>
    <h3>Context<br />Architecture</h3>
    <p>How rules, skills, prompts, and artifacts work together.</p>
  </a>
  <a class="agenda-card" href="#/8">
    <div class="agenda-num">04</div>
    <h3>Harness<br />Engineering</h3>
    <p>Why the harness is the real trust layer.</p>
  </a>
  <a class="agenda-card" href="#/11">
    <div class="agenda-num">05</div>
    <h3>When To Use It</h3>
    <p>Where this flow creates leverage.</p>
  </a>
  <a class="agenda-card" href="#/13">
    <div class="agenda-num">06</div>
    <h3>When Not<br />To Use It</h3>
    <p>Cases where lighter process is better.</p>
  </a>
  <a class="agenda-card" href="#/15">
    <div class="agenda-num">07</div>
    <h3>Demo Path</h3>
    <p>What to show in a live walkthrough.</p>
  </a>
  <a class="agenda-card" href="#/16">
    <div class="agenda-num">08</div>
    <h3>Adoption</h3>
    <p>How to pilot this with one feature.</p>
  </a>
</div>

---

<div class="section-label">01 / Fundamentals</div>

## What Is SDD?

Spec-Driven Development is a delivery model where AI-assisted work is guided by:

- Approved requirements before implementation
- Explicit artifacts for every phase
- Specialized agents with narrow responsibilities
- Deterministic gates before code can move forward

<div class="callout">
  SDD is not “better prompting.” It is a lightweight operating system for shipping software with evidence.
</div>

Note:
Emphasize that the repo treats specs, design, tasks, validation, and review as first-class engineering assets, not optional documents.

---

## Why This Exists

Teams using AI tools often hit the same failure modes:

- The agent invents missing requirements
- Chat context drifts across sessions
- Tests and validation become uneven
- Code review happens too late or too loosely

<div class="two-col">
  <div>
    <h3>Without SDD</h3>
    <ul>
      <li>Fast output</li>
      <li>Low predictability</li>
      <li>Weak traceability</li>
    </ul>
  </div>
  <div>
    <h3>With SDD</h3>
    <ul>
      <li>Fast enough output</li>
      <li>Higher confidence</li>
      <li>Reviewable evidence trail</li>
    </ul>
  </div>
</div>

---

<div class="section-label">02 / Workflow</div>

## The Seven-Phase Flow

1. Specify
2. Review specs
3. Plan design and tasks
4. Implement with TDD
5. Broaden and harden tests
6. Validate with the harness
7. Run structured code review

<div class="callout compact">
  Key idea: every phase has an owner, an artifact, an entry contract, an exit contract, and a gate.
</div>

<div class="slide-ref">Reference: <code>docs/methodology.md</code></div>

---

## Artifacts Are the Delivery Spine

Concrete artifacts under `.specs/<feature-id>/` connect the workflow end to end.

<div class="artifact-grid">
  <div class="artifact-card"><code>01-spec.md</code><span>Intent and ACs</span></div>
  <div class="artifact-card"><code>02-spec-review.md</code><span>Review verdict</span></div>
  <div class="artifact-card"><code>03-design.md</code><span>Technical design</span></div>
  <div class="artifact-card"><code>04-tasks.md</code><span>TDD-shaped tasks</span></div>
  <div class="artifact-card"><code>07-validation-report.md</code><span>Gate results</span></div>
  <div class="artifact-card"><code>08-code-review.md</code><span>Pre-commit verdict</span></div>
</div>

<div class="slide-ref">Reference: <code>docs/artifact-contract.md</code></div>

---

<div class="section-label">03 / Context Architecture</div>

## Context Architecture

This repo does not treat all context as one giant prompt.

Instead, it separates context into layers:

- Global rules and always-on instructions
- File-scoped instructions
- Specialized skills for narrow tasks
- Phase-specific agents and prompts
- Repo artifacts created during the workflow

<div class="callout">
  The design goal is context economy: load only what is needed, when it is needed.
</div>

---

## Why Context Architecture Matters

A structured context architecture improves:

- Precision: less irrelevant context, fewer invented defaults
- Portability: same method across Copilot, Claude, and Windsurf
- Maintainability: behavior lives in files, not only in human memory
- Governance: risky actions are constrained by explicit rules

<div class="two-col">
  <div>
    <h3>Repo as source of truth</h3>
    <p>Method, guardrails, and role behavior live in the repository.</p>
  </div>
  <div>
    <h3>Artifacts as memory</h3>
    <p>Specs and validation outputs preserve intent across sessions.</p>
  </div>
</div>

---

<div class="section-label">04 / Harness Engineering</div>

## Harness Engineering

The harness is the difference between confident narration and actual evidence.

It gives the workflow a deterministic way to answer:

- Does the code build?
- Did behavior regress?
- Did architecture drift?
- Is the change traceable to requirements?

<div class="callout compact">
  Principle: the agent validates its own work before claiming success.
</div>

<div class="slide-ref">Reference: <code>docs/harness-principles.md</code></div>

---

## The 10 Validation Layers

1. Format and lint
2. Compile
3. Static analysis
4. Architecture rules
5. Unit and slice tests
6. Integration tests
7. Coverage
8. Mutation testing
9. Contract validation
10. Security scanning

<div class="callout">
  This is why the workflow is trustworthy: not because the agent sounds smart, but because the repo demands proof.
</div>

---

## Traceability Is Part of the Harness

The workflow links:

- Acceptance criteria
- Tasks
- Tests
- Code symbols
- Gate outcomes

That means reviewers can ask:

- Which requirement does this change satisfy?
- Which tests prove it?
- Which gate verified it?

---

<div class="section-label">05 / Fit</div>

## When To Use This Flow

Use this workflow when you need both speed and reliability.

Best-fit cases:

- Medium to high-risk product features
- API changes with compatibility concerns
- Multi-step work where decisions must be reviewable
- Teams adopting AI coding but needing stronger governance
- Brownfield systems where regressions are expensive

<div class="callout compact">
  The more ambiguity, coordination, or risk a change has, the more SDD helps.
</div>

---

## Strong Use Cases

<div class="two-col">
  <div>
    <h3>Great fit</h3>
    <ul>
      <li>Backend features with business rules</li>
      <li>Schema or API evolution</li>
      <li>Features needing auditability</li>
      <li>Cross-team collaboration</li>
    </ul>
  </div>
  <div>
    <h3>Why</h3>
    <ul>
      <li>Open questions are surfaced early</li>
      <li>Tasks become small and testable</li>
      <li>Validation catches drift before commit</li>
      <li>Review is evidence-based</li>
    </ul>
  </div>
</div>

---

<div class="section-label">06 / Boundaries</div>

## When Not To Use This Flow

Do not force the full workflow on every tiny change.

Poor-fit cases:

- One-line typo fixes
- Small docs-only edits
- Throwaway prototypes with no production path
- Local exploratory spikes
- Emergency triage where immediate containment matters first

<div class="callout warning">
  SDD is a delivery system, not a religion. Use the amount of process the risk deserves.
</div>

---

## Use a Lighter Path Instead

If the change is tiny and low risk, prefer:

- Direct edit
- Targeted test or validation
- Short review loop
- No heavy artifact overhead

Rule of thumb:

- Small change, low risk -> lighter path
- Ambiguous change, durable impact, shared ownership -> SDD path

---

<div class="section-label">07 / Demo</div>

## Demo Path

A strong demo shows control, not speed theater.

1. Start from a feature request
2. Draft `01-spec.md` and expose open questions
3. Show `04-tasks.md` with files in scope
4. Walk one TDD task red to green
5. Show validation and review artifacts
6. Stop at the human approval boundary

Note:
The ending matters. Do not blur the line between agent autonomy and human approval. That boundary is part of the story.

---

<div class="section-label">08 / Adoption</div>

## How To Pilot It

Start with one real feature, not a slideware exercise.

1. Choose a medium-complexity ticket
2. Run the full flow end to end
3. Measure cycle time, review quality, and escaped issues
4. Retrospective after the pilot
5. Keep what improved signal, trim what added friction

<div class="callout">
  Goal: prove that structure increases delivery confidence without killing momentum.
</div>

---

## Final Recommendation

Start here:

- One feature
- One champion
- Full artifact chain
- Full harness run
- Explicit review verdict

If the pilot reduces rework and increases confidence, scale the method to more feature work.

<div class="hero-meta">
  <span class="pill">Predictability over vibes</span>
  <span class="pill">Evidence before commit</span>
</div>
