const bun = @import("bun");
const runtime = @import("runtime.zig");

pub const JSC = bun.jsc;

pub const Registration = struct {
    name: []const u8,
    callback: JSC.JSHostFnZigWithContext,
    context: ?*anyopaque = null,
};

pub fn expose(reg: Registration) runtime.Error!void {
    _ = reg;
    return runtime.Error.NotImplemented;
}

pub fn callFromJS(_: *JSC.JSGlobalObject, _: JSC.CallFrame) runtime.Error!JSC.JSValue {
    return runtime.Error.NotImplemented;
}
