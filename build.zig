const std = @import("std");

const raylibFlags = &[_][]const u8{
    "-std=gnu99",
    "-DGRAPHICS_API_OPENGL_ES2",
    "-DPLATFORM_WEB",
    "-DGL_SILENCE_DEPRECATION",
    "-fno-sanitize=undefined", // https://github.com/raysan5/raylib/issues/1891
};

pub fn build(b: *std.build.Builder) !void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("raylib", "stuff.zig");
    lib.output_dir = "./src";
    lib.setTarget(.{
        .cpu_arch = .wasm32,
        .os_tag = .wasi,
        .abi = .musl,
    });
    lib.linkLibC();
    lib.setBuildMode(mode);
    lib.addIncludeDir("./src");
    lib.addIncludeDir("/usr/lib/emscripten/system/include/"); // for e.g. GLES2/gl2.h
    lib.addCSourceFile("./src/core.c", raylibFlags);
    lib.addCSourceFile("./src/models.c", raylibFlags);
    //lib.addCSourceFile("./src/raudio.c", raylibFlags); miniaudio.h:10423:31: warning: implicit declaration of function 'sched_get_priority_max'
    lib.addCSourceFile("./src/shapes.c", raylibFlags);
    lib.addCSourceFile("./src/text.c", raylibFlags);
    lib.addCSourceFile("./src/textures.c", raylibFlags);
    lib.addCSourceFile("./src/utils.c", raylibFlags);

    lib.install();

    const proc = try std.ChildProcess.init(
        &[_][]const u8{
            "emcc",
            "-o",
            "examples/core/core_basic_window_web.html",
            "examples/core/core_basic_window_web.c",
            "-Wall",
            "-std=c99",
            "-D_DEFAULT_SOURCE",
            "-Os",
            "-s",
            "USE_GLFW=3",
            "-s",
            "TOTAL_MEMORY=67108864",
            "-s",
            "FORCE_FILESYSTEM=1",
            "--preload-file",
            "examples/core/resources@resources",
            "--shell-file",
            "src/shell.html",
            "-Isrc",
            "-Isrc/external",
            "-Isrc/extras",
            "src/libraylib.a",
            "-DPLATFORM_WEB",
        },
        b.allocator,
    );

    switch (try proc.spawnAndWait()) {
        .Exited => |code| if (code != 0) return error.ShellError,
        else => return error.ShellError,
    }
}
