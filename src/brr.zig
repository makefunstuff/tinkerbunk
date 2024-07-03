const std = @import("std");
const c = @cImport({
    @cInclude("mpg123.h");
    @cInclude("alsa/asoundlib.h");
});

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

    _ = c.snd_pcm_hw_params(pcm, params);
    _ = c.snd_pcm_hw_params_set_access(pcm, params, c.SND_PCM_FORMAT_S16_LE);
    _ = c.snd_pcm_hw_params_set_channels(pcm, params, 2);
    _ = c.snd_pcm_hw_params_set_rate(pcm, params, 44100, 0);

    _ = c.snd_pcm_hw_params(pcm, params);

    var buffer: [4096]u8 = undefined;

    while (true) {
        var done: usize = 0;
        const result = c.mpg123_read(handle, &buffer[0], buffer.len, &done);
        switch (result) {
            c.MPG123_OK => {
                std.log.info("Reading successfule", .{});
            },
            else => {
                std.log.err("Decode error {}", .{result});
            },
        }

        if (done == 0) {
            _ = c.mpg123_delete(handle);
            _ = c.snd_pcm_hw_params_free(params);
            _ = c.snd_pcm_close(pcm);
            break;
        }

        _ = c.snd_pcm_writei(pcm, &buffer[0], done / 4);
    }
}
