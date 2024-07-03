const std = @import("std");
const c = @cImport({
    @cInclude("mpg123.h");
    @cInclude("alsa/asoundlib.h");
});

pub fn brr(file: []const u8) void {
    _ = c.mpg123_init();

    const handle = c.mpg123_new(null, null) orelse {
        std.log.warn("Failed to create mpg123 handle\n", .{});
        return;
    };
    defer c.mpg123_delete(handle);

    const file_path = file.ptr;
    if (c.mpg123_open(handle, file_path) != 0) {
        std.log.warn("Filed to open the file: {}\n", .{file_path});
        return;
    }

    var pcm: c.snd_pcm_t = undefined;
    if (c.snd_pcm_open(&pcm, "default", c.SND_PCM_STREAM_PLAYBACK, 0) < 0) {
        std.log.warn("Failed to open ALSA device\n", .{});
        return;
    }
    defer c.snd_pcm_close(pcm);

    var params: *c.snd_pcm_hw_params_t = undefined;
    c.snd_pcm_hw_params_malloc(&params);
    defer c.snd_pcm_hw_params_free(params);

    c.snd_pcm_hw_params(pcm, params);
    c.snd_pcm_hw_params_set_access(pcm, params, c.SND_PCM_FORMAT_S16_LE);
    c.snd_pcm_hw_params_set_channels(pcm, params, 2);
    c.snd_pcm_hw_params_set_rate(pcm, params, 44100, 0);

    c.snd_pcm_hw_params(pcm, params);

    var buffer: [4096]u8 = undefined;

    while (true) {
        var done: c.size_t = 0;
        c.mpg123_read(handle, &buffer[0], buffer.len, &done);

        if (done == 0) break;

        c.snd_pcm_writei(pcm, &buffer[0], done / 4);
    }
}
