const std = @import("std");
const testing = std.testing;
pub const perceptron = @import("perceptron.zig");
pub const neuron = @import("neural_network/neuron.zig");

test {
    testing.refAllDeclsRecursive(@This());
}
