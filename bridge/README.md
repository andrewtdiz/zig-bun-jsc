# Bridge Harness

This directory is a self‑contained playground for the stripped down Zig ↔ JavaScriptCore bridge described in `BRIDGE_PLAN.md`. The goal is to keep all incremental work (docs, prototypes, fixtures, tests) in one place, so we can iterate without dragging the legacy Bun runtime back in.

```
bridge/
├── README.md
├── src/
│   ├── api.zig        ← public API (init/shutdown/eval/hostfn)
│   ├── bun.zig        ← minimal shim that imports `src/bun.js/jsc.zig`
│   ├── hostfn.zig     ← host-function registry + trampoline helpers
│   ├── lib.zig        ← re-exports the bridge modules for tests
│   └── runtime.zig    ← lifecycle, handle adoption, eval handler plumbing
└── tests/
    ├── embed_loop.zig
    ├── gc_weakrefs.zig
    ├── hostfn_roundtrip.zig
    ├── smoke.zig      ← imports the rest of the suite
    ├── testlib.zig    ← helpers (fake handles, eval stub, call frames)
    └── vm_lifecycle.zig
```

## Usage

1. Build + test the entire harness (this runs every file imported by `tests/smoke.zig`):
   ```bash
   zig build test
   ```
   The root `build.zig` wires up the bridge module (which re-exports the trimmed `src/bun.js/jsc.zig`) and fans out to every test under `bridge/tests/`.

2. Add bridge code in `bridge/src/` (e.g. VM bootstrap, host function dispatch, data-marshal helpers) and expand the test matrix next to the existing files so they can import the shared helpers from `bridge/tests/testlib.zig`.

3. Mirror the plan from `BRIDGE_PLAN.md` when adding new tests:
   - `tests/zvm_*.zig`: VM lifecycle, GC, microtasks.
   - `tests/hostfn_*.zig`: Zig host functions callable from JS.
   - `tests/eval_*.zig`: Eval/Script execution helpers.
   - `tests/embed_*.zig`: Game-engine style entry points.

Each test file can `@import("../src/lib.zig")` to reach the shared bridge helpers without depending on whatever remains in `src/`.

## Installing a Real Eval Handler

The automation environment cannot link JavaScriptCore, so tests install a stub through `api.configureEval` (see `bridge/tests/testlib.zig`). When you have a native JSC build, wire it up as follows:

1. Create or obtain a `JSC.VM`/`JSC.JSGlobalObject` pair (either by calling the Bun C++ helpers or by embedding WebKit yourself).
2. Call `api.init(.{ .handles = .{ .vm = vm, .global = global, .owns_vm = false } })` so the bridge records those pointers without taking ownership.
3. Provide a concrete evaluator:
   ```zig
   const bridge = @import("bridge");
   const runtime = bridge.runtime;
   const api = bridge.api;

   const EvalContext = struct {
       vm: *runtime.JSC.VM,
   };

   fn realEval(context: ?*anyopaque, global: *runtime.JSC.JSGlobalObject, script: []const u8, options: api.EvalOptions) runtime.Error!runtime.JSC.JSValue {
       const ctx: *EvalContext = @ptrCast(@alignCast(context.?));
       _ = ctx.vm; // handy for custom bookkeeping
        // TODO: call into the actual JSC evaluate/evaluateScript helper once the binary is available.
        // e.g. return runtime.JSC.VirtualMachine.evaluate(global, script.ptr, script.len, options.filename);
        return runtime.Error.EngineUnavailable;
   }

   pub fn installEval(vm: *runtime.JSC.VM, global: *runtime.JSC.JSGlobalObject) void {
       api.configureEval(realEval, &EvalContext{ .vm = vm });
   }
   ```
4. Once the handler is installed you can call `api.evalUtf8("globalThis.tick && globalThis.tick()")` from Zig, and the callback will dispatch into JavaScriptCore through your binding.

Remember to call `api.shutdown()` (or `runtime.resetForTesting()`) when you are done so host functions and VM handles are released even if the Zig process keeps running.

## Next Steps

1. Replace the placeholder evaluator shown above with a concrete call into WebKit’s `JSLockHolder`/`evaluate` helpers once prebuilt libraries are available.
2. Introduce fixtures (small `.js` files) under `bridge/fixtures/` as soon as the evaluator can actually execute JavaScript.
3. Continue trimming unused bindings under `src/bun.js/bindings/` so the bridge exports only the types it needs.

## Bridge Modules

`bridge/src/` is the public Zig surface embedders consume. Each module stays small on purpose:

- `bun.zig` — miniature replacement for the legacy Bun root module that exposes `default_allocator`, logging stubs, and re-exports `src/bun.js/jsc.zig`.
- `lib.zig` — convenience wrapper that re-exports `runtime`, `hostfn`, `api`, and the trimmed JSC handles so tests can `@import("bridge")`.
- `runtime.zig`
  - `Config` accepts optional `handles` (so you can adopt an externally-created VM/global pair) plus future toggles such as `eval_mode`.
  - `init`/`shutdown` are idempotent and manage ownership via the `owns_vm` flag before delegating to `JSC.initialize`/`JSC.VM.deinit`.
  - `installEvalHandler`, `evalUtf8`, and `handles()` expose the evaluator bridge and give tests a safe way to inspect state without touching legacy Bun code.
- `hostfn.zig`
  - `Registration` tracks the exported name, callback pointer, optional context, and `Function.length`.
  - `expose` allocates Zig metadata, creates a `JSFunction` via `JSC.host_fn.*`, and assigns it on the global object (tests skip the actual JSC call paths).
  - `callFromJS` and the internal `hostTrampoline` drive Zig callbacks when JavaScript invokes the function, reporting structured errors via `runtime.Error`.
  - `reset` releases every stored registration so `api.shutdown` always unwinds cleanly.
- `api.zig`
  - `init`/`shutdown` wrap the runtime layer and automatically reset the host-function registry.
  - `evalUtf8`, `configureEval`, and `exposeHostFunction` form the minimal public API embedders need for script execution and host callbacks; no other Bun subsystems leak through.
