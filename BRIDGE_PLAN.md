# Minimal Zig ↔ JSC Bridge: Scope & Verification Strategy

## 1. Objective
Build a stripped-down subset of the Bun repository that contains only the infrastructure required for a bidirectional bridge between Zig and JavaScriptCore (JSC). All higher-level runtime features (Node shim, HTTP/Web APIs, bundler, package manager, CLI, etc.) are intentionally deleted. The resulting artifact should:

- Initialize and own a JSC VM across macOS, Linux, and Windows.
- Expose host functions written in Zig to the JS world.
- Allow Zig to evaluate JS, get/set object properties, and marshal primitive + structured data in both directions.
- Support basic lifecycle hooks (GC integration, VM teardown, microtask flushing) needed for an embedded game-engine use case.

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

## 3. High-Level Task Breakdown
| Phase | Goals |
| --- | --- |
| **Inventory & Prune** | (Completed) Remove directories unrelated to Zig↔JSC bridging; confirm no surviving build references to deleted code. |
| **Surface Audit** | Trace every Zig file that imports `src/bun.js/jsc.zig`. Delete or simplify call sites that assume Bun APIs (e.g., HTTP, bundler). |
| **Bridge Isolation** | Refactor surviving modules into an explicit `bridge/` namespace to clarify ownership and ease future packaging. |
| **Host API Definition** | Decide the minimal host-facing API (`bridge.init()`, `bridge.eval(string) -> JSValue`, `bridge.call(fn, args)`, `bridge.expose(name, ZigFn)`, etc.) and document it for the game-engine team. |
| **Testing Harness** | Stand up a verifiable test suite (see below) that exercises the reduced functionality in CI. |

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
   - Assertions performed on the Zig side to avoid reintroducing Bun’s test runner. Example: JS calls `globalThis.__zigCallback(JSON.stringify({ foo: 1 }))`, Zig parses the payload and checks invariants.

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
- **Custom Test Driver**: Add `bun bd bridge:test` (or a plain `zig build bridge-test`) that compiles the bridge plus tests without relying on removed infrastructure.
- **Snapshot-free Assertions**: Prefer direct equality checks and structured logging so CI logs stay readable.
- **GC/Memory Hooks**: Enable `BUN_DEBUG` scopes or similar compile-time flags so tests can enforce “no leaked handles” after each run.
- **Cross-Platform Matrix**: Keep the Buildkite (or GitHub Actions) jobs minimal—just build + run the bridge tests on macOS, Linux, Windows. Fail on any ABI drift.

### 4.3 Pass/Fail Criteria
- VM initializes and shuts down without leaks (track via `wtf::RefCounted` stats or Zig allocators).
- Host → JS call, JS → host callback, and round-trip data conversions all succeed for primitives, objects, arrays, and typed arrays.
- Exceptions propagate with useful stack info on both sides.
- Deterministic microtask execution order (tests attach hooks to verify `Promise` resolutions run before the next tick).
- Stress set passes under configurable iteration counts; failures dump diagnostic info (heap size, pending jobs).

## 5. Deliverables Checklist
- [ ] Updated build scripts producing a single bridge library/binary.
- [ ] Documentation for the host API and embedding steps.
- [ ] Automated bridge test target wired into CI.
- [ ] Reference harness demonstrating integration (e.g., mock game-loop executable).
- [ ] Monitoring of binary size + dependency list to ensure we stay within embedded constraints.

By codifying the minimal layers and standing up this verification suite, we get repeatable proof that the Zig↔JSC bridge works independently from the rest of Bun and is safe to embed in the target game engine. Once stable, we can consider packaging it as a reusable SDK or git submodule for downstream teams.
