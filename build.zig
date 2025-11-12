const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const bun_module = b.createModule(.{
        .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = "bridge/src/bun.zig" } },
        .target = target,
        .optimize = optimize,
    });

    const bridge_module = b.createModule(.{
        .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = "bridge/src/lib.zig" } },
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "bun", .module = bun_module }},
    });

    const bridge_lib = b.addLibrary(.{
        .name = "bridge",
        .root_module = bridge_module,
        .linkage = .static,
    });
    b.installArtifact(bridge_lib);

    const bridge_tests = b.addTest(.{
        .name = "bridge-tests",
        .root_module = b.createModule(.{
            .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = "bridge/tests/smoke.zig" } },
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "bridge", .module = bridge_module }},
        }),
    });

    const run_tests = b.addRunArtifact(bridge_tests);
    const test_step = b.step("test", "Run bridge test suite");
    test_step.dependOn(&run_tests.step);
}
