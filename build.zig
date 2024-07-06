const std = @import("std");

fn tinkerbunk_config(b: *std.Build, target: std.Resolved, optimize: std.builtin.OtimizeMode) void {
    const exe = b.addExecutable(.{
        .name = "tinkerbunk",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.linkSystemLibrary("SDL2");

    if (target.query.os_tag == .linux) {
        exe.linkSystemLibrary("mpg123");
        exe.linkSystemLibrary("asound");
        exe.addCSourceFile(.{ .file = b.path("csrc/cbrr.c"), .flags = &.{} });
        exe.addIncludePath(b.path("./csrc"));
    }

    exe.linkLibC();

    if (target.query.eql(.{ .os_tag = .macos, .cpu_arch = .aarch64 })) {
        exe.addLibraryPath(.{ .cwd_relative = "/opt/homebrew/lib" });
        exe.addSystemIncludePath(.{ .cwd_relative = "/opt/homebrew/include" });
        exe.linkSystemLibrary("mp3lame");
    }
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
        .root_source_file = b.path("src/lame.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.addCSourceFile(.{ .file = b.path("csrc/lame.c"), .flags = &.{} });
    exe.addIncludePath(b.path("./csrc"));

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const c_program = b.addExecutable(.{
        .name = "lamedecoder",
        .target = target,
        .optimize = optimize,
    });

    c_program.addCSourceFile(.{ .file = b.path("csrc/main.c") });
    c_program.addCSourceFile(.{ .file = b.path("csrc/lame.c") });

    c_program.addLibraryPath(.{ .cwd_relative = "/opt/homebrew/lib" });
    c_program.addSystemIncludePath(.{ .cwd_relative = "/opt/homebrew/include" });
    c_program.linkSystemLibrary("mp3lame");
    b.installArtifact(c_program);
    const c_program_run_step = b.step("run_c", "Run the app");
    c_program_run_step.dependOn(b.getInstallStep());
}
