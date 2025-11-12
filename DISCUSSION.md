# Bridge Design Notes

This document tracks the ongoing conversation about turning the legacy Bun checkout into a purpose-built Zig ↔ JavaScriptCore bridge. Feel free to append new sections (with dates) as design decisions evolve.

## Q1 · What is the true minimum we need from the old code base?

- **JavaScriptCore initialization:** threading setup, VM creation, and a custom `JSGlobalObject`. Today this logic lives in `src/bun.js/bindings/bindings.cpp` + `src/bun.js/jsc.zig`.
- **Core Zig wrappers:** `JSValue`, `JSObject`, `JSString`, `CallFrame`, `VM`, and the helpers that convert between Zig data structures and JSC types.
- **ABI boundary:** the `headers.h`/`bindings.cpp` pair that exposes C-style functions Zig can call. We do not need the bundler, CLI, Node shims, HTTP, SQL, or shell subsystems.
- Everything else should either move under `bridge/` or be deleted.

## Q2 · Which areas can be removed with zero impact on the bridge?

- Package manager (`src/install/`), bundler (`src/bundler/`), CLI + shell, CSS/HTML parsers, HTTP/SQL clients, Bake, Node compatibility layers, and the JavaScript test runner were all removed.
- The remaining `src/bun.js/bindings/` files still mention DOM, WebCrypto, inspectors, etc. We keep them only until we can prove the bridge never touches those entry points; then we delete them as well.
- Build system scaffolding (CMake, scripts, `bunfig`, etc.) was erased in favor of the much smaller `bridge/build.zig`.

## Q3 · How do we validate functionality without Bun’s test runner?

- Use plain `zig test` targets under `bridge/tests/`. These tests can exercise host function exposure, evaluation helpers, and data marshaling without booting a full runtime.
- Add focused integration tests once we wire a real VM: create objects in Zig, mutate them in JS, ensure GC/weak references behave, and verify error propagation.
- No snapshots, no Node emulation—just deterministic assertions that the bridge performs the expected conversions and lifecycle transitions.

## Q4 · How does this repo relate to Bun now?

- It started as a fork, but the runtime/product functionality has been deliberately removed. The only reason `src/bun.js/*` paths remain is because the low-level bindings still include those files.
- When we mention "legacy Bun" in other documents it strictly refers to the code we are trimming; this repo is **not** a drop-in replacement for Bun.
- We will continue renaming/moving files once the Zig ↔ JSC API is stable enough that downstream embedders can depend on it without pulling in unrelated modules.

## 2025-11-12 · CLI entrypoint cleanup

- Removed `src/main.zig`, `src/main_test.zig`, and `src/main_wasm.zig` per verifier feedback so the repository no longer advertises the legacy Bun CLI/test/wasm binaries. The bridge now builds solely via `bridge/src/lib.zig`.
- Tooling gap: the sandbox image currently lacks the `zig` executable, so we cannot run `zig fmt` or `zig build test` locally; rerun those commands once Zig is provisioned.

## 2025-11-14 · Binding surface rewrite

- Deleted the legacy `src/bun.js/bindings/` tree and reimplemented the five bridge-owned bindings (JSValue, CallFrame, JSGlobalObject, VM, ZigString) with lightweight stubs so they only depend on the mini `bun` module. The new code short-circuits when `builtin.is_test` so we can keep running Zig-only tests without linking JavaScriptCore.
- These stubs intentionally limit functionality (e.g. `ZigString.fromBytes` only handles UTF-8 and `JSValue.jsNumberFromInt32` fabricates deterministic handles). Once we have a real JSC build we must replace the `builtin.is_test` branches with calls into the true C++ helpers to regain ABI compatibility.
