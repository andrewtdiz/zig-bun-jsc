const std = @import("std");
const builtin = @import("builtin");
const bun = @import("bun");

pub const JSC = bun.jsc;

pub const Error = error{
    NotInitialized,
    NotImplemented,
};

pub const Config = struct {
    /// When true, mimic `bun --eval` semantics. Placeholder until we wire eval.
    eval_mode: bool = false,
};

const AtomicBool = std.atomic.Value(bool);
var initialized = AtomicBool.init(false);

/// Initialize JavaScriptCore once per process. During `zig test` runs we short
/// circuit so we can exercise the Zig-only scaffolding without linking JSC yet.
pub fn init(config: Config) Error!void {
    const already_initialized = initialized.swap(true, .SeqCst);
    if (already_initialized) return;

    if (builtin.is_test) {
        // Tests can toggle initialization without loading the native library.
        _ = config;
        return;
    }

    JSC.initialize(config.eval_mode);
}

pub fn shutdown() Error!void {
    // TODO: gracefully tear down VM state / allocators when we expose them.
    return Error.NotImplemented;
}

pub fn isInitialized() bool {
    return initialized.load(.SeqCst);
}

pub fn resetForTesting() void {
    initialized.store(false, .SeqCst);
}

pub fn globalObject() Error!*JSC.JSGlobalObject {
    return Error.NotImplemented;
}
