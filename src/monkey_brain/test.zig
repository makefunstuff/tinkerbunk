pub const perceptron = @import("perceptron.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
