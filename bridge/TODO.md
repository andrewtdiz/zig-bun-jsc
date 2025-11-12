# Bridge TODO

Use this file as the short-term backlog for implementation work. Keep each entry scoped so an automation loop can pick it up without additional context.

## Ready
- [ ] Implement `bridge/src/runtime.zig` `shutdown()` by releasing any VM resources allocated during init.
- [ ] Implement `bridge/src/runtime.zig` `globalObject()` to return a handle to the primary `JSGlobalObject`.
- [ ] Fill in `bridge/src/hostfn.zig` so `hostfn.expose` registers a native function on the global object.
- [ ] Flesh out `bridge/src/api.zig` `evalUtf8` to compile + execute scripts and return the resulting `JSValue`.
- [ ] Replace placeholder skips in `bridge/tests/vm_lifecycle.zig` with real assertions once runtime wiring is available.

## Up Next
- [ ] Simplify root `build.zig` so `zig build test` builds the bridge lib and runs all tests.
- [ ] Write `bridge/tests/hostfn_roundtrip.zig` to cover registering a Zig callback and invoking it from JS.

## Done
- [x] Create runtime/hostfn/api scaffolding modules. (2024-??-??)
- [x] Wire `bridge/tests/*.zig` placeholders into the smoke test aggregator.
