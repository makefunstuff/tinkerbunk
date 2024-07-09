const std = @import("std");
const testing = std.testing;
const math = std.math;

const LinearRegression = struct {
    const Self = @This();

    weight: f64,
    bias: f64,

    fn init() LinearRegression {
        return Self{ .weight = 0.0, .bias = 0.0 };
    }

    fn predict(self: Self, x: f64) f64 {
        return self.weight * x + self.bias;
    }

    fn train(self: *LinearRegression, x: []const f64, y: []const f64, learning_rate: f64, epochs: usize) void {
        const n: f64 = @floatFromInt(x.len);

        for (0..epochs) |epoch| {
            var total_error: f64 = 0;

            for (x, y) |xi, yi| {
                const prediction = self.predict(xi);
                const err = prediction - yi;

                self.weight -= learning_rate * err * xi;
                self.bias -= learning_rate * err;

                total_error += err * err;
            }

            const current_mse = total_error / n;

            if (epoch % 1000 == 0 or epoch == epochs - 1) {
                std.debug.print("Epoch {d}: MSE = {d:.6}\n", .{ epoch, current_mse });
            }
        }
    }

    // https://en.wikipedia.org/wiki/Mean_squared_error
    fn loss_function(self: Self, x: []const f64, y: []const f64) f64 {
        var squared_sum: f64 = 0.0;
        for (x, y) |xi, yi| {
            const predicted = self.predict(xi);
            const err = predicted - yi;
            squared_sum += err * err;
        }
        const n: f64 = @floatFromInt(x.len);
        return squared_sum / n;
    }
};

test "Linear Regression" {
    // Initialize the model
    var model = LinearRegression.init();

    const x = [_]f64{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const y = [_]f64{ 3.1, 4.9, 7.2, 9.1, 11.0, 12.8, 14.9, 17.2, 18.8, 21.1 };

    const learning_rate: f64 = 0.01;
    const epochs: usize = 1000;
    model.train(&x, &y, learning_rate, epochs);

    try testing.expect(@abs(model.weight - 2.0) < 0.1);
    try testing.expect(@abs(model.bias - 1.0) < 0.1);

    const test_x = [_]f64{ 0, 5, 10 };
    const expected_y = [_]f64{ 1, 11, 21 };
    for (test_x, expected_y) |xi, yi| {
        const prediction = model.predict(xi);
        try testing.expect(@abs(prediction - yi) < 0.5);
    }

    const mse = model.loss_function(&x, &y);
    try testing.expect(mse < 0.1);

    const new_x = [_]f64{ 11, 12, 13 };
    const new_y = [_]f64{ 23.1, 24.9, 27.2 };
    const new_mse = model.loss_function(&new_x, &new_y);
    try testing.expect(new_mse < 0.2);

    std.debug.print("\nTrained model: y = {d:.4}x + {d:.4}\n", .{ model.weight, model.bias });
    std.debug.print("Mean Squared Error on training data: {d:.4}\n", .{mse});
    std.debug.print("Mean Squared Error on new data: {d:.4}\n", .{new_mse});
}
