# Bindings Map

Use this table to track which binding files are still required by the bridge. Delete rows (and the corresponding files) once you confirm no Zig code imports them.

| Binding | Referenced From | Notes |
| ------- | --------------- | ----- |
| `src/bun.js/bindings/JSValue.zig` | `src/bun.js/jsc.zig`, `bridge/src/*` | Core value type – keep. |
| `src/bun.js/bindings/JSObject.zig` | `src/bun.js/jsc.zig`, `bridge/src/*` | Core object wrapper – keep. |
| `src/bun.js/bindings/JSGlobalObject.zig` | `src/bun.js/jsc.zig` | Needed once we expose runtime.globalObject(). |
| `src/bun.js/bindings/JSFunction.zig` | `src/bun.js/jsc.zig` | Required for host function plumbing. |
| `src/bun.js/bindings/JSString.zig` | `src/bun.js/jsc.zig` | Required for string conversion helpers. |
| `src/bun.js/bindings/JSArray.zig` | `src/bun.js/jsc.zig` | Optional? remove if no longer re-exported. |
| `src/bun.js/bindings/VM.zig` | `src/bun.js/jsc.zig` | Needed for VM handles. |
| `src/bun.js/bindings/Exception.zig` | `src/bun.js/jsc.zig` | Needed for error plumbing. |
| `src/bun.js/bindings/CallFrame.zig` | `src/bun.js/jsc.zig` | Required by host functions. |

Add additional rows as you audit the directory. Each time you delete a binding:
1. Remove the row from this table.
2. Delete the Zig + C++ files.
3. Update `src/bun.js/jsc.zig` exports.
