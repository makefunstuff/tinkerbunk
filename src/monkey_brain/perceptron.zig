const std = @import("std");
const testing = std.testing;
const math = std.math;

const input_size: usize = 2;
const training_set_size: usize = 4;
const learning_rate: f64 = 0.1;
const epochs: u64 = 10000;

// https://en.wikipedia.org/wiki/Sigmoid_function - more details
// https://www.youtube.com/watch?v=TPqr8t919YM
fn sigmoid(x: f64) f64 {
    return 1.0 / (1.0 + math.exp(-x));
}

fn sigmoid_derivative(output: f64) f64 {
    return output * (1.0 - output);
}

fn predict(weights: [input_size]f64, bias: f64, inputs: [input_size]f64) f64 {
    var total: f64 = bias;
    for (inputs, 0..) |input, i| {
        total += weights[i] * input;
    }
    return sigmoid(total);
}

fn train(weights: *[input_size]f64, bias: *f64, training_data: [training_set_size][input_size]f64, labels: [training_set_size]f64) void {
    for (0..epochs) |_| {
        for (training_data, labels) |inputs, label| {
            const prediction = predict(weights.*, bias.*, inputs);
            const err = label - prediction;
            const adjustment = err * sigmoid_derivative(prediction);
            for (inputs, 0..) |input, j| {
                weights[j] += learning_rate * adjustment * input;
            }
            bias.* += learning_rate * adjustment;
        }
    }
}

pub fn demo() !void {
    var weights = [_]f64{ std.crypto.random.float(f64) * 2 - 1, std.crypto.random.float(f64) * 2 - 1 };
    var bias: f64 = std.crypto.random.float(f64) * 2 - 1;

    const training_data = [_][input_size]f64{
        .{ 0, 0 },
        .{ 0, 1 },
        .{ 1, 0 },
        .{ 1, 1 },
    };
    const labels = [_]f64{ 0, 1, 1, 1 }; // OR operation

    train(&weights, &bias, training_data, labels);

    std.debug.print("Trained weights: {d}, {d}\n", .{ weights[0], weights[1] });
    std.debug.print("Trained bias: {d}\n", .{bias});

    for (training_data, labels) |inputs, expected| {
        const prediction = predict(weights, bias, inputs);
        std.debug.print("Input: {d}, {d}, Predicted: {d:.4}, Expected: {d}\n", .{ inputs[0], inputs[1], prediction, expected });
    }
}

test "OR gate" {
    var weights = [_]f64{ 0.3, 0.2 };
    var bias: f64 = 0.5;

    const training_data = [_][input_size]f64{
        .{ 0, 0 },
        .{ 0, 1 },
        .{ 1, 0 },
        .{ 1, 1 },
    };
    const labels = [_]f64{ 0, 1, 1, 1 };

    train(&weights, &bias, training_data, labels);

    for (training_data, labels) |inputs, expected| {
        const prediction = predict(weights, bias, inputs);
        const predicted_error = prediction - expected;
        std.debug.print("Predicted error {}\n", .{predicted_error});
        std.debug.print("Predicted: {} | Expected: {}\n", .{ prediction, expected });

        try testing.expect(predicted_error < 0.1);
    }
}
