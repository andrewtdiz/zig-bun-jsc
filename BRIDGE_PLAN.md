# Minimal Zig ↔ JSC Bridge: Scope & Verification Strategy

## 1. Objective
Build a stripped-down subset of the former Bun runtime that contains only the infrastructure required for a bidirectional bridge between Zig and JavaScriptCore (JSC). All higher-level runtime features (Node shim, HTTP/Web APIs, bundler, package manager, CLI, etc.) are intentionally deleted. The resulting artifact should:

- Initialize and own a JSC VM across macOS, Linux, and Windows.
- Expose host functions written in Zig to the JS world.
- Allow Zig to evaluate JS, get/set object properties, and marshal primitive + structured data in both directions.
- Support basic lifecycle hooks (GC integration, VM teardown, microtask flushing) needed for an embedded game-engine use case.

> **Practical constraint:** We do **not** have a Linux build of JavaScriptCore in this environment. Until that changes, the bridge work must rely on the existing Bun scaffolding (`src/bun.js/jsc.zig` and related bindings) without actually linking or executing JSC. Focus on cleaning Bun dependencies, tightening the API surface, and ensuring the Zig runtime modules behave deterministically under tests that stop short of invoking real JSC entry points.

## 2. Minimal Layers to Keep/Refactor
1. **C++ binding surface (`src/bun.js/bindings/bindings.cpp`, `headers.h`)**  
   - Acts as the ABI contract between Zig and JSC.
   - Responsible for VM creation, JSValue helpers, property access, call helpers, exception translation, and platform-specific calling conventions.

2. **Zig-facing interface (`src/bun.js/jsc.zig`, `src/bun.js/bindings/*.zig`)**  
   - Thin wrappers that import `extern` functions and expose Zig-native structs/enums (`JSValue`, `JSGlobalObject`, `VM`, `CallFrame`, `JSObject`, `JSFunction`, `JSString`).
   - Should be auditable; remove dead declarations created for deleted APIs.

3. **Bootstrap glue (`src/runtime.zig`, `src/bun.js/VirtualMachine.zig`, `src/bun.js/ConsoleObject.zig` as needed)**  
   - Configure the VM, install a minimal global object, register bridge functions, and expose entry points the host game engine can call.
   - Keep logging/console minimal—only what is required to debug bridging.

4. **Build system artifacts (`build.zig`, `CMakeLists.txt`, `scripts/build-jsc.ts`)**  
   - Update to compile only the retained sources and link against upstream JSC/WTF/libicu dependencies.

## 3. Incremental Task Board
> Use these checklists to drive automation/LLM loops. Each item references the primary file(s) to touch and the validation command to run.

### Phase A · Architecture Skeleton
- [] `build.zig`: replace the legacy Bun build with a ~100 line script that (1) builds `bridge` as a static library and (2) runs the bridge tests via `zig build test`. (2024-05-26 — root build now installs the bridge lib and exposes `zig build test`.)
- [] `bridge/src/lib.zig`: split into modules (`runtime.zig`, `hostfn.zig`, `api.zig`) and re-export them from `lib.zig`. (2024-05-26 — `bridge/src/lib.zig` re-exports the trimmed modules.)
- [] `bridge/src/runtime.zig`: scaffold functions `init(config)`, `shutdown()`, `globalObject()`, each `@compileError("TODO")` until implemented. (2024-05-26 — lifecycle + handle adoption fully implemented.)
- [] `bridge/src/hostfn.zig`: provide helpers (`register`, `callFromJS`) with TODO bodies plus doc comments describing expected behavior. (2024-05-26 — registry + trampoline wired through Bun’s hostfn helpers.)
- [] `bridge/tests/vm_lifecycle.zig`: exercised runtime init/adopt/shutdown paths without Skip tests (2024-05-26 — added real lifecycle assertions + reset coverage).

### Phase B · Binding Cleanup
- [] `docs/bindings-map.md` (new): list every Zig file under `src/bun.js/bindings/` that is still imported; explicitly mark candidates for deletion. (2025-11-12 — audit now enumerates every import with keep/trim/legacy status.)
- [] For each unused binding file, delete the Zig + C++ pair and remove the re-export from `src/bun.js/jsc.zig`. (2025-11-12 — `src/bun.js/jsc.zig` now re-exports only JSValue/CallFrame/JSGlobalObject/VM/ZigString; remaining bindings are no longer reachable by the bridge.)
- [] `src/bun.js/jsc.zig`: ensure only the types we actively re-export remain, with comments referencing the new modules in `bridge/src/`. (2025-11-12 — added bridge-specific comment inline with the trimmed exports.)

### Phase C · Host API Definition
- [] `bridge/src/api.zig`: define the public surface (`pub fn evalUtf8`, `pub fn exposeHostFn`, `pub fn callFunction`) with structured error types. (2024-05-26 — API exposes init/shutdown/eval + hostfn with eval delegates.)
- [] `bridge/README.md`: document the API (parameters, threading expectations, error values) and link to example usage. (2024-05-26 — README now calls out eval handlers + test workflow.)
- [] `docs/LLM_GUIDE.md`: add explicit instructions for future automation runs (allowed directories, required commands, style rules). (2025-11-12 — guide now documents the bun shim, allowed paths, and mandatory commands.)

### Phase D · Testing
- [] `bridge/tests/hostfn_roundtrip.zig`: JS→Zig dispatch verified via testing harness (2024-05-26 — registry/invocation tests, no more Skip).
- [] `bridge/tests/gc_weakrefs.zig`: runtime reset now asserts handles/registry cleanup (2024-05-26 — simulates weak-ref cleanup).
- [] `bridge/tests/embed_loop.zig`: mock game loop drives api.init/eval/expose (2024-05-26 — hostfn tick loop + shutdown assertions).
- [] `README.md`: add “Test Matrix” section mapping each test file to the scenario it covers. (2024-05-26 — README table tracks the suite.)

### Phase E · Legacy Runtime Cleanup
- [] Remove the Bun CLI entrypoints (`src/main.zig`, `src/main_test.zig`, `src/main_wasm.zig`) so the repository only exposes the bridge library. (2025-11-12 — deleted the unused binaries flagged by the verifier.)

Track progress by editing this section directly—automation runs can simply check off the boxes they complete.

## 4. Verifiable Testing Suite
Design tests that can run without the removed Bun subsystems but still prove the bridge works cross-platform and under stress.

### 4.1 Layered Test Types
1. **C++/ABI Unit Tests (Zig or C++)**
   - Validate `bindings.cpp` helpers independently: convert primitives, allocate objects, throw/catch exceptions.
   - Use Zig tests that call `extern "c"` helpers directly; assert ABI expectations (pointer sizes, tagged values).

2. **Zig Integration Tests**
   - Spin up a VM inside a Zig test binary.
   - Scenario matrix:
     - Call a JS function from Zig, pass numbers/strings/typed arrays, receive results.
     - Register a Zig host function and call it from JS (confirm argument marshalling and exception propagation).
     - Create JS objects in Zig, mutate in JS, read back in Zig.
     - Trigger GC from Zig, ensure weak references/handles remain valid.
   - Store these tests under a new lightweight tree, e.g. `bridge_tests/zig/`.

3. **JavaScript-Level Contract Tests**
   - Bundle a handful of `.js` fixtures executed via `bridge.eval`.
   - Assertions performed on the Zig side to avoid reintroducing the old Bun test runner. Example: JS calls `globalThis.__zigCallback(JSON.stringify({ foo: 1 }))`, Zig parses the payload and checks invariants.

4. **Conformance + Stress**
   - Micro-bench tasks to ensure the bridge can handle:
     - Rapid host → JS calls (thousands per frame).
     - Large strings and `ArrayBufferView` transfers.
     - Concurrent Zig tasks posting work onto the VM thread (if tolerated).
   - Collect metrics (latency, allocation counts) and compare to established baselines as a regression guard.

5. **Game-Engine Embedding Smoke Tests**
   - Provide a mock C ABI (`extern "C" fn bridge_tick(delta_ms: f64)`) the engine will call.
   - Simulate the engine loop in a Zig test; ensure re-entrancy and teardown behave.

### 4.2 Tooling & Automation
- **Root Build Target**: `zig build test` (from repo root) must compile the bridge static lib and run every file under `bridge/tests/`. No other tooling required.
- **Snapshot-free Assertions**: Prefer direct equality checks and structured logging so CI logs stay readable.
- **GC/Memory Hooks**: Enable a `BRIDGE_DEBUG_*` scope (or similar compile-time flag) so tests can enforce “no leaked handles” after each run.
- **Cross-Platform Matrix**: Keep CI minimal—just build + run the bridge tests on macOS, Linux, Windows. Fail on any ABI drift.

### 4.3 Pass/Fail Criteria
- VM initializes and shuts down without leaks (track via `wtf::RefCounted` stats or Zig allocators).
- Host → JS call, JS → host callback, and round-trip data conversions all succeed for primitives, objects, arrays, and typed arrays.
- Exceptions propagate with useful stack info on both sides.
- Deterministic microtask execution order (tests attach hooks to verify `Promise` resolutions run before the next tick).
- Stress set passes under configurable iteration counts; failures dump diagnostic info (heap size, pending jobs).

## 5. Machine Checklist
This section spells out the commands an automated run should execute after each change:

1. `zig fmt bridge/src/*.zig bridge/tests/*.zig` — keep scaffolding tidy.
2. `zig build test` — run the top-level build once the simplified script lands. Until then, run `cd bridge && zig build smoke`.
3. `git status -sb` — verify only the intended files changed; automation should include this in its log.
4. Update the checkboxes above to reflect progress and add short notes (e.g., “implemented evalUtf8 in bridge/src/api.zig”).

## 6. Deliverables Checklist
- [] Updated build scripts producing a single bridge library/binary. (2025-11-12 — root `build.zig` now builds/installs only the `bridge` static lib and its tests.)
- [] Documentation for the host API and embedding steps. (2024-05-26 — `README.md` + `bridge/README.md` describe init/eval/hostfn usage.)
- [] Automated bridge test target wired into CI. (2024-05-26 — `zig build test` drives every file under `bridge/tests/`.)
- [] Reference harness demonstrating integration (e.g., mock game-loop executable). (2024-05-26 — `bridge/tests/embed_loop.zig` simulates the host loop.)
- [] Monitoring of binary size + dependency list to ensure we stay within embedded constraints. (2025-11-12 — `docs/bindings-map.md` tracks the remaining bindings so dependency creep is visible.)

By codifying the minimal layers and standing up this verification suite, we get repeatable proof that the Zig↔JSC bridge works independently from the rest of the Bun-era code and is safe to embed in the target game engine. Once stable, we can consider packaging it as a reusable SDK or git submodule for downstream teams.
