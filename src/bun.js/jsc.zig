//! Bindings to JavaScriptCore and other JavaScript primatives such as
//! VirtualMachine, JSGlobalObject (Zig::GlobalObject), and the event loop.
//!
//! The surrounding Bun runtime APIs (webcore, node compat, etc.) have been
//! removed in this trimmed repository, so this module now focuses purely on
//! JavaScriptCore bindings.

/// The calling convention used for JavaScript functions <> Native
pub const conv: std.builtin.CallingConvention = if (bun.Environment.isWindows and bun.Environment.isX64)
    .{ .x86_64_sysv = .{} }
else
    .c;

/// Binding for JSCInitialize in ZigGlobalObject.cpp
pub fn initialize(eval_mode: bool) void {
    markBinding(@src());
    JSCInitialize(std.os.environ.ptr, std.os.environ.len, onJSCInvalidEnvVar, eval_mode);
}

pub const JSValue = @import("./bindings/JSValue.zig").JSValue;

// Host functions are the native function pointer type that can be used by a
// JSC::JSFunction to call native code from JavaScript. To allow usage of `try`
// for error handling, Bun provides toJSHostFn to wrap JSHostFnZig into JSHostFn.
pub const host_fn = @import("./jsc/host_fn.zig");
pub const JSHostFn = host_fn.JSHostFn;
pub const JSHostFnZig = host_fn.JSHostFnZig;
pub const JSHostFnZigWithContext = host_fn.JSHostFnZigWithContext;
pub const JSHostFunctionTypeWithContext = host_fn.JSHostFunctionTypeWithContext;
pub const toJSHostFn = host_fn.toJSHostFn;
pub const toJSHostFnWithContext = host_fn.toJSHostFnWithContext;

/// Handles consumed by `bridge/src/runtime.zig` and `bridge/src/hostfn.zig`.
pub const CallFrame = @import("./bindings/CallFrame.zig").CallFrame;
pub const JSGlobalObject = @import("./bindings/JSGlobalObject.zig").JSGlobalObject;
pub const VM = @import("./bindings/VM.zig").VM;
/// String helper used by `bridge/src/hostfn.zig` when naming functions.
pub const ZigString = @import("./bindings/ZigString.zig").ZigString;

const log = bun.Output.scoped(.JSC, .hidden);
pub inline fn markBinding(src: std.builtin.SourceLocation) void {
    log("{s} ({s}:{d})", .{ src.fn_name, src.file, src.line });
}
pub inline fn markMemberBinding(comptime class: anytype, src: std.builtin.SourceLocation) void {
    if (!bun.Environment.enable_logs) return;
    const classname = switch (@typeInfo(@TypeOf(class))) {
        .pointer => class, // assumed to be a static string
        else => @typeName(class),
    };
    log("{s}.{s} ({s}:{d})", .{ classname, src.fn_name, src.file, src.line });
}

pub const OpaqueCallback = *const fn (current: ?*anyopaque) callconv(.c) void;
pub fn OpaqueWrap(comptime Context: type, comptime Function: fn (this: *Context) void) OpaqueCallback {
    return struct {
        pub fn callback(ctx: ?*anyopaque) callconv(.c) void {
            const context: *Context = @as(*Context, @ptrCast(@alignCast(ctx.?)));
            Function(context);
        }
    }.callback;
}

/// According to https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date,
/// maximum Date in JavaScript is less than Number.MAX_SAFE_INTEGER (u52).
pub const init_timestamp = std.math.maxInt(JSTimeType);
pub const JSTimeType = u52;
pub fn toJSTime(sec: isize, nsec: isize) JSTimeType {
    const millisec = @as(u64, @intCast(@divTrunc(nsec, std.time.ns_per_ms)));
    return @as(JSTimeType, @truncate(@as(u64, @intCast(sec * std.time.ms_per_s)) + millisec));
}

pub const MAX_SAFE_INTEGER = 9007199254740991;
pub const MIN_SAFE_INTEGER = -9007199254740991;

extern "c" fn JSCInitialize(env: [*]const [*:0]u8, count: usize, cb: *const fn ([*]const u8, len: usize) callconv(.c) void, eval_mode: bool) void;
fn onJSCInvalidEnvVar(name: [*]const u8, len: usize) callconv(.c) void {
    bun.Output.errGeneric(
        \\invalid JSC environment variable
        \\
        \\    <b>{s}<r>
        \\
        \\For a list of options, see this file:
        \\
        \\    https://github.com/oven-sh/webkit/blob/main/Source/JavaScriptCore/runtime/OptionsList.h
        \\
        \\Environment variables must be prefixed with "BUN_JSC_". This code runs before .env files are loaded, so those won't work here.
        \\
        \\Warning: options change between releases of Bun and WebKit without notice. This is not a stable API, you should not rely on it beyond debugging something, and it may be removed entirely in a future version of Bun.
    ,
        .{name[0..len]},
    );
    bun.Global.exit(1);
}

const bun = @import("bun");
const std = @import("std");
