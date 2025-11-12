const std = @import("std");
const bridge = @import("bridge");

test "host function roundtrip placeholder" {
    std.log.info("hostfn roundtrip test pending host function plumbing", .{});
    _ = bridge.hostfn;
    return error.SkipZigTest;
}
