const std = @import("std");

pub fn ls() !void {
    const dir = try std.fs.cwd().openDir(".", .{ .iterate = true });

    var iterator = dir.iterate();

    while (try iterator.next()) |entry| {
        const name = entry.name;
        std.debug.print("{s}\n", .{name});
    }
}
