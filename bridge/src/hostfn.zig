const std = @import("std");
const builtin = @import("builtin");
const bun = @import("bun");
const runtime = @import("runtime.zig");

pub const JSC = bun.jsc;

const Allocator = std.mem.Allocator;
const Mutex = std.Thread.Mutex;

pub const HostCallback = *const fn (context: ?*anyopaque, global: *JSC.JSGlobalObject, frame: *JSC.CallFrame) runtime.Error!JSC.JSValue;

pub const Registration = struct {
    name: []const u8,
    callback: HostCallback,
    context: ?*anyopaque = null,
    /// Number of parameters reported via `Function.length`.
    length: u8 = 0,
};

const StoredRegistration = struct {
    name: []u8,
    callback: HostCallback,
    context: ?*anyopaque,
    length: u8,
    js_function: JSC.JSValue = .zero,
};

var registry = std.ArrayListUnmanaged(*StoredRegistration){};
var registry_mutex = Mutex{};

fn allocator() Allocator {
    return bun.default_allocator;
}

pub fn expose(reg: Registration) runtime.Error!void {
    if (reg.name.len == 0) return runtime.Error.InvalidArgument;
    if (!runtime.isInitialized()) return runtime.Error.NotInitialized;

    const global = try runtime.globalObject();

    var stored = try allocateStoredRegistration(reg);
    var needs_destroy = true;
    errdefer if (needs_destroy) destroyStoredRegistration(stored);

    try installOnGlobal(global, stored);
    try remember(stored);

    needs_destroy = false;
}

pub fn callFromJS(global: *JSC.JSGlobalObject, frame: *JSC.CallFrame) runtime.Error!JSC.JSValue {
    const stored = try lookupRegistration(frame);
    return stored.callback(stored.context, global, frame);
}

pub fn reset() void {
    registry_mutex.lock();
    defer registry_mutex.unlock();

    const alloc = allocator();
    for (registry.items, 0..) |stored, idx| {
        _ = idx;
        destroyStoredRegistration(stored);
    }
    registry.deinit(alloc);
    registry = .{};
}

fn allocateStoredRegistration(reg: Registration) runtime.Error!*StoredRegistration {
    const alloc = allocator();
    var stored = alloc.create(StoredRegistration) catch return runtime.Error.EngineUnavailable;
    stored.* = .{
        .name = alloc.dupe(u8, reg.name) catch {
            alloc.destroy(stored);
            return runtime.Error.EngineUnavailable;
        },
        .callback = reg.callback,
        .context = reg.context,
        .length = reg.length,
        .js_function = .zero,
    };
    return stored;
}

fn installOnGlobal(global: *JSC.JSGlobalObject, stored: *StoredRegistration) runtime.Error!void {
    if (builtin.is_test) {
        stored.js_function = .zero;
        _ = global;
        return;
    }
    const function_value = try makeHostFunction(global, stored);
    stored.js_function = function_value;
    attachToGlobal(global, stored);
}

fn makeHostFunction(global: *JSC.JSGlobalObject, stored: *StoredRegistration) runtime.Error!JSC.JSValue {
    var symbol = JSC.ZigString.fromBytes(stored.name);
    const fn_value = JSC.host_fn.NewRuntimeFunction(
        global,
        &symbol,
        @intCast(stored.length),
        hostTrampoline,
        false,
        false,
        null,
    );
    if (fn_value == .zero) return runtime.Error.EngineUnavailable;
    JSC.host_fn.setFunctionData(fn_value, stored);
    return fn_value;
}

fn attachToGlobal(global: *JSC.JSGlobalObject, stored: *StoredRegistration) void {
    var symbol = JSC.ZigString.fromBytes(stored.name);
    const global_value = JSC.JSGlobalObject.toJSValue(global);
    global_value.putZigString(&symbol, global, stored.js_function);
}

fn remember(stored: *StoredRegistration) runtime.Error!void {
    registry_mutex.lock();
    defer registry_mutex.unlock();
    registry.append(allocator(), stored) catch return runtime.Error.EngineUnavailable;
}

fn destroyStoredRegistration(stored: *StoredRegistration) void {
    const alloc = allocator();
    alloc.free(stored.name);
    alloc.destroy(stored);
}

fn lookupRegistration(frame: *JSC.CallFrame) runtime.Error!*StoredRegistration {
    const callee = frame.callee();
    const data = JSC.host_fn.getFunctionData(callee) orelse return runtime.Error.InvalidHostFunction;
    return @ptrCast(@alignCast(data));
}

fn findRegistrationByNameUnlocked(name: []const u8) ?*StoredRegistration {
    for (registry.items) |stored| {
        if (std.mem.eql(u8, stored.name, name)) {
            return stored;
        }
    }
    return null;
}

fn hostTrampoline(global: *JSC.JSGlobalObject, frame: *JSC.CallFrame) callconv(JSC.conv) JSC.JSValue {
    const result = callFromJS(global, frame) catch |err| {
        reportRuntimeError(global, err);
        return .zero;
    };
    return result;
}

fn reportRuntimeError(global: *JSC.JSGlobalObject, err: runtime.Error) void {
    const message: []const u8 = switch (err) {
        error.NotInitialized => "runtime not initialized",
        error.MissingGlobalObject => "global object missing",
        error.EngineUnavailable => "JavaScriptCore engine unavailable",
        error.InvalidHostFunction => "host function metadata missing",
        error.InvalidArgument => "invalid host function registration",
    };
    _ = global.throwTODO(message) catch {};
}

pub const testing = if (builtin.is_test) struct {
    pub fn registrationCount() usize {
        registry_mutex.lock();
        defer registry_mutex.unlock();
        return registry.items.len;
    }

    pub fn has(name: []const u8) bool {
        registry_mutex.lock();
        defer registry_mutex.unlock();
        return findRegistrationByNameUnlocked(name) != null;
    }

    pub fn invoke(name: []const u8, global: *JSC.JSGlobalObject, frame: *JSC.CallFrame) runtime.Error!JSC.JSValue {
        registry_mutex.lock();
        const stored = findRegistrationByNameUnlocked(name);
        registry_mutex.unlock();
        if (stored) |entry| {
            return entry.callback(entry.context, global, frame);
        }
        return runtime.Error.InvalidHostFunction;
    }
} else struct {};
