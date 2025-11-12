# Automation Guide

Use this checklist every time you spin up an automation run. The repo is now a pure Zig ↔ JavaScriptCore bridge; anything that smells like the old Bun runtime is suspect.

## Mission
- Keep the public API limited to `bridge/src/{runtime,hostfn,api}.zig`.
- Ensure JavaScriptCore is never executed on this machine – rely on the scaffolding under `src/bun.js/`.
- Remove Bun-era subsystems instead of reanimating them (CLI, bundler, Node shims, HTTP stack, etc.).

## Workspace Boundaries
- ✅ `bridge/src/` – runtime modules, the new `bun` shim (`bridge/src/bun.zig`), and future helpers.
- ✅ `bridge/tests/` – add/modify tests; keep them self-contained.
- ✅ `docs/`, `BRIDGE_PLAN.md`, `bridge/TODO.md` – keep the plan/todo/bindings docs current.
- ✅ `src/bun.js/jsc.zig` + `src/bun.js/bindings/` – only to prune exports or document the remaining bindings.
- ✅ `build.zig` – maintain the lean build that links only the bridge library.
- 🚫 Everything else in `src/` is legacy Bun runtime code. Do not edit it unless you are **deleting** it.

## Implementation Notes
- The bridge imports a minimal shim at `bridge/src/bun.zig`. Never point the build at `src/bun.zig` again; that would resurrect the entire Bun runtime.
- When touching bindings, update **both** `src/bun.js/jsc.zig` and `docs/bindings-map.md` in the same change so the surface stays auditable.
- Every task that lands must flip the relevant checkbox in `BRIDGE_PLAN.md` and/or `bridge/TODO.md` with a short parenthetical note (file + date).

## Prohibited Actions
- No new external dependencies, npm projects, or TypeScript toolchains.
- No attempts to execute real JavaScriptCore binaries here.
- No git history rewrites or `git reset --hard`.

Following these guardrails keeps each automation iteration predictable and reviewable while we wait for an actual JSC build.
