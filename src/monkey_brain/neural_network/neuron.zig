const std = @import("std");
const math = std.math;
const Random = std.Random;
const ArrayList = std.ArrayList;
const testing = std.testing;

pub const Neuron = struct {
    weights: ArrayList(f64),
    bias: f64,

    pub fn init(allocator: std.mem.Allocator, num_inputs: usize) !Neuron {
        var weights = ArrayList(f64).init(allocator);
        var prng = Random.DefaultPrng.init(blk: {
            const seed: u64 = @intCast(std.time.milliTimestamp());
            break :blk seed;
        });

        var random = prng.random();
        var i: usize = 0;

        while (i < num_inputs) : (i += 1) {
            try weights.append(random.float(f64) * 2 - 1);
        }

        return Neuron{
            .weights = weights,
            .bias = random.float(f64) * 2 - 1,
        };
    }

    pub fn deinit(self: *Neuron) void {
        self.weights.deinit();
    }

    pub fn activate(self: *const Neuron, inputs: []const f64) f64 {
        var sum: f64 = self.bias;
        for (self.weights.items, 0..) |weight, i| {
            sum += inputs[i] * weight;
        }
        return sigmoid(sum);
    }
};

fn sigmoid(x: f64) f64 {
    return 1.0 / (1.0 + math.exp(-x));
}

test "Neuron initialization" {
    const allocator = testing.allocator;
    var neuron = try Neuron.init(allocator, 2);
    defer neuron.deinit();

    std.debug.print("Testing neuron", .{});
    try testing.expect(neuron.weights.items.len == 2);
    try testing.expect(neuron.bias >= -1 and neuron.bias <= 1);
}
