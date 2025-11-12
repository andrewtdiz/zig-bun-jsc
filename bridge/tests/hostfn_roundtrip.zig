const std = @import("std");
const bridge = @import("bridge");
const testlib = @import("testlib.zig");

const runtime = bridge.runtime;
const hostfn = bridge.hostfn;

test "host function registration stores metadata and dispatches via testing harness" {
    testlib.reset();
    defer testlib.reset();

    try runtime.init(.{});
    try testlib.adoptHandles(2);

    var call_count: usize = 0;
    const registration = hostfn.Registration{
        .name = "zigCallback",
        .length = 1,
        .context = &call_count,
        .callback = struct {
            fn run(context: ?*anyopaque, global: *runtime.JSC.JSGlobalObject, frame: *runtime.JSC.CallFrame) runtime.Error!runtime.JSC.JSValue {
                _ = global;
                _ = frame;
                const counter: *usize = @ptrCast(@alignCast(context.?));
                counter.* += 1;
                return runtime.JSC.JSValue.true;
            }
        }.run,
    };

    try hostfn.expose(registration);
    try std.testing.expectEqual(@as(usize, 1), hostfn.testing.registrationCount());

    const value = try hostfn.testing.invoke("zigCallback", try runtime.globalObject(), testlib.fakeCallFrame());
    try std.testing.expectEqual(runtime.JSC.JSValue.true, value);
    try std.testing.expectEqual(@as(usize, 1), call_count);

    hostfn.reset();
    try std.testing.expectEqual(@as(usize, 0), hostfn.testing.registrationCount());
    try runtime.shutdown();
}

test "host function invoke reports missing registrations" {
    testlib.reset();
    defer testlib.reset();

    try runtime.init(.{});
    try testlib.adoptHandles(3);

    const global = try runtime.globalObject();
    try std.testing.expectError(runtime.Error.InvalidHostFunction, hostfn.testing.invoke("missing", global, testlib.fakeCallFrame()));

    try runtime.shutdown();
}
