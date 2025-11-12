
# Zig ↔ JavaScriptCore Bridge

This repository now focuses on a single goal: provide a compact, auditable layer that connects Zig code to WebKit’s JavaScriptCore (JSC). The code base started life as Bun, but the runtime, CLI, package manager, bundler, Node compatibility layer, and web APIs have been removed so we can ship a lightweight embedding surface that fits inside other applications (such as a game engine).

## What’s Here

| Path | Purpose |
| ---- | ------- |
| `src/bun.js/jsc.zig` | The trimmed Zig bindings that wrap JSC types (JSValue, JSObject, JSGlobalObject, VM, etc.). |
| `src/bun.js/bindings/` | The matching C++/Zig glue that bridges to the JavaScriptCore headers. This directory is still large because it houses the low-level ABI surface. |
| `bridge/` | A self-contained Zig test harness for iterating on the bridge without any of the old Bun tooling. |

Anything unrelated to Zig↔JSC data flow (bundler, install tools, HTTP, CSS, Node polyfills, etc.) has been deleted. When you see references to “legacy Bun” in comments they exist only for historical context.

## Getting Started

Requirements:

- Zig `0.16.0-dev.732` (or newer)
- A C/C++ toolchain capable of building JavaScriptCore (Clang/LLVM on macOS + Linux, MSVC on Windows)

> **Note:** The Linux automation environment that drives this repo does **not** have JavaScriptCore compiled. Until we publish prebuilt artifacts, all work happens against the stubbed interfaces already present in `src/bun.js/`. Treat them as scaffolding: build APIs, clean dependencies, and verify Zig-only behavior, but don’t attempt to run/link the real JSC binary yet.

Smoke test the Zig-only scaffolding:

```bash
zig build            # builds the bridge static library
zig build test       # runs every file under bridge/tests/
```

The root `build.zig` wires `bridge/tests/*.zig` against `bridge/src/lib.zig`, which re-exports the slimmed `src/bun.js/jsc.zig`. These tests currently stop before touching real JavaScriptCore symbols so you can iterate on the Zig surface without dealing with the native library yet.

Next steps (see `BRIDGE_PLAN.md` for the detailed roadmap):

1. Integrate a real JavaScriptCore build and implement an `EvalHandler` that calls into it (the bridge exposes `api.configureEval` for this hook).
2. Continue trimming unneeded Bun bindings so only the bridge-critical surfaces remain.
3. Expand the test matrix with additional data-marshalling scenarios once real JSC builds become available.

## Test Matrix

| File | Scenario | Status |
| ---- | -------- | ------ |
| `bridge/tests/smoke.zig` | Sanity check + pulls in the rest of the suite | PASS |
| `bridge/tests/vm_lifecycle.zig` | Init/adopt/shutdown + eval lifecycle gates | PASS |
| `bridge/tests/hostfn_roundtrip.zig` | Register a Zig host fn and dispatch via metadata | PASS |
| `bridge/tests/gc_weakrefs.zig` | Reset paths free handles + hostfn registry | PASS |
| `bridge/tests/embed_loop.zig` | Simulated game loop exercising eval + host callbacks | PASS |

All rows execute under `zig build test`; add new scenarios here as coverage expands.

## Relationship to Bun

- `_Everything_` under `src/` that still references `bun.*` is historical scaffolding we are paring back to the bare essentials. Treat those symbols as implementation details, not product features.
- The repository intentionally keeps `src/bun.js/` paths because many of the C++ bindings expect those include locations. We will collapse the directories once the new bridge API is stable.
- When you need a reference implementation for how to call a JSC API, search the Git history rather than pulling large Bun subsystems back in.

## Support & Contact

- **Security reports:** see `SECURITY.md`.
- **Contributing:** `CONTRIBUTING.md` covers how to propose changes and run the bridge harness.
- **Project discussion:** use `DISCUSSION.md` for design notes, outstanding questions, and test plans tied to the new bridge.
- **Automation guidance:** `docs/LLM_GUIDE.md` documents the expectations for overnight/LLM runs.

If you are looking for the full Bun runtime, CLI, or package manager, use [`oven-sh/bun`](https://github.com/oven-sh/bun). This repository is intentionally minimal and is not a drop-in replacement for Bun itself.
