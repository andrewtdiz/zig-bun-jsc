const runtime = @import("runtime.zig");
const hostfn = @import("hostfn.zig");

pub const Error = runtime.Error;
pub const Config = runtime.Config;
pub const Registration = hostfn.Registration;
pub const EvalOptions = runtime.EvalOptions;
pub const EvalHandler = runtime.EvalHandler;

pub fn init(config: Config) Error!void {
    try runtime.init(config);
}

pub fn shutdown() Error!void {
    hostfn.reset();
    return runtime.shutdown();
}

pub fn evalUtf8(script: []const u8) Error!runtime.JSC.JSValue {
    return runtime.evalUtf8(script, .{});
}

pub fn exposeHostFunction(registration: Registration) Error!void {
    try hostfn.expose(registration);
}

pub fn configureEval(handler: EvalHandler, context: ?*anyopaque) void {
    runtime.installEvalHandler(handler, context);
}
