const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub fn present_sdl_window() !void {
    const WINDOW_WIDTH: u32 = 800;
    const WINDOW_HEIGHT: u32 = 600;

    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Window is not initialized: %s", c.SDL_GetError());
    }
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow("Aken", c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, WINDOW_WIDTH, WINDOW_HEIGHT, c.SDL_WINDOW_OPENGL) orelse {
        c.SDL_Log("Window create error, reason: %s", c.SDL_GetError());
        return error.SDLWindowInitError;
    };
    defer c.SDL_DestroyWindow(window);

    const renderer = c.SDL_CreateRenderer(window, -1, 0) orelse {
        c.SDL_Log("Renderer create error, reason: %s", c.SDL_GetError());
        return error.SDLRendererInitError;
    };
    defer c.SDL_DestroyRenderer(renderer);

    const rect_height = 100;
    const rect_width = 100;

    const rect_x = WINDOW_WIDTH / 2 - rect_width / 2;
    const rect_y = WINDOW_HEIGHT / 2 - rect_height / 2;

    const rect = c.SDL_Rect{ .x = rect_x, .y = rect_y, .w = rect_width, .h = rect_height };

    var quit = false;
    while (!quit) {
        var event: c.SDL_Event = undefined;

        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    quit = true;
                },
                else => {},
            }
        }
        const bg_color = c.SDL_Color{ .r = 255, .g = 255, .b = 255, .a = 255 };
        _ = c.SDL_SetRenderDrawColor(renderer, bg_color.r, bg_color.g, bg_color.b, bg_color.a);

        _ = c.SDL_RenderClear(renderer);

        const rect_color = c.SDL_Color{ .r = 0, .g = 0, .b = 255, .a = 255 };
        _ = c.SDL_SetRenderDrawColor(renderer, rect_color.r, rect_color.g, rect_color.b, rect_color.a);

        _ = c.SDL_RenderFillRect(renderer, &rect);
        _ = c.SDL_RenderPresent(renderer);
    }
}
