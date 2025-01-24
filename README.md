## Run

*Tested only on macOS*

`git clone --recursive` this repository.

In the root directory `mkdir bin`.

Build the libraries in `libs/sokol-odin/sokol` using the provided shell scripts.

Run `run.sh` from the root directory. Uses the linker flag `-linker:lld`.

## Attribution

All sample code (ported to Odin), images and shaders have been taken from https://github.com/edubart/sokol_gp.
