# Minimal Zig ↔ JSC Bridge: Scope & Verification Strategy

## 1. Objective
Build a stripped-down subset of the former Bun runtime that contains only the infrastructure required for a bidirectional bridge between Zig and JavaScriptCore (JSC). All higher-level runtime features (Node shim, HTTP/Web APIs, bundler, package manager, CLI, etc.) are intentionally deleted. The resulting artifact should:

- Initialize and own a JSC VM across macOS, Linux, and Windows.
- Expose host functions written in Zig to the JS world.
- Allow Zig to evaluate JS, get/set object properties, and marshal primitive + structured data in both directions.
- Support basic lifecycle hooks (GC integration, VM teardown, microtask flushing) needed for an embedded game-engine use case.
- Do NOT deprecate ANY functionality relating to FFI support

> **Practical constraint:** We do **not** have a Linux build of JavaScriptCore in this environment. Until that changes, the bridge work must rely on the existing Bun scaffolding (`src/bun.js/jsc.zig` and related bindings) without actually linking or executing JSC. Focus on cleaning Bun dependencies, tightening the API surface, and ensuring the Zig runtime modules behave deterministically under tests that stop short of invoking real JSC entry points.
