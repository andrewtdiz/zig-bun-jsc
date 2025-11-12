const std = @import("std");
const bridge = @import("bridge");

test "embedding loop placeholder" {
    std.log.info("embed loop test pending API wiring", .{});
    _ = bridge.api;
    return error.SkipZigTest;
}
