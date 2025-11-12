const std = @import("std");
const bridge = @import("bridge");
const testlib = @import("testlib.zig");

const runtime = bridge.runtime;
const api = bridge.api;

test "runtime init adopts handles and shuts down cleanly" {
    testlib.reset();
    defer testlib.reset();

    try std.testing.expectError(runtime.Error.NotInitialized, runtime.shutdown());

    try runtime.init(.{});
    try std.testing.expect(runtime.isInitialized());

    try std.testing.expectError(runtime.Error.MissingGlobalObject, runtime.globalObject());

    const handles = testlib.makeHandles(1);
    try runtime.adoptHandles(handles);

    const global = try runtime.globalObject();
    try std.testing.expectEqual(@intFromPtr(handles.global), @intFromPtr(global));
    try std.testing.expect(runtime.handles() != null);

    try runtime.shutdown();
    try std.testing.expect(!runtime.isInitialized());
    try std.testing.expect(runtime.handles() == null);
}

test "runtime resetForTesting clears stale handles" {
    testlib.reset();
    defer testlib.reset();

    try runtime.init(.{});
    try testlib.adoptHandles(5);
    try std.testing.expect(runtime.handles() != null);

    runtime.resetForTesting();
    try std.testing.expect(!runtime.isInitialized());
    try std.testing.expect(runtime.handles() == null);

    try runtime.init(.{});
    try std.testing.expect(runtime.isInitialized());
}

test "api evalUtf8 enforces lifecycle and delegates to handler" {
    testlib.reset();
    defer testlib.reset();

    try std.testing.expectError(runtime.Error.NotInitialized, api.evalUtf8("1"));

    try runtime.init(.{});
    try std.testing.expectError(runtime.Error.MissingGlobalObject, api.evalUtf8("1"));

    try testlib.adoptHandles(6);
    try std.testing.expectError(runtime.Error.EngineUnavailable, api.evalUtf8("1"));

    testlib.enableEvalStub();
    const script = "return 42;";
    const value = try api.evalUtf8(script);
    const expected = runtime.JSC.JSValue.jsNumberFromInt32(@intCast(script.len));
    try std.testing.expectEqual(expected, value);
}
