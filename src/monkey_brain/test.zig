pub const main = @import("main.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
