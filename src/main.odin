/*
 * Example taken from the sokol_gp README and ported to Odin:
 * https://github.com/edubart/sokol_gp/tree/master?tab=readme-ov-file#quick-usage-example
 */
package main

import sapp "../libs/sokol-odin/sokol/app"
import sg "../libs/sokol-odin/sokol/gfx"
import sglue "../libs/sokol-odin/sokol/glue"
import sgp "../libs/sokol-odin/sokol/gp"
import slog "../libs/sokol-odin/sokol/log"
import "core:math"

frame :: proc "c" () {
	width := sapp.width()
	height := sapp.height()

	ratio := f32(width) / f32(height)

	sgp.begin(width, height)
	sgp.viewport(0, 0, width, height)
	sgp.project(-ratio, ratio, 1, -1)

	sgp.set_color(0.1, 0.1, 0.1, 1.0)
	sgp.clear()

	time := f32(sapp.frame_count()) * f32(sapp.frame_duration())
	r := math.sin(time) * 0.5 + 0.5
	g := math.cos(time) * 0.5 + 0.5

	sgp.set_color(r, g, 0.3, 1.0)
	sgp.rotate_at(time, 0, 0)
	sgp.draw_filled_rect(-0.5, -0.5, 1, 1)

	pass := sg.Pass {
		swapchain = sglue.swapchain(),
	}

	sg.begin_pass(pass)
	sgp.flush()
	sgp.end()
	sg.end_pass()
	sg.commit()
}

init :: proc "c" () {
	sgdesc := sg.Desc {
		environment = sglue.environment(),
		logger = {func = slog.func},
	}
	sg.setup(sgdesc)

	sgpdesc: sgp.Desc
	sgp.setup(sgpdesc)
}

cleanup :: proc "c" () {
	sgp.shutdown()
	sg.shutdown()
}

main :: proc() {
	sapp.run(
		{
			init_cb = init,
			frame_cb = frame,
			cleanup_cb = cleanup,
			window_title = "SOKOL GP EXAMPLE",
			logger = {func = slog.func},
		},
	)
}

