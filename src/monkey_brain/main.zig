const std = @import("std");
const testing = std.testing;

const input_size: usize = 2;
const training_set_size: usize = 4;
const learning_rate: f64 = 0.1;
const epochs: u64 = 100 * 1000;

fn sigmoid(x: f64) f64 {
    return 1.0 / (1.0 + std.math.exp(-x));
}

fn sigmoid_derivative(output: f64) f64 {
    return output * (1.0 - output);
}

fn predict(weights: [input_size]f64, bias: f64, inputs: [input_size]f64) f64 {
    var total: f64 = 0.0;
    for (0..input_size) |i| {
        total += weights[i] * inputs[i];
    }
    total += bias;
    return sigmoid(total);
}

fn train(weights: *[input_size]f64, bias: *f64, training_data: [training_set_size][input_size]f64, labels: [training_set_size]f64) void {
    for (0..epochs) |_| {
        for (0..training_set_size) |i| {
            const prediction = predict(weights.*, bias.*, training_data[i]);
            const err = labels[i] - prediction;
            const adjustment = err * sigmoid_derivative(prediction);

            for (0..input_size) |j| {
                weights[j] += learning_rate * adjustment * training_data[i][j];
            }
            bias.* += learning_rate * adjustment;
        }
    }
}

pub fn main() !void {
    const w1 = std.crypto.random.float(f64);
    const w2 = std.crypto.random.float(f64);

    var weights: [input_size]f64 = .{ w1, w2 };
    var bias: f64 = 0.0;

    const training_data: [training_set_size][input_size]f64 = .{ .{ 0, 0 }, .{ 0, 1 }, .{ 1, 0 }, .{ 1, 1 } };

    const labels: [training_set_size]f64 = .{ 0, 0, 0, 1 };

    train(&weights, &bias, training_data, labels);

    for (0..training_set_size) |i| {
        const prediction = predict(weights, bias, training_data[i]);
        std.log.info("Input {} {}, Predicted output: {}", .{ training_data[i][0], training_data[i][1], prediction });
    }
}

test "hello" {
    try testing.expect(true);
}
