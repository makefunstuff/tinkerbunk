const std = @import("std");
const File = std.fs.File;

const c = @cImport({
    @cInclude("csrc/lame.h");
});

const decodeErrors = error{
    LameInitFailed,
};

pub fn init_lame(filepath: [*:0]const u8) !void {
    _ = c.lame_decode(filepath);
}

test "init_lame" {
    try init_lame("static/sample.mp3");
}
