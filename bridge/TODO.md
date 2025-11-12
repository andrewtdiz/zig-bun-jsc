# Bridge TODO

Use this file as the short-term backlog for implementation work. Keep each entry scoped so an automation loop can pick it up without additional context.

## Ready
_(none — 2025-11-13)_

## Up Next
_(none — 2025-11-12)_

## Done
- [x] Update `docs/LLM_GUIDE.md` with the streamlined workflow (allowed directories, required commands, coding style). (2025-11-12 — guide now documents the bun shim, allowed paths, and mandatory commands.)
- [x] Audit `docs/bindings-map.md` / `src/bun.js/jsc.zig` to trim bindings the bridge no longer re-exports. (2025-11-12 — jsc exports limited to the five handles consumed by bridge/src/*.)
- [x] Create runtime/hostfn/api scaffolding modules. (2024-??-??)
- [x] Wire `bridge/tests/*.zig` placeholders into the smoke test aggregator.
- [x] Implement `bridge/src/runtime.zig` `shutdown()` by releasing any VM resources allocated during init. (2025-11-12 — added VM handle teardown + state reset)
- [x] Implement `bridge/src/runtime.zig` `globalObject()` to return a handle to the primary `JSGlobalObject`. (2025-11-12 — added handle adoption helpers + structured errors)
- [x] Fill in `bridge/src/hostfn.zig` so `hostfn.expose` registers a native function on the global object. (2025-11-12 — bridged to Bun host_fn scaffold + trampoline dispatch)
- [x] Replace placeholder skips in `bridge/tests/vm_lifecycle.zig` (and related suites) with real assertions. (2024-05-26 — added lifecycle/hostfn/gc/embed loop coverage)
- [x] Simplify root `build.zig` so `zig build` installs the bridge lib and `zig build test` runs the suite. (2024-05-26 — new ~60 line build script.)
- [x] Flesh out `bridge/src/api.zig` `evalUtf8` to compile/evaluate scripts via a delegate and return the resulting `JSValue`. (2024-05-26 — added eval handler plumbing + tests.)
- [x] Refresh `bridge/README.md` so it reflects the current module/test layout and documents how to install a real `EvalHandler`. (2025-11-13 — added module tree, EvalHandler wiring guide, and updated next steps.)
