const std = @import("std");
const ls = @import("ls.zig");
const socket_server = @import("socket-server.zig");
const sdl_window = @import("sdl-window.zig");

const commands = [_]struct {
    name: []const u8,
    command: Command,
}{
    .{ .name = "ls", .command = Command.LS },
    .{ .name = "tcp", .command = Command.TCP },
    .{ .name = "window", .command = Command.WINDOW },
    .{ .name = "brr", .command = Command.BRR },
};

const Command = enum {
    LS,
    TCP,
    WINDOW,
    BRR,
};

const Arg = struct {
    const Self = @This();

    name: []const u8,
    command: Command = undefined,

    fn parse(self: *Self) !void {
        inline for (commands) |cmd| {
            if (std.mem.eql(u8, cmd.name, self.name)) {
                self.command = cmd.command;
            }
        }
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len == 1) {
        std.debug.print("No command provided. Use 'help' for usage information.\n", .{});
        return;
    }

    if (args.len == 2) {
        var argument = Arg{
            .name = args[1],
        };
        try argument.parse();
        switch (argument.command) {
            .LS => try ls.ls(),
            .TCP => try socket_server.start_server(),
            .WINDOW => try sdl_window.present_sdl_window(),
            else => {
                return;
            },
        }
    }

    std.debug.print("Unknown command. Use 'help' for usage information.\n", .{});
    print_help();
}

fn arg_is(arg: []const u8, target: []const u8) bool {
    return std.mem.eql(u8, arg, target);
}

fn print_help() void {
    std.debug.print("[usage] tinkerbunk ls\n", .{});
}
