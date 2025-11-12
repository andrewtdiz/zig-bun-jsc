const std = @import("std");
const bridge = @import("bridge");
const testlib = @import("testlib.zig");

const runtime = bridge.runtime;
const hostfn = bridge.hostfn;

test "resetForTesting clears handles and hostfn state" {
    testlib.reset();
    defer testlib.reset();

    try runtime.init(.{});
    var handles = testlib.makeHandles(7);
    handles.owns_vm = true;
    try runtime.adoptHandles(handles);
    try std.testing.expect(runtime.handles() != null);

    try hostfn.expose(.{
        .name = "leaky",
        .length = 0,
        .callback = struct {
            fn noop(_: ?*anyopaque, global: *runtime.JSC.JSGlobalObject, frame: *runtime.JSC.CallFrame) runtime.Error!runtime.JSC.JSValue {
                _ = global;
                _ = frame;
                return runtime.JSC.JSValue.js_undefined;
            }
        }.noop,
    });
    try std.testing.expect(hostfn.testing.has("leaky"));

    runtime.resetForTesting();
    hostfn.reset();

    try std.testing.expect(runtime.handles() == null);
    try std.testing.expectEqual(@as(usize, 0), hostfn.testing.registrationCount());
}
