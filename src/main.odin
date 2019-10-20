package main

import sg "sokol_gfx"
import sapp "sokol_app"

import "core:os"

state: struct {
	pass_action: sg.Pass_Action,
	bind:        sg.Bindings,
	pip:         sg.Pipeline,
};

init_callback :: proc "c" () {
	sg.setup({
		mtl_device                   = sapp.metal_get_device(),
		mtl_renderpass_descriptor_cb = sapp.metal_get_renderpass_descriptor,
		mtl_drawable_cb              = sapp.metal_get_drawable,
		d3d11_device                 = sapp.d3d11_get_device(),
		d3d11_device_context         = sapp.d3d11_get_device_context(),
		d3d11_render_target_view_cb  = sapp.d3d11_get_render_target_view,
		d3d11_depth_stencil_view_cb  = sapp.d3d11_get_depth_stencil_view,
	});

	Vertex :: struct {
		pos: [3]f32,
		col: [4]f32,
	};

	vertices := [?]Vertex{
		{{+0.5, +0.5, +0.5}, {1.0, 0.0, 0.0, 1.0}},
		{{+0.5, -0.5, +0.5}, {0.0, 1.0, 0.0, 1.0}},
		{{-0.5, -0.5, +0.5}, {0.0, 0.0, 1.0, 1.0}},
		{{-0.5, -0.5, +0.5}, {0.0, 0.0, 1.0, 1.0}},
		{{-0.5, +0.5, +0.5}, {0.0, 0.0, 1.0, 1.0}},
		{{+0.5, +0.5, +0.5}, {1.0, 0.0, 0.0, 1.0}},
	};
	state.bind.vertex_buffers[0] = sg.make_buffer({
		size = len(vertices)*size_of(vertices[0]),
		content = &vertices[0],
		label = "triangle-vertices",
	});

	state.pip = sg.make_pipeline({
		shader = sg.make_shader({
			vs = {
				source = `
					struct vs_in {
						float4 pos: POS;
						float4 col: COLOR;
					};
					struct vs_out {
						float4 col: COLOR0;
						float4 pos: SV_POSITION;
					};
					vs_out main(vs_in inp) {
						vs_out outp;
						outp.pos = inp.pos;
						outp.col = inp.col;
						return outp;
					}
				`,
			},
			fs = {
				source = `
					float4 main(float4 col: COLOR0): SV_TARGET0 {
						return col;
					}
				`,
			},

			attrs = {
				0 = {sem_name = "POS"},
				1 = {sem_name = "COLOR"},
			},
		}),
		label = "triangle-pipeline",
		primitive_type = .TRIANGLES,
		layout = {
			attrs = {
				0 = {format = .FLOAT3},
				1 = {format = .FLOAT4},
			},
		},
	});

	state.pass_action.colors[0] = {action = .CLEAR, val = {0.5, 0.7, 1.0, 1}};
}

frame_callback :: proc "c" () {
	sg.begin_default_pass(state.pass_action, sapp.framebuffer_size());
	sg.apply_pipeline(state.pip);
	sg.apply_bindings(state.bind);
	sg.draw(0, 6, 1);
	sg.end_pass();
	sg.commit();
}

main :: proc() {
	err := sapp.run({
		init_cb      = init_callback,
		frame_cb     = frame_callback,
		cleanup_cb   = proc "c" () { sg.shutdown(); },
		event_cb     = event_callback,
		width        = 400,
		height       = 300,
		window_title = "SOKOL Quad",
	});
	os.exit(int(err));
}


event_callback :: proc "c" (event: ^sapp.Event) {
	if event.type == .KEY_DOWN && !event.key_repeat {
		switch event.key_code {
		case .ESCAPE:
			sapp.request_quit();
		case .Q:
			if .CTRL in event.modifiers {
				sapp.request_quit();
			}
		}
	}
}
