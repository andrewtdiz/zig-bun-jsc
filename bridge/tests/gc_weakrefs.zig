const std = @import("std");
const bridge = @import("bridge");

test "gc weak refs placeholder" {
    std.log.info("gc weak refs test pending runtime + GC hooks", .{});
    _ = bridge.runtime;
    return error.SkipZigTest;
}
