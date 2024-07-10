const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const SCREEN_WIDTH = 640;
const SCREEN_HEIGHT = 480;

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Video init error: %s", c.SDL_GetError());
    }
}
