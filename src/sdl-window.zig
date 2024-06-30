const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub fn present_sdl_window() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Window is not initialized: %s", c.SDL_GetError());
    }
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow("Aken", c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, 800, 600, c.SDL_WINDOW_OPENGL) orelse {
        c.SDL_Log("Window create error, reason: %s", c.SDL_GetError());
        return error.SDLWindowInitError;
    };
    defer c.SDL_DestroyWindow(window);

    const renderer = c.SDL_CreateRenderer(window, -1, 0) orelse {
        c.SDL_Log("Renderer create error, reason: %s", c.SDL_GetError());
        return error.SDLRendererInitError;
    };
    defer c.SDL_DestroyRenderer(renderer);

    while (true) {
        _ = c.SDL_RenderClear(renderer);
        c.SDL_RenderPresent(renderer);
    }
}
