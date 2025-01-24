## Dependencies

- Sokol shader compiler: https://github.com/floooh/sokol-tools
- Linker: lld. However, the linker flag in `build_all.sh` can also be removed.

## Run

*Tested only on macOS*

`git clone --recursive` this repository.

In the root directory `mkdir bin`.

Build the libraries for your OS in `libs/sokol-odin/sokol` using the provided shell scripts.

Run `build_all.sh` from the root directory.

Run an executable from the `bin` directory.

## Attribution

All sample code, images and shaders have been taken from the examples in https://github.com/edubart/sokol_gp.
