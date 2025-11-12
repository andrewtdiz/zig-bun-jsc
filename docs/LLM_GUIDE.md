# Automation Guide

This repository is now tailored for iterative work by a large language model. Follow these rules every time you run an autonomous loop:

## Primary Goal
Deliver a minimal Zig ↔ JavaScriptCore bridge. Do **not** reintroduce Bun subsystems (bundler, CLI, HTTP, package manager, Node polyfills, etc.).

## Allowed Touchpoints
- `bridge/src/` – modern bridge modules (runtime, hostfn, api, future helpers).
- `bridge/tests/` – Zig test suites; add new files here as you implement scenarios.
- `docs/` – design notes and task backlogs.
- `src/bun.js/jsc.zig` + `src/bun.js/bindings/` – only when pruning or exposing necessary bindings. Avoid modifying other legacy files.
- `build.zig` – simplify/replace with the lean bridge build.

## Commands To Run
1. `zig fmt bridge/src/*.zig bridge/tests/*.zig` after code edits.
2. `zig build test` (once the simplified root build exists). Until then run `cd bridge && zig build smoke`.
3. `git status -sb` and include the output summary in your report.

> **Important:** Do **not** attempt to compile or execute the real JavaScriptCore runtime in this environment; the libraries are not available. Use the existing Zig scaffolding to ensure APIs compile and tests pass up to the point where JSC would be invoked. Focus on removing legacy Bun dependencies and tightening the bridge interfaces.

## Style / Structure
- Prefer small modules over monolithic files.
- Keep placeholders explicit: use `return error.SkipZigTest;` in tests and `@compileError`/`Error.NotImplemented` in code.
- Update `BRIDGE_PLAN.md` checkboxes whenever you finish a task. Mention the exact files touched.
- Document non-obvious behavior in `docs/` or inline comments (short and targeted).

## Forbidden Actions
- Do not restore deleted directories (`src/bundler`, `src/install`, etc.).
- Do not add npm/Node dependencies or TypeScript tooling.
- Avoid editing Git history or touching `.git` metadata.

Stick to these guidelines and each nightly run will make deterministic progress that is easy to review.
