const runtime = @import("runtime.zig");
const hostfn = @import("hostfn.zig");

pub const Error = runtime.Error;
pub const Config = runtime.Config;
pub const Registration = hostfn.Registration;

pub fn init(config: Config) Error!void {
    try runtime.init(config);
}

pub fn shutdown() Error!void {
    return runtime.shutdown();
}

pub fn evalUtf8(_: []const u8) Error!runtime.JSC.JSValue {
    return Error.NotImplemented;
}

pub fn exposeHostFunction(registration: Registration) Error!void {
    try hostfn.expose(registration);
}
