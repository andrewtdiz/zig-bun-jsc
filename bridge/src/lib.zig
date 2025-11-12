const bun = @import("bun");

/// Expose the trimmed JSC bindings so downstream code has a single import path.
pub const JSC = bun.jsc;
pub const JSValue = JSC.JSValue;
pub const JSGlobalObject = JSC.JSGlobalObject;
pub const CallFrame = JSC.CallFrame;

/// Bridge modules
pub const runtime = @import("runtime.zig");
pub const hostfn = @import("hostfn.zig");
pub const api = @import("api.zig");

/// Convenience helpers used by the existing smoke tests.
pub const initialize = runtime.init;
pub const isInitialized = runtime.isInitialized;
pub const resetForTesting = runtime.resetForTesting;
