const std = @import("std");
const bridge = @import("bridge");

const runtime = bridge.runtime;
const api = bridge.api;

pub fn reset() void {
    bridge.hostfn.reset();
    runtime.resetForTesting();
}

pub fn makeHandles(seed: usize) runtime.Handles {
    const base = 0x1000 + seed * 0x200;
    return .{
        .vm = fakePtr(runtime.JSC.VM, base),
        .global = fakePtr(runtime.JSC.JSGlobalObject, base + 0x80),
        .owns_vm = false,
    };
}

pub fn adoptHandles(seed: usize) runtime.Error!void {
    try runtime.adoptHandles(makeHandles(seed));
}

pub fn fakeCallFrame() *runtime.JSC.CallFrame {
    return fakePtr(runtime.JSC.CallFrame, 0xF000);
}

pub fn enableEvalStub() void {
    api.configureEval(stubEvaluator, null);
}

fn fakePtr(comptime T: type, addr: usize) *T {
    std.debug.assert(addr != 0);
    return @as(*T, @ptrFromInt(addr));
}

fn stubEvaluator(
    _: ?*anyopaque,
    _: *runtime.JSC.JSGlobalObject,
    script: []const u8,
    _: api.EvalOptions,
) runtime.Error!runtime.JSC.JSValue {
    const max_supported: usize = @intCast(@as(i64, std.math.maxInt(i32)));
    const clipped_len = @min(script.len, max_supported);
    return runtime.JSC.JSValue.jsNumberFromInt32(@intCast(clipped_len));
}
