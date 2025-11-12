const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const bun_module = b.createModule(.{
        .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = "../src/bun.zig" } },
    });

    const bridge_module = b.createModule(.{
        .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = "src/lib.zig" } },
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "bun", .module = bun_module }},
    });

    const smoke_module = b.createModule(.{
        .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = "tests/smoke.zig" } },
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "bridge", .module = bridge_module }},
    });

    const smoke = b.addTest(.{
        .name = "bridge-smoke",
        .root_module = smoke_module,
    });

    const run_smoke = b.addRunArtifact(smoke);
    b.step("smoke", "Run bridge smoke tests").dependOn(&run_smoke.step);
}
