const std = @import("std");
const ls = @import("ls.zig");
const socket_server = @import("socket-server.zig");
const sdl_window = @import("sdl-window.zig");

const commands = [_]u8{ "ls", "tcp", "window", "brr" };
const Command = enum {
    LS,
    TCP,
    WINDOW,
    BRR,
};

const Arg = struct {
    const Self = @This();

    name: []const u8,
    command: Command,

    fn parse(self: *Self) void {
        inline for (commands) |command| {
            if (std.mem.eql([]u8, command, self.name)) {}
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

    if (args.len == 2) {}

    std.debug.print("Unknown command. Use 'help' for usage information.\n", .{});
    print_help();
}

fn arg_is(arg: []const u8, target: []const u8) bool {
    return std.mem.eql(u8, arg, target);
}

fn print_help() void {
    std.debug.print("[usage] tinkerbunk ls\n", .{});
}
