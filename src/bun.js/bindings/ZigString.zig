/// Extremely small subset of Bun's ZigString helper. It only handles the UTF-8
/// names we pass while registering host functions. Once a real JavaScriptCore
/// build is available we can widen this implementation or drop it entirely in
/// favour of the upstream definition.
pub const ZigString = extern struct {
    ptr: [*]const u8,
    len: usize,

    pub fn fromBytes(slice: []const u8) ZigString {
        if (slice.len == 0) return .{ .ptr = empty_ptr(), .len = 0 };
        return .{ .ptr = slice.ptr, .len = slice.len };
    }

    pub fn slice(this: *const ZigString) []const u8 {
        return this.ptr[0..this.len];
    }
};

inline fn empty_ptr() [*]const u8 {
    return @ptrCast(&empty_bytes);
}

const empty_bytes = [_]u8{0};
