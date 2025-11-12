const builtin = @import("builtin");
const JSValue = @import("./JSValue.zig").JSValue;

/// Minimal handle to the VM's primary global object.
pub const JSGlobalObject = opaque {
    pub inline fn toJSValue(this: *JSGlobalObject) JSValue {
        return @enumFromInt(@intFromPtr(this));
    }

    /// Placeholder error helper until the true JavaScriptCore bridge is wired in.
    pub fn throwTODO(_: *JSGlobalObject, _: []const u8) error{JSError} {
        return error.JSError;
    }
};
