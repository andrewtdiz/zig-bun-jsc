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
   zig build test
   ```
   The root `build.zig` wires up the `bridge` module (which re-exports `src/bun.js/jsc.zig`) and fans out to every file under `bridge/tests/`.

2. Add bridge code in `bridge/src/` (e.g. VM bootstrap, host function dispatch, data-marshal helpers).

3. Mirror the plan from `BRIDGE_PLAN.md` when adding new tests:
   - `tests/zvm_*.zig`: VM lifecycle, GC, microtasks.
   - `tests/hostfn_*.zig`: Zig host functions callable from JS.
   - `tests/eval_*.zig`: Eval/Script execution helpers.
   - `tests/embed_*.zig`: Game-engine style entry points.

Each test file can `@import("../src/lib.zig")` to reach the shared bridge helpers without depending on whatever remains in `src/`.

## Next Steps

- Provide a production `EvalHandler` that calls into a real JavaScriptCore build (see `api.configureEval`).
- Introduce fixtures (e.g. tiny JS scripts) under `bridge/fixtures/` once we hook up the evaluation pipeline.
- Continue trimming unused bindings under `src/bun.js/bindings/` so the bridge exports only the types it needs.

## Bridge Modules

The `bridge/src/` directory hosts the public Zig surface for embedders. The modules deliberately mirror the flow described in `BRIDGE_PLAN.md`:

- `runtime.zig`
  - `Config` now accepts an optional `handles` payload so an embedder that already owns a `JSC::VM`/`JSGlobalObject` can pass those pointers directly into `runtime.init`.
  - `init` is idempotent and records the configuration even when we short‑circuit under `zig test`.
  - `adoptHandles` can be called later if the VM is created asynchronously; `globalObject()` returns either a usable pointer or a structured error (`error.NotInitialized` or `error.MissingGlobalObject`).
  - `shutdown`/`resetForTesting` tear down the handle bookkeeping while respecting ownership (we only `JSC.VM.deinit` when the bridge created the VM).

- `hostfn.zig`
  - `Registration` describes a host callback (`name`, `callback`, optional `context`, and the exposed `length`/`Function.length`).
  - `expose` creates a real `JSC::JSFunction` via Bun’s host-function scaffold, stores the metadata in Zig (so we can cleanly reset), and assigns the function on the global object.
  - `callFromJS` powers the trampoline invoked by JavaScriptCore. It looks up the `StoredRegistration` via `JSC.host_fn.getFunctionData` and invokes the Zig callback with the optional context pointer.
  - `reset` frees any registrations that were installed so `api.shutdown` can leave the process in a clean state even without JSC linked.

- `api.zig`
  - `init`/`shutdown` forward to the runtime layer and ensure host-function state is cleared on shutdown.
  - `evalUtf8` enforces initialization/global-object checks and then dispatches to an `EvalHandler`. Tests install a stub handler; embedders should call `api.configureEval` to provide a real JavaScriptCore-backed implementation once the engine is available.
  - `exposeHostFunction` forwards to the new `hostfn.expose`, so embedders only need to import the `api` module for basic lifecycle + host-function plumbing.
