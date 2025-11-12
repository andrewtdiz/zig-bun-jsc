const std = @import("std");
const builtin = @import("builtin");

const bun = @import("bun");

/// Re-export the trimmed JavaScriptCore bindings so downstream code has a
/// single import path (`@import("../src/lib.zig").JSC`).
pub const JSC = bun.jsc;
pub const JSValue = JSC.JSValue;
pub const JSObject = JSC.JSObject;
pub const JSString = JSC.JSString;

pub const BridgeError = error{
    NotInitialized,
    NotImplemented,
};

pub const BridgeConfig = struct {
    eval_mode: bool = false,
};

const AtomicBool = std.atomic.Value(bool);
var is_initialized = AtomicBool.init(false);

/// Initialize JavaScriptCore once per process. During `zig test` runs we short
/// circuit so we can exercise the Zig-only scaffolding without linking JSC yet.
pub fn initialize(config: BridgeConfig) void {
    const was_initialized = is_initialized.swap(true, .SeqCst);
    if (was_initialized) return;

    if (builtin.is_test) {
        _ = config;
        return;
    }

    JSC.initialize(config.eval_mode);
}

pub fn resetForTesting() void {
    is_initialized.store(false, .SeqCst);
}

pub fn isInitialized() bool {
    return is_initialized.load(.SeqCst);
}

/// High-level API surface that the future game engine will call into.
pub const Bridge = struct {
    /// TODO: wire up VM + global object creation and call into JSC.
    pub fn eval(_: []const u8) BridgeError!JSValue {
        return BridgeError.NotImplemented;
    }

    pub fn exposeHostFunction(_: []const u8, _: JSC.JSHostFnZig) BridgeError!void {
        return BridgeError.NotImplemented;
    }
};
