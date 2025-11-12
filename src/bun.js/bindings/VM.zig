const builtin = @import("builtin");
const JSGlobalObject = @import("./JSGlobalObject.zig").JSGlobalObject;

pub const VM = opaque {
    pub fn deinit(vm: *VM, global: *JSGlobalObject) void {
        if (builtin.is_test) {
            _ = vm;
            _ = global;
            return;
        }
        JSC__VM__deinit(vm, global);
    }
};

extern fn JSC__VM__deinit(vm: *VM, global: *JSGlobalObject) void;
