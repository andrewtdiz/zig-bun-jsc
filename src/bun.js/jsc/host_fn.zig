const builtin = @import("builtin");
const std = @import("std");
const JSValue = @import("../bindings/JSValue.zig").JSValue;
const JSGlobalObject = @import("../bindings/JSGlobalObject.zig").JSGlobalObject;
const CallFrame = @import("../bindings/CallFrame.zig").CallFrame;
const ZigString = @import("../bindings/ZigString.zig").ZigString;

pub const conv: std.builtin.CallingConvention = if (builtin.os.tag == .windows and builtin.cpu.arch == .x86_64)
    .{ .x86_64_sysv = .{} }
else
    .c;

pub const JSHostFn = *const fn (*JSGlobalObject, *CallFrame) callconv(conv) JSValue;
pub const JSHostFnZig = *const fn (*JSGlobalObject, *CallFrame) anyerror!JSValue;

pub fn JSHostFnZigWithContext(comptime Context: type) type {
    return *const fn (*Context, *JSGlobalObject, *CallFrame) anyerror!JSValue;
}

pub fn JSHostFunctionTypeWithContext(comptime Context: type) type {
    return *const fn (*Context, *JSGlobalObject, *CallFrame) callconv(conv) JSValue;
}

pub fn toJSHostFn(comptime fn_ptr: JSHostFnZig) JSHostFn {
    return struct {
        fn thunk(global: *JSGlobalObject, frame: *CallFrame) callconv(conv) JSValue {
            return fn_ptr(global, frame) catch { return .zero; };
        }
    }.thunk;
}

pub fn toJSHostFnWithContext(comptime Context: type, comptime fn_ptr: JSHostFnZigWithContext(Context)) JSHostFunctionTypeWithContext(Context) {
    return struct {
        fn thunk(ctx: *Context, global: *JSGlobalObject, frame: *CallFrame) callconv(conv) JSValue {
            return fn_ptr(ctx, global, frame) catch { return .zero; };
        }
    }.thunk;
}

/// Create a host function backed by Zig. Tests short-circuit to `.zero` because
/// the VM scaffolding is not linked on this machine.
pub fn NewRuntimeFunction(
    global: *JSGlobalObject,
    name: *const ZigString,
    length: u32,
    callback: JSHostFn,
    is_constructor: bool,
    is_strict: bool,
    context: ?*anyopaque,
) JSValue {
    if (builtin.is_test) {
        _ = global;
        _ = name;
        _ = length;
        _ = callback;
        _ = is_constructor;
        _ = is_strict;
        _ = context;
        return .zero;
    }
    return Bun__HostFunction__create(global, name, length, callback, is_constructor, is_strict, context);
}

pub fn setFunctionData(function_value: JSValue, data: ?*anyopaque) void {
    if (builtin.is_test) {
        _ = function_value;
        _ = data;
        return;
    }
    Bun__HostFunction__setData(function_value, data);
}

pub fn getFunctionData(function_value: JSValue) ?*anyopaque {
    if (builtin.is_test) return null;
    return Bun__HostFunction__getData(function_value);
}

extern fn Bun__HostFunction__create(
    global: *JSGlobalObject,
    name: *const ZigString,
    length: u32,
    callback: JSHostFn,
    is_constructor: bool,
    is_strict: bool,
    context: ?*anyopaque,
) JSValue;
extern fn Bun__HostFunction__setData(function_value: JSValue, data: ?*anyopaque) void;
extern fn Bun__HostFunction__getData(function_value: JSValue) ?*anyopaque;
