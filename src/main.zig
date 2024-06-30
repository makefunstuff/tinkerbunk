const std = @import("std");
const ls = @import("ls.zig");
const socket_server = @import("socket-server.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len == 2 and std.mem.eql(u8, args[1], "help")) {
        print_help();
        return;
    }
    if (args.len == 2 and std.mem.eql(u8, args[1], "ls")) {
        try ls.ls();
        return;
    }

    if (args.len == 2 and std.mem.eql(u8, args[1], "tcp-foo")) {
        try socket_server.start_server();
    }

    std.debug.print("Unknown command. Use 'help' for usage information.\n", .{});
    print_help();
}

fn print_help() void {
    std.debug.print("[usage] tinkerbunk ls\n", .{});
}
