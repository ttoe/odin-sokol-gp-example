sokol-shdc --input shaders/sample-effect.glsl --output src/sample-effect/sample-effect.glsl.odin --slang glsl430:hlsl5:metal_macos --format sokol_odin
sokol-shdc --input shaders/sample-sdf.glsl --output src/sample-sdf/sample-sdf.glsl.odin --slang glsl430:hlsl5:metal_macos --format sokol_odin

odin build src/sample-rectangle -out:bin/sample-rectangle -use-separate-modules -show-timings -o:speed -linker:lld
odin build src/sample-effect -out:bin/sample-effect -use-separate-modules -show-timings -o:speed -linker:lld
