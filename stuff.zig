usingnamespace @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
});

export fn UpdateDrawZig() void {
    BeginDrawing();

    DrawRectangle(0, 50, 50, 50, GRAY);

    //DrawText("Congrats! You created your first windowwww!", 190, 200, 20, LIGHTGRAY);

    EndDrawing();
    //----------------------------------------------------------------------------------
}
