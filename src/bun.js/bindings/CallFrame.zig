const builtin = @import("builtin");
const JSValue = @import("./JSValue.zig").JSValue;

/// Opaque representation of JSC::CallFrame. We only need access to the callee
/// handle so that host functions can discover the registered Zig metadata.
pub const CallFrame = opaque {
    pub fn callee(self: *const CallFrame) JSValue {
        if (builtin.is_test) return .zero;
        return JSC__CallFrame__callee(self);
    }
};

extern fn JSC__CallFrame__callee(frame: *const CallFrame) JSValue;
