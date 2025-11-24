const std = @import("std");
const builtin = @import("builtin");
const bun = @import("bun");

pub const JSC = bun.jsc;

pub const Error = error{
    NotInitialized,
    MissingGlobalObject,
    EngineUnavailable,
    InvalidHostFunction,
    InvalidArgument,
};

pub const Config = struct {
    /// When true, mimic `bun --eval` semantics. Placeholder until we wire eval.
    eval_mode: bool = false,
    /// Optional pre-built handles for the JSC VM + global object. When omitted
    /// we operate in a "configuration only" mode until the embedder provides
    /// concrete pointers via `adoptHandles`.
    handles: ?Handles = null,
};

pub const Handles = struct {
    vm: *JSC.VM,
    global: *JSC.JSGlobalObject,
    owns_vm: bool = false,
};

pub const EvalOptions = struct {
    filename: []const u8 = "<eval>",
};

pub const EvalHandler = *const fn (context: ?*anyopaque, global: *JSC.JSGlobalObject, script: []const u8, options: EvalOptions) Error!JSC.JSValue;

const AtomicBool = std.atomic.Value(bool);
var initialized = AtomicBool.init(false);

const State = struct {
    config: Config = .{},
    vm: ?*JSC.VM = null,
    global: ?*JSC.JSGlobalObject = null,
    owns_vm: bool = false,
};

var state: State = .{};

const EvalBackend = struct {
    handler: EvalHandler = defaultEvaluator,
    context: ?*anyopaque = null,
};

var eval_backend: EvalBackend = .{};

/// Initialize JavaScriptCore once per process. During `zig test` runs we short
/// circuit so we can exercise the Zig-only scaffolding without linking JSC yet.
pub fn init(config: Config) Error!void {
    const already_initialized = initialized.swap(true, .seq_cst);
    if (already_initialized) return;

    state.config = config;

    if (builtin.is_test) {
        // Tests can toggle initialization without loading the native library.
        if (config.handles) |provided_handles| {
            try adoptHandles(provided_handles);
        }
        return;
    }

    JSC.initialize(config.eval_mode);

    if (config.handles) |provided_handles| {
        try adoptHandles(provided_handles);
    }
}

pub fn shutdown() Error!void {
    const was_initialized = initialized.swap(false, .seq_cst);
    if (!was_initialized) return Error.NotInitialized;

    releaseVmHandlesIfPresent();
    resetState();
}

pub fn isInitialized() bool {
    return initialized.load(.seq_cst);
}

pub fn resetForTesting() void {
    releaseVmHandlesIfPresent();
    initialized.store(false, .seq_cst);
    resetState();
}

pub fn globalObject() Error!*JSC.JSGlobalObject {
    if (!isInitialized()) return Error.NotInitialized;
    return state.global orelse Error.MissingGlobalObject;
}

pub fn adoptHandles(new_handles: Handles) Error!void {
    if (!isInitialized()) return Error.NotInitialized;
    state.vm = new_handles.vm;
    state.global = new_handles.global;
    state.owns_vm = new_handles.owns_vm;
}

pub fn handles() ?Handles {
    const vm_ptr = state.vm orelse return null;
    const global_ptr = state.global orelse return null;
    return .{
        .vm = vm_ptr,
        .global = global_ptr,
        .owns_vm = state.owns_vm,
    };
}

pub fn installEvalHandler(handler: EvalHandler, context: ?*anyopaque) void {
    eval_backend = .{
        .handler = handler,
        .context = context,
    };
}

pub fn evalUtf8(script: []const u8, options: EvalOptions) Error!JSC.JSValue {
    if (script.len == 0) return Error.InvalidArgument;
    const global = try globalObject();
    return eval_backend.handler(eval_backend.context, global, script, options);
}

fn releaseVmHandlesIfPresent() void {
    const vm_ptr = state.vm orelse {
        state.global = null;
        state.owns_vm = false;
        return;
    };
    defer state.vm = null;

    const global_ptr = state.global orelse {
        state.global = null;
        state.owns_vm = false;
        return;
    };
    state.global = null;
    const owned = state.owns_vm;
    state.owns_vm = false;

    if (builtin.is_test) return;
    if (!owned) return;

    JSC.VM.deinit(vm_ptr, global_ptr);
}

fn resetState() void {
    state = .{};
    eval_backend = .{};
}

fn defaultEvaluator(_: ?*anyopaque, _: *JSC.JSGlobalObject, _: []const u8, _: EvalOptions) Error!JSC.JSValue {
    return Error.EngineUnavailable;
}
