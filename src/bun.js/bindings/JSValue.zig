const builtin = @import("builtin");
const JSGlobalObject = @import("./JSGlobalObject.zig").JSGlobalObject;
const ZigString = @import("./ZigString.zig").ZigString;

/// Minimal representation of JSC's EncodedJSValue.
///
/// We intentionally keep the original Bun/Bun-JSC numeric tags for the
/// primitive values we rely on so that the eventual native bridge can simply
/// link the real helpers without further changes.
pub const JSValue = enum(i64) {
    js_undefined = 0xA,
    null = 0x2,
    true = 0x7,
    false = 0x6,
    zero = 0,
    _,
};

/// Build a numeric JSValue. Tests fall back to deterministic stubs so we can
/// exercise the Zig-only scaffolding without a real JavaScriptCore build.
pub fn jsNumberFromInt32(value: i32) JSValue {
    if (builtin.is_test) {
        // Reserve the high bit so the stub never collides with the small-int tags
        // from the real EncodedJSValue representation.
        const tagged_bits: u64 = @as(u64, test_number_prefix) | @as(u64, @intCast(@as(u32, @bitCast(value))));
        const tagged = @as(i64, @bitCast(tagged_bits));
        return @enumFromInt(tagged);
    }
    return JSC__JSValue__numberFromInt32(value);
}

pub inline fn jsBoolean(value: bool) JSValue {
    return if (value) .true else .false;
}

/// Attach `value` onto `object[key]` using a ZigString-backed property name.
pub fn putZigString(object: JSValue, global: *JSGlobalObject, key: *const ZigString, value: JSValue) void {
    if (builtin.is_test) {
        _ = object;
        _ = global;
        _ = key;
        _ = value;
        return;
    }
    JSC__JSValue__put(object, global, key, value);
}

const test_number_prefix: i64 = 0x4000_0000;

extern fn JSC__JSValue__numberFromInt32(value: i32) JSValue;
extern fn JSC__JSValue__put(value: JSValue, global: *JSGlobalObject, key: *const ZigString, result: JSValue) void;
