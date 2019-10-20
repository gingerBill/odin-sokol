package sokol_gfx

when ODIN_OS == "windows" do foreign import sgfx_lib "sokol_gfx_d3d11.lib"

import "core:c"

c_int :: c.int;

@(default_calling_convention="c")
@(link_prefix="sg_")
foreign sgfx_lib {
	/* setup and misc functions */
	shutdown            :: proc() ---
	@(link_name="sg_isvalid") is_valid :: proc() -> bool  ---
	reset_state_cache   :: proc() ---
	push_debug_group    :: proc(name: cstring) ---
	pop_debug_group     :: proc() ---

	/* resource creation, destruction and updating */
	destroy_buffer        :: proc(buf:  Buffer) ---
	destroy_image         :: proc(img:  Image) ---
	destroy_shader        :: proc(shd:  Shader) ---
	destroy_pipeline      :: proc(pip:  Pipeline) ---
	destroy_pass          :: proc(pass: Pass) ---
	query_buffer_overflow :: proc(buf: Buffer) -> bool ---

	/* rendering functions */
	apply_pipeline     :: proc(pip: Pipeline) ---
	end_pass           :: proc() ---
	commit             :: proc() ---

	/* getting information */
	query_desc        :: proc() -> Desc ---
	query_backend     :: proc() -> Backend ---
	query_features    :: proc() -> Features ---
	query_limits      :: proc() -> Limits ---
	query_pixelformat :: proc(format: Pixel_Format) -> Pixel_Format_Info ---
	/* get current state of a resource (INITIAL, ALLOC, VALID, FAILED, INVALID) */
	query_buffer_state   :: proc(buf:  Buffer)   -> Resource_State ---
	query_image_state    :: proc(img:  Image)    -> Resource_State ---
	query_shader_state   :: proc(shd:  Shader)   -> Resource_State ---
	query_pipeline_state :: proc(pip:  Pipeline) -> Resource_State ---
	query_pass_state     :: proc(pass: Pass)     -> Resource_State ---
	/* get runtime information about a resource */
	query_buffer_info   :: proc(buf:  Buffer)   -> Buffer_Info ---
	query_image_info    :: proc(img:  Image)    -> Image_Info ---
	query_shader_info   :: proc(shd:  Shader)   -> Shader_Info ---
	query_pipeline_info :: proc(pip:  Pipeline) -> Pipeline_Info ---
	query_pass_info     :: proc(pass: Pass)     -> Pass_Info ---

	/* separate resource allocation and initialization (for async setup) */
	alloc_buffer   :: proc() -> Buffer ---
	alloc_image    :: proc() -> Image ---
	alloc_shader   :: proc() -> Shader ---
	alloc_pipeline :: proc() -> Pipeline ---
	fail_buffer    :: proc(buf_id:  Buffer) ---
	fail_image     :: proc(img_id:  Image) ---
	fail_shader    :: proc(shd_id:  Shader) ---
	fail_pipeline  :: proc(pip_id:  Pipeline) ---
	fail_pass      :: proc(pass_id: Pass) ---

	/* rendering contexts (optional) */
	@(link_name="sg_setup_context")    setup_ctx    :: proc() -> Ctx ---
	@(link_name="sg_activate_context") activate_ctx :: proc(ctx_id: Ctx) ---
	@(link_name="sg_discard_context")  discard_ctx  :: proc(ctx_id: Ctx) ---
}

/* setup and misc functions */
setup :: proc(desc: Desc) {
	d := desc;
	sg_setup(&d);
}
install_trace_hooks :: proc(hooks: Trace_Hooks) -> Trace_Hooks {
	h := hooks;
	return sg_install_trace_hooks(&h);
}

/* resource creation, destruction and updating */
make_buffer :: proc(desc: Buffer_Desc) -> Buffer {
	d := desc;
	return sg_make_buffer(&d);
}
make_image :: proc(desc: Image_Desc) -> Image {
	d := desc;
	return sg_make_image(&d);
}
make_shader :: proc(desc: Shader_Desc) -> Shader {
	d := desc;
	return sg_make_shader(&d);
}
make_pipeline :: proc(desc: Pipeline_Desc) -> Pipeline {
	d := desc;
	return sg_make_pipeline(&d);
}
make_pass :: proc(desc: Pass_Desc) -> Pass {
	d := desc;
	return sg_make_pass(&d);
}
update_buffer :: proc(buf: Buffer, data_ptr: rawptr, data_size: int) {
	sg_update_buffer(buf, data_ptr, c_int(data_size));
}
update_image :: proc(img: Image, data: Image_Content) {
	d := data;
	sg_update_image(img, &d);
}
append_buffer :: proc(buf: Buffer, data_ptr: rawptr, data_size: int) -> int {
	return cast(int)sg_append_buffer(buf, data_ptr, c_int(data_size));
}

/* rendering functions */
begin_default_pass :: proc(pass_action: Pass_Action, width, height: int) {
	p := pass_action;
	sg_begin_default_pass(&p, c_int(width), c_int(height));
}
begin_pass :: proc(pass: Pass, pass_action: Pass_Action) {
	p := pass_action;
	sg_begin_pass(pass, &p);
}
apply_viewport :: proc(x, y, width, height: int, origin_top_left: bool) {
	sg_apply_viewport(c_int(x), c_int(y), c_int(width), c_int(height), origin_top_left);
}
apply_scissor_rect :: proc(x, y, width, height: int, origin_top_left: bool) {
	sg_apply_scissor_rect(c_int(x), c_int(y), c_int(width), c_int(height), origin_top_left);
}
apply_bindings :: proc(bindings: Bindings) {
	b := bindings;
	sg_apply_bindings(&b);
}
apply_uniforms :: proc(stage: Shader_Stage, ub_index: int, data: rawptr, num_bytes: int) {
	sg_apply_uniforms(stage, c_int(ub_index), data, c_int(num_bytes));
}
draw :: proc(base_element, num_elements, num_instances: int) {
	sg_draw(c_int(base_element), c_int(num_elements), c_int(num_instances));
}

/* get resource creation desc struct with their default values replaced */
query_buffer_defaults :: proc(desc: Buffer_Desc) -> Buffer_Desc {
	d := desc;
	return sg_query_buffer_defaults(&d);
}
query_image_defaults :: proc(desc: Image_Desc) -> Image_Desc {
	d := desc;
	return sg_query_image_defaults(&d);
}
query_shader_defaults :: proc(desc: Shader_Desc) -> Shader_Desc {
	d := desc;
	return sg_query_shader_defaults(&d);
}
query_pipeline_defaults :: proc(desc: Pipeline_Desc) -> Pipeline_Desc {
	d := desc;
	return sg_query_pipeline_defaults(&d);
}
query_pass_defaults :: proc(desc: Pass_Desc) -> Pass_Desc {
	d := desc;
	return sg_query_pass_defaults(&d);
}

/* separate resource allocation and initialization (for async setup) */
init_buffer :: proc(buf_id: Buffer, desc: Buffer_Desc) {
	d := desc;
	sg_init_buffer(buf_id, &d);
}
init_image :: proc(img_id: Image, desc: Image_Desc) {
	d := desc;
	sg_init_image(img_id, &d);
}
init_shader :: proc(shd_id: Shader, desc: Shader_Desc) {
	d := desc;
	sg_init_shader(shd_id, &d);
}
init_pipeline :: proc(pip_id: Pipeline, desc: Pipeline_Desc) {
	d := desc;
	sg_init_pipeline(pip_id, &d);
}
init_pass :: proc(pass_id: Pass, desc: Pass_Desc) {
	d := desc;
	sg_init_pass(pass_id, &d);
}



@(default_calling_convention="c")
foreign sgfx_lib {
	/* setup and misc functions */
	sg_setup               :: proc(desc: ^Desc) ---
	sg_install_trace_hooks :: proc(hooks: ^Trace_Hooks) -> Trace_Hooks ---

	/* resource creation, destruction and updating */
	sg_make_buffer           :: proc(desc: ^Buffer_Desc)   -> Buffer ---
	sg_make_image            :: proc(desc: ^Image_Desc)    -> Image ---
	sg_make_shader           :: proc(desc: ^Shader_Desc)   -> Shader ---
	sg_make_pipeline         :: proc(desc: ^Pipeline_Desc) -> Pipeline ---
	sg_make_pass             :: proc(desc: ^Pass_Desc)     -> Pass ---
	sg_update_buffer         :: proc(buf: Buffer, data_ptr: rawptr, data_size: c_int) ---
	sg_update_image          :: proc(img: Image,  data: ^Image_Content) ---
	sg_append_buffer         :: proc(buf: Buffer, data_ptr: rawptr, data_size: c_int) -> c_int ---

	/* rendering functions */
	sg_begin_default_pass :: proc(pass_action: ^Pass_Action, width, height: c_int) ---
	sg_begin_pass         :: proc(pass: Pass, pass_action: ^Pass_Action) ---
	sg_apply_viewport     :: proc(x, y, width, height: c_int, origin_top_left: bool) ---
	sg_apply_scissor_rect :: proc(x, y, width, height: c_int, origin_top_left: bool) ---
	sg_apply_bindings     :: proc(bindings: ^Bindings) ---
	sg_apply_uniforms     :: proc(stage: Shader_Stage, ub_index: c_int, data: rawptr, num_bytes: c_int) ---
	sg_draw               :: proc(base_element, num_elements, num_instances: c_int) ---

	/* get resource creation desc struct with their default values replaced */
	sg_query_buffer_defaults   :: proc(desc: ^Buffer_Desc)   -> Buffer_Desc ---
	sg_query_image_defaults    :: proc(desc: ^Image_Desc)    -> Image_Desc ---
	sg_query_shader_defaults   :: proc(desc: ^Shader_Desc)   -> Shader_Desc ---
	sg_query_pipeline_defaults :: proc(desc: ^Pipeline_Desc) -> Pipeline_Desc ---
	sg_query_pass_defaults     :: proc(desc: ^Pass_Desc)     -> Pass_Desc ---

	/* separate resource allocation and initialization (for async setup) */
	sg_init_buffer    :: proc(buf_id:  Buffer,   desc: ^Buffer_Desc) ---
	sg_init_image     :: proc(img_id:  Image,    desc: ^Image_Desc) ---
	sg_init_shader    :: proc(shd_id:  Shader,   desc: ^Shader_Desc) ---
	sg_init_pipeline  :: proc(pip_id:  Pipeline, desc: ^Pipeline_Desc) ---
	sg_init_pass      :: proc(pass_id: Pass,     desc: ^Pass_Desc) ---
}
