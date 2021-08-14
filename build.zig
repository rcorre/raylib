const std = @import("std");

const raylibFlags = &[_][]const u8{
    "-std=gnu99",
    "-DGRAPHICS_API_OPENGL_ES2",
    "-DPLATFORM_WEB",
    "-DGL_SILENCE_DEPRECATION",
    "-fno-sanitize=undefined", // https://github.com/raysan5/raylib/issues/1891
};

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("raylib", null);
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
}
