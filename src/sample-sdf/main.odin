/*
 * Example taken from the sokol_gp and ported to Odin:
 * https://github.com/edubart/sokol_gp.git
 *
 * This examples shows how to create 2D shaders,
 * in this case the shader is a SDF (signed distance field) animation.
 */
package main

import sapp "../../libs/sokol-odin/sokol/app"
import sg "../../libs/sokol-odin/sokol/gfx"
import sglue "../../libs/sokol-odin/sokol/glue"
import sgp "../../libs/sokol-odin/sokol/gp"
import slog "../../libs/sokol-odin/sokol/log"
import "base:runtime"
import "core:os"
import stbi "vendor:stb/image"

pip: sg.Pipeline
shd: sg.Shader

frame :: proc "c" () {
	width := sapp.width()
	height := sapp.height()
	sgp.begin(width, height)

	// Draw using the custom shader pipeline
	// 
	sgp.set_pipeline(pip)

	vs_uniform: Vs_Uniforms
	vs_uniform.iResolution = {f32(width), f32(height)}

	fs_uniform: Fs_Uniforms
	fs_uniform.iTime = f32(sapp.frame_count()) / 60

	sgp.set_uniform(&vs_uniform, size_of(Vs_Uniforms), &fs_uniform, size_of(Fs_Uniforms))
	sgp.unset_image(0)
	sgp.draw_filled_rect(0, 0, f32(width), f32(height))
	sgp.reset_image(0)
	sgp.reset_pipeline()

	// Dispatch draw commands
	// 
	pass: sg.Pass
	pass.swapchain = sglue.swapchain()

	sg.begin_pass(pass)
	sgp.flush()
	sgp.end()
	sg.end_pass()
	sg.commit()
}

init :: proc "c" () {
	context = runtime.default_context()

	// Initialize sokol gfx
	// 
	sgdesc := sg.Desc {
		environment = sglue.environment(),
		logger = {func = slog.func},
	}
	sg.setup(sgdesc)
	assert(sg.isvalid())

	// Initialize sokol gp
	// 
	sgpdesc: sgp.Desc
	sgp.setup(sgpdesc)
	assert(sgp.is_valid())

	// Initialize shader
	//
	shd = sg.make_shader(sample_sdf_shader_desc(sg.query_backend()))
	assert(sg.query_shader_state(shd) == .VALID)
	pip_desc := sgp.Pipeline_Desc {
		shader       = shd,
		has_vs_color = true,
	}
	pip = sgp.make_pipeline(pip_desc)
	assert(sg.query_pipeline_state(pip) == .VALID)
}

cleanup :: proc "c" () {
	sg.destroy_pipeline(pip)
	sg.destroy_shader(shd)
	sgp.shutdown()
	sg.shutdown()
}

main :: proc() {
	sapp.run(
		{
			init_cb = init,
			frame_cb = frame,
			cleanup_cb = cleanup,
			window_title = "SOKOL GP SAMPLE - EFFECT",
			logger = {func = slog.func},
		},
	)
}

