# Bindings Map

The bridge now re-exports only the bindings that are exercised by `bridge/src/*`. Keep this table in sync with `src/bun.js/jsc.zig` so future cleanups can prove we are not dragging unused Bun code back in.

| Binding | Referenced From | Purpose |
| ------- | --------------- | ------- |
| `src/bun.js/bindings/JSValue.zig` | `src/bun.js/jsc.zig`, `bridge/src/runtime.zig`, `bridge/src/hostfn.zig`, `bridge/tests/*` | Tagged value handle for all eval + hostfn flows. |
| `src/bun.js/bindings/CallFrame.zig` | `src/bun.js/jsc.zig`, `bridge/src/hostfn.zig` | Provides the `CallFrame` passed to Zig host callbacks. |
| `src/bun.js/bindings/JSGlobalObject.zig` | `src/bun.js/jsc.zig`, `bridge/src/runtime.zig`, `bridge/src/hostfn.zig` | Exposes the primary global object handle returned by `runtime.globalObject()`. |
| `src/bun.js/bindings/VM.zig` | `src/bun.js/jsc.zig`, `bridge/src/runtime.zig`, `bridge/tests/testlib.zig` | Wraps the VM pointer needed for lifecycle management. |
| `src/bun.js/bindings/ZigString.zig` | `src/bun.js/jsc.zig`, `bridge/src/hostfn.zig` | Converts Zig strings so host functions can be named on the global object. |

> If a binding disappears from this list, delete the corresponding Zig/C++ files and remove the re-export from `src/bun.js/jsc.zig`.

2025-11-13: Removed the lingering `WTF.zig` re-export from `src/bun.js/jsc.zig`; legacy Bun sources import it directly now, so the bridge only exposes `JSValue`, `CallFrame`, `JSGlobalObject`, `VM`, and `ZigString`.

2025-11-13: Removed the legacy `Strong`, `Weak`, `WeakRefType`, `RefString`, and `javascript_core_c_api` exports from `src/bun.js/jsc.zig`. They are no longer part of the bridge module surface and can be deleted once the remaining Bun-era sources that reference them are removed.

2025-11-14: Deleted the rest of `src/bun.js/bindings/` and reimplemented the five retained bindings with lightweight stubs. The new files only depend on the bridge’s mini `bun` module and provide deterministic fallbacks while tests run without a native JavaScriptCore build. When the real engine becomes available we can replace the `builtin.is_test` branches with calls into the upstream C++ helpers.
