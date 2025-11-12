const std = @import("std");
const builtin = @import("builtin");

/// Minimal subset of the legacy Bun module required by the bridge.
/// Provides platform info, logging hooks, and allocator access so
/// `src/bun.js/jsc.zig` can compile in isolation.

pub const Environment = struct {
    pub const isWindows = builtin.os.tag == .windows;
    pub const isX64 = builtin.cpu.arch == .x86_64;
    pub const enable_logs = false;
};

pub const Output = struct {
    pub const Scope = enum { JSC };
    pub const Visibility = enum { hidden };

    pub fn scoped(_: Scope, _: Visibility) type {
        return struct {
            pub fn log(_: []const u8, _: anytype) void {}
        };
    }

    pub fn errGeneric(comptime fmt: []const u8, args: anytype) void {
        std.io.getStdErr().writer().print(fmt ++ "\n", args) catch {};
    }
};

pub const Global = struct {
    pub fn exit(code: i32) noreturn {
        std.process.exit(code);
    }
};

pub const default_allocator: std.mem.Allocator = std.heap.c_allocator;

/// Re-export the JavaScriptCore Zig bindings.
pub const jsc = @import("../../src/bun.js/jsc.zig");
