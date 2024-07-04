const std = @import("std");
const c = @cImport({
    @cInclude("mpg123.h");
    @cInclude("alsa/asoundlib.h");
});

const _op_snd_pcm_info_t = opaque {};
const snd_pcm_info_t = ?*_op_snd_pcm_info_t;

pub fn brr(file: []const u8) !void {
    _ = c.mpg123_init();

    const handle = c.mpg123_new(null, null) orelse {
        std.log.warn("Failed to create mpg123 handle\n", .{});
        return;
    };

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

    var params: ?*c.snd_pcm_hw_params_t = null;
    _ = c.snd_pcm_hw_params_malloc(&params);

    var encoding: c_int = 0;
    var channels: c_int = 0;
    var rate: c_long = 0;

    if (c.mpg123_getformat(handle, &rate, &channels, &encoding) != c.MPG123_OK) {
        std.log.warn("Failed to get format\n", .{});
        return;
    }

    _ = c.snd_pcm_hw_params(pcm, params);
    _ = c.snd_pcm_hw_params_set_access(pcm, params, c.SND_PCM_ACCESS_RW_INTERLEAVED);
    _ = c.snd_pcm_hw_params_set_access(pcm, params, c.SND_PCM_FORMAT_S16_LE);
    _ = c.snd_pcm_hw_params_set_channels(pcm, params, @intCast(channels));
    _ = c.snd_pcm_hw_params_set_rate(pcm, params, @intCast(rate), 0);

    _ = c.snd_pcm_hw_params(pcm, params);

    var buffer: [4096]u8 = undefined;

    while (true) {
        var done: usize = 0;
        const result = c.mpg123_read(handle, &buffer[0], buffer.len, &done);
        switch (result) {
            c.MPG123_OK => {},
            c.MPG123_DONE => {
                std.log.info("Done reading", .{});
            },
            else => {
                const plain_error = c.mpg123_plain_strerror(result);
                std.log.err("Decode error {s}", .{plain_error});
            },
        }

        if (done == 0) {
            break;
        }

        const frames_sent = c.snd_pcm_writei(pcm, &buffer[0], done / 4);
        if (frames_sent < 0) {
            std.log.err("Failed to write to ALSA device", .{});
            var pcm_info: snd_pcm_info_t = undefined;
            const alloc_result = c.snd_pcm_info_malloc(@ptrCast(&pcm_info));
            if (alloc_result == 0) {
                std.log.err("Failed to allocate pcm info", .{});
                return;
            }
            _ = c.snd_pcm_info(pcm, @ptrCast(&pcm_info));

            std.log.debug("pcm_info {?}", .{pcm_info});
            defer c.snd_pcm_info_free(@ptrCast(&pcm_info));
            return;
        } else {
            std.log.info("Frames sent: {d}", .{frames_sent});
        }
    }
    _ = c.mpg123_delete(handle);
    _ = c.snd_pcm_hw_params_free(params);
    _ = c.snd_pcm_close(pcm);
    _ = c.mpg123_exit();
}
