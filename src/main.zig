const std = @import("std");
const ls = @import("ls.zig");
const socket_server = @import("socket-server.zig");
const sdl_window = @import("sdl-window.zig");
const brr = @import("brr.zig");

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

    if (args.len == 3) {
        if (std.mem.eql(u8, args[1], "brr")) {
            try brr.brr(std.heap.c_allocator, args[2]);
            return;
        }
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

fn print_help() void {
    std.debug.print("[usage] tinkerbunk ls\n", .{});
}
