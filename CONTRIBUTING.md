# Contributing

Thanks for helping build the Zig ↔ JavaScriptCore bridge! The repository was forked from Bun but now serves a single purpose: provide an embeddable API for creating a JavaScriptCore VM from Zig. Please keep that scope in mind when proposing changes.

## Prerequisites

- Zig `0.16.0-dev.732` or newer
- A C/C++ toolchain that can build JavaScriptCore (Clang/LLVM on macOS + Linux, MSVC on Windows)
- JavaScriptCore/WTF headers and libraries (only needed once we begin linking the native engine; the current smoke tests run without them)

## Local Workflow

1. Clone the repository and ensure the `bridge/` directory is in your `$PWD`.
2. Review `docs/LLM_GUIDE.md` for automation/build rules.
3. Run the Zig-only smoke tests:
   ```bash
   cd bridge
   zig build smoke
   ```
   This validates that `bridge/src/lib.zig` can be imported and that the initialization primitives behave.
4. Develop new bridge functionality inside `bridge/src/` (or `src/bun.js/` when editing the low-level bindings) and mirror the work with tests under `bridge/tests/`.
5. If you need to touch the legacy `src/` tree, keep the change narrowly focused on exposing the JSC API; avoid resurrecting large Bun subsystems.

## Coding Guidelines

- Prefer small, auditable modules over monolithic files. The goal is to make it easy for host applications to reason about what they are embedding.
- Document new entry points in `bridge/README.md` or `BRIDGE_PLAN.md` as appropriate.
- When interacting with the C++ bindings, ensure ABI changes are mirrored in both Zig and C++ sources.
- Every new feature should include a `zig test` in `bridge/tests/` (or a C++ unit test once we have a native harness).

## Submitting Changes

- Open a GitHub issue or discussion before large refactors so we can confirm they align with the bridge roadmap.
- Keep pull requests focused; it is easier to review a series of small PRs than a single sweeping rewrite.
- Update relevant documentation (`README.md`, `BRIDGE_PLAN.md`, etc.) whenever behavior changes.
- The maintainers run `zig build smoke` (and eventually the full bridge test suite) before merging. Please do the same locally.

Thank you for helping us turn this former Bun checkout into a lean, reusable Zig↔JSC SDK!
