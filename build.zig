const std = @import("std");

fn define_subproj(name: []const u8, b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !void {
    const exe_path = try std.fmt.allocPrint(b.allocator, "src/{s}/main.zig", .{name});
    const test_path = try std.fmt.allocPrint(b.allocator, "src/{s}/test.zig", .{name});
    const run_task_name = try std.fmt.allocPrint(b.allocator, "run_{s}", .{name});
    const run_task_desc = try std.fmt.allocPrint(b.allocator, "Run {s}", .{name});
    const test_task_name = try std.fmt.allocPrint(b.allocator, "test_{s}", .{name});
    const test_task_desc = try std.fmt.allocPrint(b.allocator, "Run tests for {s}", .{name});

    const exe = b.addExecutable(.{
        .name = name,
        .root_source_file = b.path(exe_path),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step(run_task_name, run_task_desc);
    run_step.dependOn(&run_cmd.step);

    const test_exe = b.addTest(.{ .root_source_file = b.path(test_path), .target = target, .optimize = optimize });
    const run_unit_tests = b.addRunArtifact(test_exe);
    const test_step = b.step(test_task_name, test_task_desc);
    test_step.dependOn(&run_unit_tests.step);
}

pub fn build(b: *std.Build) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    if (target.query.os_tag == .linux) {
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
    }

    try define_subproj("monkey_brain", b, target, optimize);
    try define_subproj("monkey_learns", b, target, optimize);

    const cprog = b.addExecutable(.{ .name = "cprog", .target = target, .optimize = optimize });
    cprog.linkLibC();
    cprog.addCSourceFiles(.{ .files = &.{ "csrc/cp.c", "csrc/main.c", "csrc/wc.c", "csrc/sh.c", "csrc/stat.c", "csrc/http.c" }, .flags = &.{} });
    b.installArtifact(cprog);

    const run_c_cmd = b.addRunArtifact(cprog);
    run_c_cmd.step.dependOn(b.getInstallStep());
    const runc_step = b.step("runc", "Run c prog");
    runc_step.dependOn(&run_c_cmd.step);
}
