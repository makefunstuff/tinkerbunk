const std = @import("std");
const print = std.debug.print;
const net = std.net;

pub fn start_server() !void {
    print("Starting server\n", .{});

    const ip = [_]u8{ 127, 0, 0, 1 };
    const port = 9000;

    const addr = net.Address.initIp4(ip, port);

    var server = try net.Address.listen(addr, .{});
    print("Listening at {}\n", .{server.listen_address});
    defer server.deinit();

    while (true) {
        var connection = try server.accept();
        _ = try connection.stream.write("Hello, client\n");
        defer connection.stream.close();
    }
}
