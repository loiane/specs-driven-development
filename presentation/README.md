# Presentation

This folder contains the presentation material for the specs-driven-development repository.

## Files

- `sdd-repo-talk.md`: Marp-compatible Markdown version.
- `reveal/index.html`: Reveal.js entrypoint.
- `reveal/slides.md`: Reveal.js slide content.
- `reveal/theme.css`: small custom theme overrides.

## Recommended workflow

1. Edit content in `reveal/slides.md` for Reveal.js presentations.
2. Open `reveal/index.html` in a local web server.
3. Use `sdd-repo-talk.md` only if you want Marp export to PDF/PPTX.

## Run Reveal.js locally

From repo root:

```bash
python3 -m http.server 8000
```

Then open:

- `http://localhost:8000/presentation/reveal/index.html`

Tip: use arrow keys to navigate slides.

## Suggested talk duration

- 20-25 minutes total
- 8-10 minutes demo
- 3-5 minutes Q&A

## Content sources in this repo

- `docs/methodology.md`
- `docs/harness-principles.md`
- `docs/artifact-contract.md`
- `docs/spec-format.md`
- `README.md`
