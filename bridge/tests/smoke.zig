const std = @import("std");
const bridge = @import("bridge");

test "bridge scaffolding initializes lazily" {
    bridge.resetForTesting();
    defer bridge.resetForTesting();

    try std.testing.expect(!bridge.isInitialized());

    bridge.initialize(.{});
    try std.testing.expect(bridge.isInitialized());
}
