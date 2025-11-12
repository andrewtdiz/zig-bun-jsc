# Bridge Harness

This directory is a self‑contained playground for the stripped down Zig ↔ JavaScriptCore bridge described in `BRIDGE_PLAN.md`. The goal is to keep all incremental work (docs, prototypes, fixtures, tests) in one place, so we can iterate without dragging the legacy Bun runtime back in.

```
bridge/
├── README.md          ← you are here
├── src/
│   └── lib.zig        ← thin wrapper that re-exports `src/bun.js/jsc.zig`
└── tests/
    └── smoke.zig      ← first scaffolding test (structure only)
```

## Usage

1. Run the smoke test (verifies the harness integrates with Zig):
   ```bash
   cd bridge
   zig build smoke
   ```
   The dedicated `bridge/build.zig` wires up the `bridge` module (which re-exports `src/bun.js/jsc.zig`) and injects the legacy `src/bun.zig` dependency. The test intentionally avoids touching the real JavaScriptCore symbols, so it works even before we finish wiring the C++ linkage.

2. Add bridge code in `bridge/src/` (e.g. VM bootstrap, host function dispatch, data-marshal helpers).

3. Mirror the plan from `BRIDGE_PLAN.md` when adding new tests:
   - `tests/zvm_*.zig`: VM lifecycle, GC, microtasks.
   - `tests/hostfn_*.zig`: Zig host functions callable from JS.
   - `tests/eval_*.zig`: Eval/Script execution helpers.
   - `tests/embed_*.zig`: Game-engine style entry points.

Each test file can `@import("../src/lib.zig")` to reach the shared bridge helpers without depending on whatever remains in `src/`.

## Next Steps

- Flesh out `bridge/src/lib.zig` to construct a VM, expose host functions, and evaluate JS.
- Introduce fixtures (e.g. tiny JS scripts) under `bridge/fixtures/` once we hook up the evaluation pipeline.
- When we’re ready to link against JavaScriptCore, extend the root `build.zig` (or add a mini `bridge/build.zig`) with a `bridge-test` step that runs every file under `bridge/tests/`.
