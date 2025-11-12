const std = @import("std");

/// Minimal build configuration for the trimmed JSC↔Zig bridge.
pub const use_mimalloc = false;
pub const override_no_export_cpp_apis = false;
pub const zig_self_hosted_backend = false;
pub const reported_nodejs_version = "0.0.0";
pub const baseline = false;
pub const sha = "dev";
pub const is_canary = false;
pub const canary_revision = "0";
pub const base_path = ".";
pub const enable_logs = true;
pub const enable_asan = false;
pub const codegen_path = ".";
pub const codegen_embed = false;
pub const version = std.SemanticVersion{ .major = 0, .minor = 1, .patch = 0 };
