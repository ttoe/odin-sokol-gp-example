/*
 * Example taken from the sokol_gp and ported to Odin:
 * https://github.com/edubart/sokol_gp.git
 *
 * This sample showcases how to create 2D shader effects using multiple textures.
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
image: sg.Image
linear_sampler: sg.Sampler
perlin_image: sg.Image

frame :: proc "c" () {
	window_width := sapp.width()
	window_height := sapp.height()
	sgp.begin(window_width, window_height)

	secs := f64(sapp.frame_count()) * sapp.frame_duration()

	image_desc := sg.query_image_desc(image)
	window_ratio := f32(window_width) / f32(window_height)
	image_ratio := f32(image_desc.width) / f32(image_desc.height)

	uniforms: Fs_Uniforms = {
		iVelocity  = {0.02, 0.01},
		iPressure  = 0.3,
		iTime      = f32(secs),
		iWarpiness = 0.2,
		iRatio     = image_ratio,
		iZoom      = 0.4,
		iLevel     = 1.0,
	}

	sgp.set_pipeline(pip)
	sgp.set_uniform(nil, 0, &uniforms, size_of(Fs_Uniforms))
	sgp.set_image(IMG_iTexChannel0, image)
	sgp.set_image(IMG_iTexChannel1, perlin_image)
	sgp.set_sampler(SMP_iSmpChannel0, linear_sampler)
	sgp.set_sampler(SMP_iSmpChannel1, linear_sampler)
	width := window_ratio >= image_ratio ? f32(window_width) : image_ratio * f32(window_height)
	height := window_ratio >= image_ratio ? f32(window_width) / image_ratio : f32(window_height)

	sgp.draw_filled_rect(0, 0, width, height)

	sgp.reset_image(IMG_iTexChannel0)
	sgp.reset_image(IMG_iTexChannel1)
	sgp.reset_sampler(SMP_iSmpChannel0)
	sgp.reset_sampler(SMP_iSmpChannel1)
	sgp.reset_pipeline()

	pass := sg.Pass {
		swapchain = sglue.swapchain(),
	}

	sg.begin_pass(pass)
	sgp.flush()
	sgp.end()
	sg.end_pass()
	sg.commit()
}

load_image :: proc(filename: string) -> sg.Image {
	bytes, read_succes := os.read_entire_file_from_filename(filename)
	assert(read_succes)

	width, height, channels: i32
	data := stbi.load_from_memory(raw_data(bytes), i32(len(bytes)), &width, &height, &channels, 4)
	img: sg.Image

	if data == nil {
		return img
	}

	image_desc := sg.Image_Desc {
		width = width,
		height = height,
		data = {subimage = {0 = {0 = {ptr = data, size = uint(width * height * 4)}}}},
	}

	img = sg.make_image(image_desc)
	stbi.image_free(data)

	return img
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

	// Load images
	//
	image = load_image("images/lpc_winter_preview.png")
	perlin_image = load_image("images/perlin.png")
	assert(sg.query_image_state(image) == .VALID)
	assert(sg.query_image_state(perlin_image) == .VALID)

	// Create linear sampler
	// 
	linear_sampler_desc := sg.Sampler_Desc {
		min_filter = .LINEAR,
		mag_filter = .LINEAR,
		wrap_u     = .REPEAT,
		wrap_v     = .REPEAT,
	}
	linear_sampler = sg.make_sampler(linear_sampler_desc)
	assert(sg.query_sampler_state(linear_sampler) == .VALID)

	// Initialize shader
	//
	shd = sg.make_shader(sample_effect_shader_desc(sg.query_backend()))
	assert(sg.query_shader_state(shd) == .VALID)
	pip_desc := sgp.Pipeline_Desc {
		shader       = shd,
		has_vs_color = true,
	}
	pip = sgp.make_pipeline(pip_desc)
	assert(sg.query_pipeline_state(pip) == .VALID)
}

cleanup :: proc "c" () {
	sg.destroy_image(image)
	sg.destroy_image(perlin_image)
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

