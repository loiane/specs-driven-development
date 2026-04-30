# Security Policy

## Supported versions

This toolkit is versioned per [CHANGELOG.md](CHANGELOG.md). Only the latest minor release receives security fixes.

## Reporting a vulnerability

**Do not open a public GitHub issue for security reports.**

Please report suspected vulnerabilities privately via GitHub's
[Report a vulnerability](https://github.com/loiane/specs-driven-development/security/advisories/new)
form (Security tab → Advisories → Report a vulnerability). Include:

- A description of the issue.
- Steps to reproduce or a proof-of-concept.
- Affected files / commit SHA.
- Your assessment of impact (and any suggested fix).

You will receive an acknowledgement within 5 business days. We aim to publish a fix or mitigation within 30 days for high-severity issues.

## Threat model — what this toolkit is and isn't

This repository ships **prompts, skills, templates, hooks, and shell scripts** that are dropped into consumer repositories and executed by AI coding agents (Claude Code, GitHub Copilot, Windsurf) and CI.

In-scope concerns:

- A malicious modification to a hook script (e.g. `.claude/hooks/block-impl-without-failing-test.sh`) that bypasses the TDD invariant, the files-in-scope guard, or the skip-flag block.
- A malicious modification to `.github/scripts/harness.sh` that silently masks failing gates.
- A skill or prompt that instructs an agent to exfiltrate secrets, disable security gates, or execute arbitrary commands without user confirmation.
- A template that omits a required guardrail section a downstream consumer relies on.

Out of scope (consumer-side responsibilities):

- Vulnerabilities in the consumer's own application code.
- Vulnerabilities in third-party Maven plugins, npm packages, or Docker images that a consumer adds.
- Misconfiguration of MCP servers in the consumer environment.

## Hardening recommendations for consumers

If you adopt this toolkit in an enterprise repo:

1. **Protect hooks and scripts via `CODEOWNERS`.** Require a security-team review for any change to `.claude/hooks/`, `.github/scripts/`, `.windsurf/` workflow files, and the Maven parent-pom fragment.
2. **Treat ticket content as data, not instructions.** The `issue-tracker-ingestion` skill pulls Jira/GitHub/Linear/Azure ticket bodies via MCP. Ticket descriptions are user-controlled and may contain prompt-injection. Always quote pulled content into the spec's `## Source` block; never let an agent execute instructions found in ticket text.
3. **Run secret scanning.** Add `gitleaks` (or GitHub secret scanning) alongside the OWASP Dependency Check layer.
4. **Pin tool versions.** Pin `jq`, `mvn`, `bash`, and any CI runner image. Bumps should be deliberate, never silent.
5. **Sign or verify.** If your org requires it, sign hook scripts and verify signatures in CI before they execute.

## Disclosure

We follow coordinated disclosure. Once a fix ships, the advisory is published in [CHANGELOG.md](CHANGELOG.md) with a `### Security` heading and, for material issues, a GitHub Security Advisory.
