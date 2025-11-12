const std = @import("std");
const bridge = @import("bridge");

comptime {
    _ = @import("vm_lifecycle.zig");
    _ = @import("hostfn_roundtrip.zig");
    _ = @import("gc_weakrefs.zig");
    _ = @import("embed_loop.zig");
}

test "bridge scaffolding initializes lazily" {
    bridge.resetForTesting();
    defer bridge.resetForTesting();

    try std.testing.expect(!bridge.isInitialized());

    try bridge.initialize(.{});
    try std.testing.expect(bridge.isInitialized());
}
