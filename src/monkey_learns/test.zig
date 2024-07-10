const std = @import("std");
const testing = std.testing;
pub const linear_regression = @import("linear_regression.zig");

test {
    testing.refAllDeclsRecursive(@This());
}
