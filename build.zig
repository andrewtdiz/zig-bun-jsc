const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const jsc_module = b.addModule("jsc", .{
        .root_source_file = b.path("src/bun.js/jsc.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const bun_module = b.addModule("bun", .{
        .root_source_file = b.path("bridge/src/bun.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    bun_module.addImport("jsc", jsc_module);

    const bridge_module = b.addModule("bridge", .{
        .root_source_file = b.path("bridge/src/lib.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    bridge_module.addImport("bun", bun_module);

    const bridge_lib = b.addLibrary(.{
        .name = "bridge",
        .root_module = bridge_module,
        .linkage = .static,
    });
    b.installArtifact(bridge_lib);

    const bridge_tests_module = b.createModule(.{
        .root_source_file = b.path("bridge/tests/smoke.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    bridge_tests_module.addImport("bridge", bridge_module);

    const bridge_tests = b.addTest(.{
        .name = "bridge-tests",
        .root_module = bridge_tests_module,
    });

    const run_tests = b.addRunArtifact(bridge_tests);
    const test_step = b.step("test", "Run bridge test suite");
    test_step.dependOn(&run_tests.step);
}
