const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "tinkerbunk",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.linkSystemLibrary("SDL2");
    exe.linkSystemLibrary("mpg123");
    exe.linkSystemLibrary("asound");
    exe.linkLibC();
    exe.addCSourceFile(.{ .file = b.path("csrc/cbrr.c"), .flags = &.{} });
    exe.addIncludePath(b.path("./csrc"));

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);

    // monkey brains
    const monkey_brain = b.addExecutable(.{
        .name = "monkey_brain",
        .root_source_file = b.path("src/monkey_brain/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(monkey_brain);

    const monkey_brain_run = b.addRunArtifact(monkey_brain);
    monkey_brain_run.step.dependOn(b.getInstallStep());

    const monkey_run_step = b.step("monkey_run", "Run the monkey brain");
    monkey_run_step.dependOn(&monkey_brain_run.step);

    const monkey_test_exec = b.addTest(.{ .root_source_file = b.path("src/monkey_brain/test.zig"), .target = target, .optimize = optimize });

    const monkey_test_run = b.addRunArtifact(monkey_test_exec);
    const monkey_test_step = b.step("monkey_test", "Run monkey brain cells test");
    monkey_test_step.dependOn(&monkey_test_run.step);
}
