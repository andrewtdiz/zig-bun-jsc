const std = @import("std");
const bridge = @import("bridge");
const testlib = @import("testlib.zig");

const runtime = bridge.runtime;
const hostfn = bridge.hostfn;
const api = bridge.api;

test "embed loop orchestrates init, hostfn exposure, and shutdown" {
    testlib.reset();
    defer testlib.reset();

    try api.init(.{ .eval_mode = true });
    try testlib.adoptHandles(11);
    testlib.enableEvalStub();

    var tick_counter: usize = 0;
    try api.exposeHostFunction(.{
        .name = "tick",
        .length = 1,
        .context = &tick_counter,
        .callback = struct {
            fn run(context: ?*anyopaque, global: *runtime.JSC.JSGlobalObject, frame: *runtime.JSC.CallFrame) runtime.Error!runtime.JSC.JSValue {
                _ = global;
                _ = frame;
                const counter: *usize = @ptrCast(@alignCast(context.?));
                counter.* += 1;
                return runtime.JSC.JSValue.js_undefined;
            }
        }.run,
    });

    var frame: usize = 0;
    while (frame < 4) : (frame += 1) {
        const value = try hostfn.testing.invoke("tick", try runtime.globalObject(), testlib.fakeCallFrame());
        try std.testing.expectEqual(runtime.JSC.JSValue.js_undefined, value);
        const eval_value = try api.evalUtf8("tick()");
        try std.testing.expectEqual(runtime.JSC.JSValue.jsNumberFromInt32(@intCast("tick()".len)), eval_value);
    }

    try std.testing.expectEqual(@as(usize, 4), tick_counter);

    try api.shutdown();
    try std.testing.expect(!runtime.isInitialized());
    try std.testing.expectEqual(@as(usize, 0), hostfn.testing.registrationCount());
}
