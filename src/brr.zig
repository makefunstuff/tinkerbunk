const std = @import("std");
const c = @cImport({
    @cInclude("mpg123.h");
    @cInclude("alsa/asoundlib.h");
});

pub fn brr(allocator: std.mem.Allocator, file: []const u8) !void {
    _ = c.mpg123_init();

    const handle = c.mpg123_new(null, null) orelse {
        std.log.warn("Failed to create mpg123 handle\n", .{});
        return;
    };

    const buffer_size = c.mpg123_outblock(handle);

    const file_path: [*c]const u8 = @ptrCast(file);
    if (c.mpg123_open(handle, file_path) != c.MPG123_OK) {
        std.log.warn("Failed to open the file: {s}\n", .{file_path});
        return;
    }

    var pcm: ?*c.snd_pcm_t = undefined;
    if (c.snd_pcm_open(&pcm, "default", c.SND_PCM_STREAM_PLAYBACK, 0) < 0) {
        std.log.warn("Failed to open ALSA device\n", .{});
        return;
    }

    var encoding: c_int = 0;
    var channels: c_int = 0;
    var rate: c_long = 0;

    if (c.mpg123_getformat(handle, &rate, &channels, &encoding) != c.MPG123_OK) {
        std.log.warn("Failed to get format\n", .{});
        return;
    }

    var params: ?*c.snd_pcm_hw_params_t = null;
    if (c.snd_pcm_hw_params_malloc(&params) < 0) {
        std.log.warn("Failed to allocate ALSA hardware parameters\n", .{});
        return;
    }
    _ = c.snd_pcm_hw_params_any(pcm, params);
    _ = c.snd_pcm_hw_params(pcm, params);
    _ = c.snd_pcm_hw_params_set_access(pcm, params, c.SND_PCM_ACCESS_RW_INTERLEAVED);
    _ = c.snd_pcm_hw_params_set_format(pcm, params, c.SND_PCM_FORMAT_S16_LE);
    _ = c.snd_pcm_hw_params_set_channels(pcm, params, @as(c_uint, @intCast(channels)));
    _ = c.snd_pcm_hw_params_set_rate(pcm, params, @as(c_uint, @intCast(rate)), 0);
    _ = c.snd_pcm_hw_params(pcm, params);

    var done: usize = 0;
    var buffer: []u8 = try allocator.alloc(u8, buffer_size);
    defer allocator.free(buffer);

    const buffer_ptr = @as([*c]u8, @ptrCast(&buffer[0]));

    while (c.mpg123_read(handle, buffer_ptr, buffer_size, &done) == c.MPG123_OK) {
        const frames = @divExact(@as(c_ulong, @intCast(done)), @as(c_ulong, @intCast(channels * 2)));
        std.log.debug("Starting sending", .{});
        const write_state = c.snd_pcm_writei(pcm, buffer_ptr, @as(c_ulong, frames));
        std.log.info("Written pcm frames {}", .{write_state});
    }
    _ = c.mpg123_delete(handle);
    _ = c.snd_pcm_hw_params_free(params);
    _ = c.snd_pcm_close(pcm);
    _ = c.mpg123_exit();
}
