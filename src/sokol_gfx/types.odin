package sokol_gfx

import "core:c"


/*
    Resource id typedefs:

    Buffer:      vertex- and index-buffers
    Image:       textures and render targets
    Shader:      vertex- and fragment-shaders, uniform blocks
    Pipeline:    associated shader and vertex-layouts, and render states
    Pass:        a bundle of render targets and actions on them
    Context:     a 'context handle' for switching between 3D-API contexts

    Instead of pointers, resource creation functions return a 32-bit
    number which uniquely identifies the resource object.

    The 32-bit resource id is split into a 16-bit pool index in the lower bits,
    and a 16-bit 'unique counter' in the upper bits. The index allows fast
    pool lookups, and combined with the unique-mask it allows to detect
    'dangling accesses' (trying to use an object which no longer exists, and
    its pool slot has been reused for a new object)

    The resource ids are wrapped into a struct so that the compiler
    can complain when the wrong resource type is used.
*/
Buffer   :: struct { id: u32 };
Image    :: struct { id: u32 };
Shader   :: struct { id: u32 };
Pipeline :: struct { id: u32 };
Pass     :: struct { id: u32 };
Ctx      :: struct { id: u32 };


INVALID_ID              :: 0;
NUM_SHADER_STAGES       :: 2;
NUM_INFLIGHT_FRAMES     :: 2;
MAX_COLOR_ATTACHMENTS   :: 4;
MAX_SHADERSTAGE_BUFFERS :: 8;
MAX_SHADERSTAGE_IMAGES  :: 12;
MAX_SHADERSTAGE_UBS     :: 4;
MAX_UB_MEMBERS          :: 16;
MAX_VERTEX_ATTRIBUTES   :: 16; /* NOTE: actual max vertex attrs can be less on GLES2, see limits! */
MAX_MIPMAPS             :: 16;
MAX_TEXTUREARRAY_LAYERS :: 128;


/*
    backend

    The active 3D-API backend, use the function query_backend()
    to get the currently active backend.

    For returned value corresponds with the compile-time define to select
    a backend, with the only exception of SOKOL_GLES3: this may
    return BACKEND_GLES2 if the backend has to fallback to GLES2 mode
    because GLES3 isn't supported.
*/
Backend :: enum i32 {
    GLCORE33,
    GLES2,
    GLES3,
    D3D11,
    METAL_IOS,
    METAL_MACOS,
    METAL_SIMULATOR,
    DUMMY,
};


/*
    Pixel_Format

    sokol_gfx basically uses the same pixel formats as WebGPU, since these
    are supported on most newer GPUs. GLES2 and WebGL has a much smaller
    subset of available pixel formats. Call query_pixelformat() to check
    at runtime if a pixel format supports the desired features.

    A pixelformat name consist of three parts:

        - components (R, RG, RGB or RGBA)
        - bit width per component (8, 16 or 32)
        - component data type:
            - unsigned normalized (no postfix)
            - signed normalized (SN postfix)
            - unsigned integer (UI postfix)
            - signed integer (SI postfix)
            - float (F postfix)

    Not all pixel formats can be used for everything, call query_pixelformat()
    to inspect the capabilities of a given pixelformat. The function returns
    an pixelformat_info struct with the following bool members:

        - sample: the pixelformat can be sampled as texture at least with
                  nearest filtering
        - filter: the pixelformat can be samples as texture with linear
                  filtering
        - render: the pixelformat can be used for render targets
        - blend:  blending is supported when using the pixelformat for
                  render targets
        - msaa:   multisample-antiliasing is supported when using the
                  pixelformat for render targets
        - depth:  the pixelformat can be used for depth-stencil attachments

    When targeting GLES2/WebGL, the only safe formats to use
    as texture are PIXELFORMAT_R8 and PIXELFORMAT_RGBA8. For rendering
    in GLES2/WebGL, only PIXELFORMAT_RGBA8 is safe. All other formats
    must be checked via query_pixelformats().

    The default pixel format for texture images is PIXELFORMAT_RGBA8.

    The default pixel format for render target images is platform-dependent:
        - for Metal and D3D11 it is PIXELFORMAT_BGRA8
        - for GL backends it is PIXELFORMAT_RGBA8

    This is mainly because of the default framebuffer which is setup outside
    of sokol_gfx.h. On some backends, using BGRA for the default frame buffer
    allows more efficient frame flips. For your own offscreen-render-targets,
    use whatever renderable pixel format is convenient for you.
*/
Pixel_Format :: enum i32 {
    _DEFAULT,    /* value 0 reserved for default-init */
    NONE,

    R8,
    R8SN,
    R8UI,
    R8SI,

    R16,
    R16SN,
    R16UI,
    R16SI,
    R16F,
    RG8,
    RG8SN,
    RG8UI,
    RG8SI,

    R32UI,
    R32SI,
    R32F,
    RG16,
    RG16SN,
    RG16UI,
    RG16SI,
    RG16F,
    RGBA8,
    RGBA8SN,
    RGBA8UI,
    RGBA8SI,
    BGRA8,
    RGB10A2,
    RG11B10F,

    RG32UI,
    RG32SI,
    RG32F,
    RGBA16,
    RGBA16SN,
    RGBA16UI,
    RGBA16SI,
    RGBA16F,

    RGBA32UI,
    RGBA32SI,
    RGBA32F,

    DEPTH,
    DEPTH_STENCIL,

    BC1_RGBA,
    BC2_RGBA,
    BC3_RGBA,
    BC4_R,
    BC4_RSN,
    BC5_RG,
    BC5_RGSN,
    BC6H_RGBF,
    BC6H_RGBUF,
    BC7_RGBA,
    PVRTC_RGB_2BPP,
    PVRTC_RGB_4BPP,
    PVRTC_RGBA_2BPP,
    PVRTC_RGBA_4BPP,
    ETC2_RGB8,
    ETC2_RGB8A1,

    _NUM,
};


/*
    Runtime information about a pixel format, returned
    by query_pixelformat().
*/
Pixel_Format_Info :: struct {
    sample: bool, /* pixel format can be sampled in shaders */
    filter: bool, /* pixel format can be sampled with filtering */
    render: bool, /* pixel format can be used as render target */
    blend:  bool, /* alpha-blending is supported */
    msaa:   bool, /* pixel format can be used as MSAA render target */
    depth:  bool, /* pixel format is a depth format */
};

/*
    Runtime information about available optional features,
    returned by query_features()
*/
Features :: struct {
    instancing:              bool,
    origin_top_left:         bool,
    multiple_render_targets: bool,
    msaa_render_targets:     bool,
    imagetype_3d:            bool, /* creation of IMAGETYPE_3D images is supported */
    imagetype_array:         bool, /* creation of IMAGETYPE_ARRAY images is supported */
    image_clamp_to_border:   bool, /* border color and clamp-to-border UV-wrap mode is supported */
};


/*
    Runtime information about resource limits, returned by query_limit()
*/
Limits :: struct {
    max_image_size_2d:      u32, /* max width/height of IMAGETYPE_2D images */
    max_image_size_cube:    u32, /* max width/height of IMAGETYPE_CUBE images */
    max_image_size_3d:      u32, /* max width/height/depth of IMAGETYPE_3D images */
    max_image_size_array:   u32,
    max_image_array_layers: u32,
    max_vertex_attrs:       u32, /* <= MAX_VERTEX_ATTRIBUTES (only on some GLES2 impls) */
};

/*
    resource_state

    The current state of a resource in its resource pool.
    Resources start in the INITIAL state, which means the
    pool slot is unoccupied and can be allocated. When a resource is
    created, first an id is allocated, and the resource pool slot
    is set to state ALLOC. After allocation, the resource is
    initialized, which may result in the VALID or FAILED state. The
    reason why allocation and initialization are separate is because
    some resource types (e.g. buffers and images) might be asynchronously
    initialized by the user application. If a resource which is not
    in the VALID state is attempted to be used for rendering, rendering
    operations will silently be dropped.

    The special INVALID state is returned in query_xxx_state() if no
    resource object exists for the provided resource id.
*/
Resource_State :: enum i32 {
    INITIAL,
    ALLOC,
    VALID,
    FAILED,
    INVALID,
};

/*
    usage

    A resource usage hc.int describing the update strategy of
    buffers and images. This is used in the buffer_desc.usage
    and image_desc.usage members when creating buffers
    and images:

    USAGE_IMMUTABLE:     the resource will never be updated with
                         new data, instead the data content of the
                         resource must be provided on creation
    USAGE_DYNAMIC:       the resource will be updated infrequently
                         with new data (this could range from "once
                         after creation", to "quite often but not
                         every frame")
    USAGE_STREAM:        the resource will be updated each frame
                         with new content

    The rendering backends use this hc.int to prevent that the
    CPU needs to wait for the GPU when attempting to update
    a resource that might be currently accessed by the GPU.

    Resource content is updated with the function update_buffer() for
    buffer objects, and update_image() for image objects. Only
    one update is allowed per frame and resource object. The
    application must update all data required for rendering (this
    means that the update data can be smaller than the resource size,
    if only a part of the overall resource size is used for rendering,
    you only need to make sure that the data that *is* used is valid.

    The default usage is USAGE_IMMUTABLE.
*/
Usage :: enum i32 {
    _DEFAULT,      /* value 0 reserved for default-init */
    IMMUTABLE,
    DYNAMIC,
    STREAM,
    _NUM,
};


/*
    buffer_type

    This indicates whether a buffer contains vertex- or index-data,
    used in the buffer_desc.type member when creating a buffer.

    The default value is BUFFERTYPE_VERTEXBUFFER.
*/
Buffer_Type :: enum i32 {
    _DEFAULT,         /* value 0 reserved for default-init */
    VERTEXBUFFER,
    INDEXBUFFER,
    _NUM,
};


/*
    index_type

    Indicates whether indexed rendering (fetching vertex-indices from an
    index buffer) is used, and if yes, the index data type (16- or 32-bits).
    This is used in the pipeline_desc.index_type member when creating a
    pipeline object.

    The default index type is INDEXTYPE_NONE.
*/
Index_Type :: enum i32 {
    _DEFAULT,   /* value 0 reserved for default-init */
    NONE,
    UINT16,
    UINT32,
    _NUM,
};

/*
    image_type

    Indicates the basic image type (2D-texture, cubemap, 3D-texture
    or 2D-array-texture). 3D- and array-textures are not supported
    on the GLES2/WebGL backend. The image type is used in the
    image_desc.type member when creating an image.

    The default image type when creating an image is IMAGETYPE_2D.
*/
Image_Type :: enum i32 {
    _DEFAULT,  /* value 0 reserved for default-init */
    D2,
    CUBE,
    D3,
    ARRAY,
    _NUM,
};

/*
    Cube_Face

    The cubemap faces. Use these as indices in the image_desc.content
    array.
*/
Cube_Face :: enum i32 {
   POS_X,
   NEG_X,
   POS_Y,
   NEG_Y,
   POS_Z,
   NEG_Z,
   NUM,
};

/*
    Shader_Stage

    There are 2 shader stages: vertex- and fragment-shader-stage.
    Each shader stage consists of:

    - one slot for a shader function (provided as source- or byte-code)
    - MAX_SHADERSTAGE_UBS slots for uniform blocks
    - MAX_SHADERSTAGE_IMAGES slots for images used as textures by
      the shader function
*/
Shader_Stage :: enum i32 {
    VS,
    FS,
};

/*
    Primitive_Type

    This is the common subset of 3D primitive types supported across all 3D
    APIs. This is used in the pipeline_desc.primitive_type member when
    creating a pipeline object.

    The default primitive type is PRIMITIVETYPE_TRIANGLES.
*/
Primitive_Type :: enum i32 {
    _DEFAULT,  /* value 0 reserved for default-init */
    POINTS,
    LINES,
    LINE_STRIP,
    TRIANGLES,
    TRIANGLE_STRIP,
    _NUM,
};

/*
    Filter

    The filtering mode when sampling a texture image. This is
    used in the image_desc.min_filter and image_desc.mag_filter
    members when creating an image object.

    The default filter mode is FILTER_NEAREST.
*/
Filter :: enum i32 {
    _DEFAULT, /* value 0 reserved for default-init */
    NEAREST,
    LINEAR,
    NEAREST_MIPMAP_NEAREST,
    NEAREST_MIPMAP_LINEAR,
    LINEAR_MIPMAP_NEAREST,
    LINEAR_MIPMAP_LINEAR,
    _NUM,
};

/*
    Wrap

    The texture coordinates wrapping mode when sampling a texture
    image. This is used in the image_desc.wrap_u, .wrap_v
    and .wrap_w members when creating an image.

    The default wrap mode is WRAP_REPEAT.

    NOTE: WRAP_CLAMP_TO_BORDER is not supported on all backends
    and platforms. To check for support, call query_features()
    and check the "clamp_to_border" boolean in the returned
    features struct.

    Platforms which don't support WRAP_CLAMP_TO_BORDER will silently fall back
    to WRAP_CLAMP_TO_EDGE without a validation error.

    Platforms which support clamp-to-border are:

        - all desktop GL platforms
        - Metal on macOS
        - D3D11

    Platforms which do not support clamp-to-border:

        - GLES2/3 and WebGL/WebGL2
        - Metal on iOS
*/
Wrap :: enum i32 {
    _DEFAULT,   /* value 0 reserved for default-init */
    REPEAT,
    CLAMP_TO_EDGE,
    CLAMP_TO_BORDER,
    MIRRORED_REPEAT,
    _NUM,
};

/*
    Border_Color

    The border color to use when sampling a texture, and the UV wrap
    mode is WRAP_CLAMP_TO_BORDER.

    The default border color is BORDERCOLOR_OPAQUE_BLACK
*/
Border_Color :: enum i32 {
    _DEFAULT,    /* value 0 reserved for default-init */
    TRANSPARENT_BLACK,
    OPAQUE_BLACK,
    OPAQUE_WHITE,
    _NUM,
};

/*
    Vertex_Format

    The data type of a vertex component. This is used to describe
    the layout of vertex data when creating a pipeline object.
*/
Vertex_Format :: enum i32 {
    INVALID,
    FLOAT,
    FLOAT2,
    FLOAT3,
    FLOAT4,
    BYTE4,
    BYTE4N,
    UBYTE4,
    UBYTE4N,
    SHORT2,
    SHORT2N,
    USHORT2N,
    SHORT4,
    SHORT4N,
    USHORT4N,
    UINT10_N2,
    _NUM,
};

/*
    Vertex_Step

    Defines whether the input pointer of a vertex input stream is advanced
    'per vertex' or 'per instance'. The default step-func is
    VERTEXSTEP_PER_VERTEX. VERTEXSTEP_PER_INSTANCE is used with
    instanced-rendering.

    The vertex-step is part of the vertex-layout definition
    when creating pipeline objects.
*/
Vertex_Step :: enum i32 {
    _DEFAULT,     /* value 0 reserved for default-init */
    PER_VERTEX,
    PER_INSTANCE,
    _NUM,
};

/*
    Uniform_Type

    The data type of a uniform block member. This is used to
    describe the internal layout of uniform blocks when creating
    a shader object.
*/
Uniform_Type :: enum i32 {
    INVALID,
    FLOAT,
    FLOAT2,
    FLOAT3,
    FLOAT4,
    MAT4,
    _NUM,
};

/*
    Cull_Mode

    The face-culling mode, this is used in the
    pipeline_desc.rasterizer.cull_mode member when creating a
    pipeline object.

    The default cull mode is CULLMODE_NONE
*/
Cull_Mode :: enum i32 {
    _DEFAULT,   /* value 0 reserved for default-init */
    NONE,
    FRONT,
    BACK,
    _NUM,
};

/*
    Face_Winding

    The vertex-winding rule that determines a front-facing primitive. This
    is used in the member pipeline_desc.rasterizer.face_winding
    when creating a pipeline object.

    The default winding is FACEWINDING_CW (clockwise)
*/
Face_Winding :: enum i32 {
    _DEFAULT,    /* value 0 reserved for default-init */
    CCW,
    CW,
    _NUM,
};

/*
    Compare_Func

    The compare-function for depth- and stencil-ref tests.
    This is used when creating pipeline objects in the members:

    pipeline_desc
        .depth_stencil
            .depth_compare_func
            .stencil_front.compare_func
            .stencil_back.compare_func

    The default compare func for depth- and stencil-tests is
    COMPAREFUNC_ALWAYS.
*/
Compare_Func :: enum i32 {
    _DEFAULT,    /* value 0 reserved for default-init */
    NEVER,
    LESS,
    EQUAL,
    LESS_EQUAL,
    GREATER,
    NOT_EQUAL,
    GREATER_EQUAL,
    ALWAYS,
    _NUM,
};

/*
    Stencil_Op

    The operation performed on a currently stored stencil-value when a
    comparison test passes or fails. This is used when creating a pipeline
    object in the members:

    pipeline_desc
        .depth_stencil
            .stencil_front
                .fail_op
                .depth_fail_op
                .pass_op
            .stencil_back
                .fail_op
                .depth_fail_op
                .pass_op

    The default value is STENCILOP_KEEP.
*/
Stencil_Op :: enum i32 {
    _DEFAULT,      /* value 0 reserved for default-init */
    KEEP,
    ZERO,
    REPLACE,
    INCR_CLAMP,
    DECR_CLAMP,
    INVERT,
    INCR_WRAP,
    DECR_WRAP,
    _NUM,
};

/*
    Blend_Factor

    The source and destination factors in blending operations.
    This is used in the following members when creating a pipeline object:

    pipeline_desc
        .blend
            .src_factor_rgb
            .dst_factor_rgb
            .src_factor_alpha
            .dst_factor_alpha

    The default value is BLENDFACTOR_ONE for source
    factors, and BLENDFACTOR_ZERO for destination factors.
*/
Blend_Factor :: enum i32 {
    _DEFAULT,    /* value 0 reserved for default-init */
    ZERO,
    ONE,
    SRC_COLOR,
    ONE_MINUS_SRC_COLOR,
    SRC_ALPHA,
    ONE_MINUS_SRC_ALPHA,
    DST_COLOR,
    ONE_MINUS_DST_COLOR,
    DST_ALPHA,
    ONE_MINUS_DST_ALPHA,
    SRC_ALPHA_SATURATED,
    BLEND_COLOR,
    ONE_MINUS_BLEND_COLOR,
    BLEND_ALPHA,
    ONE_MINUS_BLEND_ALPHA,
    _NUM,
};

/*
    Blend_Op

    Describes how the source and destination values are combined in the
    fragment blending operation. It is used in the following members when
    creating a pipeline object:

    pipeline_desc
        .blend
            .op_rgb
            .op_alpha

    The default value is BLENDOP_ADD.
*/
Blend_Op :: enum i32 {
    _DEFAULT,    /* value 0 reserved for default-init */
    ADD,
    SUBTRACT,
    REVERSE_SUBTRACT,
    _NUM,
};

/*
    color_mask

    Selects the color channels when writing a fragment color to the
    framebuffer. This is used in the members
    pipeline_desc.blend.color_write_mask when creating a pipeline object.

    The default colormask is COLORMASK_RGBA (write all colors channels)
*/
COLOR_MASK__DEFAULT :: 0;      /* value 0 reserved for default-init */
COLOR_MASK_NONE :: (0x10);     /* special value for 'all channels disabled */
COLOR_MASK_R :: (1<<0);
COLOR_MASK_G :: (1<<1);
COLOR_MASK_B :: (1<<2);
COLOR_MASK_A :: (1<<3);
COLOR_MASK_RGB :: 0x7;
COLOR_MASK_RGBA :: 0xF;

/*
    action

    Defines what action should be performed at the start of a render pass:

    ACTION_CLEAR:    clear the render target image
    ACTION_LOAD:     load the previous content of the render target image
    ACTION_DONTCARE: leave the render target image content undefined

    This is used in the pass_action structure.

    The default action for all pass attachments is ACTION_CLEAR, with the
    clear color rgba = {0.5f, 0.5f, 0.5f, 1.0f], depth=1.0 and stencil=0.

    If you want to override the default behaviour, it is important to not
    only set the clear color, but the 'action' field as well (as long as this
    is in its _ACTION_DEFAULT, the value fields will be ignored).
*/
Action :: enum i32 {
    _DEFAULT,
    CLEAR,
    LOAD,
    DONTCARE,
    _NUM,
};

/*
    pass_action

    The pass_action struct defines the actions to be performed
    at the start of a rendering pass in the functions begin_pass()
    and begin_default_pass().

    A separate action and clear values can be defined for each
    color attachment, and for the depth-stencil attachment.

    The default clear values are defined by the macros:

    - DEFAULT_CLEAR_RED:     0.5f
    - DEFAULT_CLEAR_GREEN:   0.5f
    - DEFAULT_CLEAR_BLUE:    0.5f
    - DEFAULT_CLEAR_ALPHA:   1.0f
    - DEFAULT_CLEAR_DEPTH:   1.0f
    - DEFAULT_CLEAR_STENCIL: 0
*/
Color_Attachment_Action :: struct {
    action: Action,
    val:    [4]f32,
};

Depth_Attachment_Action :: struct {
    action: Action,
    val:    f32,
};

Stencil_Attachment_Action :: struct {
    action: Action,
    val:    u8,
};

Pass_Action :: struct {
    _start_canary: u32,
    colors:        [MAX_COLOR_ATTACHMENTS]Color_Attachment_Action,
    depth:         Depth_Attachment_Action,
    stencil:       Stencil_Attachment_Action,
    _end_canary:   u32,
};

/*
    bindings

    The bindings structure defines the resource binding slots
    of the sokol_gfx render pipeline, used as argument to the
    apply_bindings() function.

    A resource binding struct contains:

    - 1..N vertex buffers
    - 0..N vertex buffer offsets
    - 0..1 index buffers
    - 0..1 index buffer offsets
    - 0..N vertex shader stage images
    - 0..N fragment shader stage images

    The max number of vertex buffer and shader stage images
    are defined by the MAX_SHADERSTAGE_BUFFERS and
    MAX_SHADERSTAGE_IMAGES configuration constants.

    The optional buffer offsets can be used to group different chunks
    of vertex- and/or index-data into the same buffer objects.
*/
Bindings :: struct {
    _start_canary:         u32,
    vertex_buffers:        [MAX_SHADERSTAGE_BUFFERS]Buffer,
    vertex_buffer_offsets: [MAX_SHADERSTAGE_BUFFERS]c.int,
    index_buffer:          Buffer,
    index_buffer_offset:   c.int,
    vs_images:             [MAX_SHADERSTAGE_IMAGES]Image,
    fs_images:             [MAX_SHADERSTAGE_IMAGES]Image,
    _end_canary:           u32,
};

/*
    buffer_desc

    Creation parameters for buffer objects, used in the
    make_buffer() call.

    The default configuration is:

    .size:      0       (this *must* be set to a valid size in bytes)
    .type:      BUFFERTYPE_VERTEXBUFFER
    .usage:     USAGE_IMMUTABLE
    .content    0
    .label      0       (optional string label for trace hooks)

    The dbg_label will be ignored by sokol_gfx.h, it is only useful
    when hooking into make_buffer() or init_buffer() via
    the install_trace_hook

    ADVANCED TOPIC: Injecting native 3D-API buffers:

    The following struct members allow to inject your own GL, Metal
    or D3D11 buffers into sokol_gfx:

    .gl_buffers[NUM_INFLIGHT_FRAMES]
    .mtl_buffers[NUM_INFLIGHT_FRAMES]
    .d3d11_buffer

    You must still provide all other members except the .content member, and
    these must match the creation parameters of the native buffers you
    provide. For USAGE_IMMUTABLE, only provide a single native 3D-API
    buffer, otherwise you need to provide NUM_INFLIGHT_FRAMES buffers
    (only for GL and Metal, not D3D11). Providing multiple buffers for GL and
    Metal is necessary because sokol_gfx will rotate through them when
    calling update_buffer() to prevent lock-stalls.

    Note that it is expected that immutable injected buffer have already been
    initialized with content, and the .content member must be 0!

    Also you need to call reset_state_cache() after calling native 3D-API
    functions, and before calling any sokol_gfx function.
*/
Buffer_Desc :: struct {
    _start_canary: u32,
    size:          c.int,
    type:          Buffer_Type,
    usage:         Usage,
    content:       rawptr,
    label:         cstring,
    /* GL specific */
    gl_buffers:    [NUM_INFLIGHT_FRAMES]u32,
    /* Metal specific */
    mtl_buffers:   [NUM_INFLIGHT_FRAMES]rawptr,
    /* D3D11 specific */
    d3d11_buffer:  rawptr,
    _end_canary:   u32,
};

/*
    subimage_content

    Pointer to and size of a subimage-surface data, this is
    used to describe the initial content of immutable-usage images,
    or for updating a dynamic- or stream-usage images.

    For 3D- or array-textures, one subimage_content item
    describes an entire mipmap level consisting of all array- or
    3D-slices of the mipmap level. It is only possible to update
    an entire mipmap level, not parts of it.
*/
Subimage_Content :: struct {
    ptr: rawptr,    /* pointer to subimage data */
    size: c.int,    /* size in bytes of pointed-to subimage data */
};

/*
    image_content

    Defines the content of an image through a 2D array
    of Subimage_Content structs. The first array dimension
    is the cubemap face, and the second array dimension the
    mipmap level.
*/
Image_Content :: struct {
    subimage: [Cube_Face.NUM][MAX_MIPMAPS]Subimage_Content,
};

/*
    image_desc

    Creation parameters for image objects, used in the
    make_image() call.

    The default configuration is:

    .type:              IMAGETYPE_2D
    .render_target:     false
    .width              0 (must be set to >0)
    .height             0 (must be set to >0)
    .depth/.layers:     1
    .num_mipmaps:       1
    .usage:             USAGE_IMMUTABLE
    .pixel_format:      PIXELFORMAT_RGBA8 for textures, backend-dependent
                        for render targets (RGBA8 or BGRA8)
    .sample_count:      1 (only used in render_targets)
    .min_filter:        FILTER_NEAREST
    .mag_filter:        FILTER_NEAREST
    .wrap_u:            WRAP_REPEAT
    .wrap_v:            WRAP_REPEAT
    .wrap_w:            WRAP_REPEAT (only IMAGETYPE_3D)
    .border_color       BORDERCOLOR_OPAQUE_BLACK
    .max_anisotropy     1 (must be 1..16)
    .min_lod            0.0f
    .max_lod            FLT_MAX
    .content            an image_content struct to define the initial content
    .label              0       (optional string label for trace hooks)

    IMAGETYPE_ARRAY and IMAGETYPE_3D are not supported on
    WebGL/GLES2, use query_features().imagetype_array and
    query_features().imagetype_3d at runtime to check
    if array- and 3D-textures are supported.

    Images with usage USAGE_IMMUTABLE must be fully initialized by
    providing a valid .content member which points to
    initialization data.

    ADVANCED TOPIC: Injecting native 3D-API textures:

    The following struct members allow to inject your own GL, Metal
    or D3D11 textures into sokol_gfx:

    .gl_textures[NUM_INFLIGHT_FRAMES]
    .mtl_textures[NUM_INFLIGHT_FRAMES]
    .d3d11_texture

    The same rules apply as for injecting native buffers
    (see buffer_desc documentation for more details).
*/
Image_Desc :: struct {
    _start_canary:  u32,
    type:           Image_Type,
    render_target:  bool,
    width:          c.int,
    height:         c.int,
    using dl: struct #raw_union {
        depth:      c.int,
        layers:     c.int,
    },
    num_mipmaps:    c.int,
    usage:          Usage,
    pixel_format:   Pixel_Format,
    sample_count:   c.int,
    min_filter:     Filter,
    mag_filter:     Filter,
    wrap_u:         Wrap,
    wrap_v:         Wrap,
    wrap_w:         Wrap,
    border_color:   Border_Color,
    max_anisotropy: u32,
    min_lod:        f32,
    max_lod:        f32,
    content:        Image_Content,
    label:          cstring,
    /* GL specific */
    gl_textures:    [NUM_INFLIGHT_FRAMES]u32,
    /* Metal specific */
    mtl_textures:   [NUM_INFLIGHT_FRAMES]rawptr,
    /* D3D11 specific */
    d3d11_texture:  rawptr,
    _end_canary:    u32,
};

/*
    shader_desc

    The structure shader_desc defines all creation parameters
    for shader programs, used as input to the make_shader() function:

    - reflection information for vertex attributes (vertex shader inputs):
        - vertex attribute name (required for GLES2, optional for GLES3 and GL)
        - a semantic name and index (required for D3D11)
    - for each vertex- and fragment-shader-stage:
        - the shader source or bytecode
        - an optional entry function name
        - reflection info for each uniform block used by the shader stage:
            - the size of the uniform block in bytes
            - reflection info for each uniform block member (only required for GL backends):
                - member name
                - member type (UNIFORMTYPE_xxx)
                - if the member is an array, the number of array items
        - reflection info for the texture images used by the shader stage:
            - the image type (IMAGETYPE_xxx)
            - the name of the texture sampler (required for GLES2, optional everywhere else)

    For all GL backends, shader source-code must be provided. For D3D11 and Metal,
    either shader source-code or byte-code can be provided.

    For D3D11, if source code is provided, the d3dcompiler_47.dll will be loaded
    on demand. If this fails, shader creation will fail.
*/
Shader_Attr_Desc :: struct {
    name:      cstring, /* GLSL vertex attribute name (only required for GLES2) */
    sem_name:  cstring, /* HLSL semantic name */
    sem_index: c.int,   /* HLSL semantic index */
};

Shader_Uniform_Desc :: struct {
    name:        cstring,
    type:        Uniform_Type,
    array_count: c.int,
};

Shader_Uniform_Block_Desc :: struct {
    size:     c.int,
    uniforms: [MAX_UB_MEMBERS]Shader_Uniform_Desc,
};

Shader_Image_Desc :: struct {
    name: cstring,
    type: Image_Type,
};

Shader_Stage_Desc :: struct {
    source:         cstring,
    byte_code:      ^u8,
    byte_code_size: c.int,
    entry:          cstring,
    uniform_blocks: [MAX_SHADERSTAGE_UBS]Shader_Uniform_Block_Desc,
    images:         [MAX_SHADERSTAGE_IMAGES]Shader_Image_Desc,
};

Shader_Desc :: struct {
    _start_canary: u32,
    attrs:         [MAX_VERTEX_ATTRIBUTES]Shader_Attr_Desc,
    vs:            Shader_Stage_Desc,
    fs:            Shader_Stage_Desc,
    label:         cstring,
    _end_canary:   u32,
};

/*
    pipeline_desc

    The pipeline_desc struct defines all creation parameters
    for an pipeline object, used as argument to the
    make_pipeline() function:

    - the vertex layout for all input vertex buffers
    - a shader object
    - the 3D primitive type (points, lines, triangles, ...)
    - the index type (none, 16- or 32-bit)
    - depth-stencil state
    - alpha-blending state
    - rasterizer state

    If the vertex data has no gaps between vertex components, you can omit
    the .layout.buffers[].stride and layout.attrs[].offset items (leave them
    default-initialized to 0), sokol will then compute the offsets and strides
    from the vertex component formats (.layout.attrs[].offset). Please note
    that ALL vertex attribute offsets must be 0 in order for the the
    automatic offset computation to kick in.

    The default configuration is as follows:

    .layout:
        .buffers[]:         vertex buffer layouts
            .stride:        0 (if no stride is given it will be computed)
            .step_func      VERTEXSTEP_PER_VERTEX
            .step_rate      1
        .attrs[]:           vertex attribute declarations
            .buffer_index   0 the vertex buffer bind slot
            .offset         0 (offsets can be omitted if the vertex layout has no gaps)
            .format         VERTEXFORMAT_INVALID (must be initialized!)
    .shader:            0 (must be intilized with a valid shader id!)
    .primitive_type:    PRIMITIVETYPE_TRIANGLES
    .index_type:        INDEXTYPE_NONE
    .depth_stencil:
        .stencil_front, .stencil_back:
            .fail_op:               STENCILOP_KEEP
            .depth_fail_op:         STENCILOP_KEEP
            .pass_op:               STENCILOP_KEEP
            .compare_func           COMPAREFUNC_ALWAYS
        .depth_compare_func:    COMPAREFUNC_ALWAYS
        .depth_write_enabled:   false
        .stencil_enabled:       false
        .stencil_read_mask:     0
        .stencil_write_mask:    0
        .stencil_ref:           0
    .blend:
        .enabled:               false
        .src_factor_rgb:        BLENDFACTOR_ONE
        .dst_factor_rgb:        BLENDFACTOR_ZERO
        .op_rgb:                BLENDOP_ADD
        .src_factor_alpha:      BLENDFACTOR_ONE
        .dst_factor_alpha:      BLENDFACTOR_ZERO
        .op_alpha:              BLENDOP_ADD
        .color_write_mask:      COLORMASK_RGBA
        .color_attachment_count 1
        .color_format           PIXELFORMAT_RGBA8
        .depth_format           PIXELFORMAT_DEPTHSTENCIL
        .blend_color:           { 0.0f, 0.0f, 0.0f, 0.0f }
    .rasterizer:
        .alpha_to_coverage_enabled:     false
        .cull_mode:                     CULLMODE_NONE
        .face_winding:                  FACEWINDING_CW
        .sample_count:                  1
        .depth_bias:                    0.0f
        .depth_bias_slope_scale:        0.0f
        .depth_bias_clamp:              0.0f
    .label  0       (optional string label for trace hooks)
*/
Buffer_Layout_Desc :: struct {
    stride:    c.int,
    step_func: Vertex_Step,
    step_rate: c.int,
};

Vertex_Attr_Desc :: struct {
    buffer_index: c.int,
    offset:       c.int,
    format:       Vertex_Format,
};

Layout_Desc :: struct {
    buffers: [MAX_SHADERSTAGE_BUFFERS]Buffer_Layout_Desc,
    attrs:   [MAX_VERTEX_ATTRIBUTES]Vertex_Attr_Desc,
};

Stencil_State :: struct {
    fail_op:       Stencil_Op,
    depth_fail_op: Stencil_Op,
    pass_op:       Stencil_Op,
    compare_func:  Compare_Func,
};

Depth_Stencil_State :: struct {
    stencil_front:       Stencil_State,
    stencil_back:        Stencil_State,
    depth_compare_func:  Compare_Func,
    depth_write_enabled: bool,
    stencil_enabled:     bool,
    stencil_read_mask:   u8,
    stencil_write_mask:  u8,
    stencil_ref:         u8,
};

Blend_State :: struct {
    enabled:                bool,
    src_factor_rgb:         Blend_Factor,
    dst_factor_rgb:         Blend_Factor,
    op_rgb:                 Blend_Op,
    src_factor_alpha:       Blend_Factor,
    dst_factor_alpha:       Blend_Factor,
    op_alpha:               Blend_Op,
    color_write_mask:       u8,
    color_attachment_count: c.int,
    color_format:           Pixel_Format,
    depth_format:           Pixel_Format,
    blend_color:            [4]f32,
};

Rasterizer_State :: struct {
    alpha_to_coverage_enabled: bool,
    cull_mode:                 Cull_Mode,
    face_winding:              Face_Winding,
    sample_count:              c.int,
    depth_bias:                f32,
    depth_bias_slope_scale:    f32,
    depth_bias_clamp:          f32,
};

Pipeline_Desc :: struct {
    _start_canary:  u32,
    layout:         Layout_Desc,
    shader:         Shader,
    primitive_type: Primitive_Type,
    index_type:     Index_Type,
    depth_stencil:  Depth_Stencil_State,
    blend:          Blend_State,
    rasterizer:     Rasterizer_State,
    label:          cstring,
    _end_canary:    u32,
};

/*
    pass_desc

    Creation parameters for an pass object, used as argument
    to the make_pass() function.

    A pass object contains 1..4 color-attachments and none, or one,
    depth-stencil-attachment. Each attachment consists of
    an image, and two additional indices describing
    which subimage the pass will render: one mipmap index, and
    if the image is a cubemap, array-texture or 3D-texture, the
    face-index, array-layer or depth-slice.

    Pass images must fulfill the following requirements:

    All images must have:
    - been created as render target (sg_image_desc.render_target = true)
    - the same size
    - the same sample count

    In addition, all color-attachment images must have the same
    pixel format.
*/
Attachment_Desc :: struct {
    image: Image,
    mip_level: c.int,
    using data: struct #raw_union {
        face:  c.int,
        layer: c.int,
        slice: c.int,
    },
};

Pass_Desc :: struct {
    _start_canary:            u32,
    color_attachments:        [MAX_COLOR_ATTACHMENTS]Attachment_Desc,
    depth_stencil_attachment: Attachment_Desc,
    label:                    cstring,
    _end_canary:              u32,
};

/*
    Trace_Hooks

    Installable callback functions to keep track of the sokol_gfx calls,
    this is useful for debugging, or keeping track of resource creation
    and destruction.

    Trace hooks are installed with install_trace_hooks(), this returns
    another trace_hooks struct with the previous set of
    trace hook function pointers. These should be invoked by the
    new trace hooks to form a proper call chain.
*/
Trace_Hooks :: struct {
    user_data: rawptr,
    reset_state_cache:           proc "c" (user_data: rawptr),
    make_buffer:                 proc "c" (desc: ^Buffer_Desc,   result: Buffer,   user_data: rawptr),
    make_image:                  proc "c" (desc: ^Image_Desc,    result: Image,    user_data: rawptr),
    make_shader:                 proc "c" (desc: ^Shader_Desc,   result: Shader,   user_data: rawptr),
    make_pipeline:               proc "c" (desc: ^Pipeline_Desc, result: Pipeline, user_data: rawptr),
    make_pass:                   proc "c" (desc: ^Pass_Desc,     result: Pass,     user_data: rawptr),
    destroy_buffer:              proc "c" (buf: Buffer,   user_data: rawptr),
    destroy_image:               proc "c" (img: Image,    user_data: rawptr),
    destroy_shader:              proc "c" (shd: Shader,   user_data: rawptr),
    destroy_pipeline:            proc "c" (pip: Pipeline, user_data: rawptr),
    destroy_pass:                proc "c" (pass: Pass,    user_data: rawptr),
    update_buffer:               proc "c" (buf: Buffer, data_ptr: rawptr, data_size: c.int, user_data: rawptr),
    update_image:                proc "c" (img: Image, data: ^Image_Content, user_data: rawptr),
    append_buffer:               proc "c" (buf: Buffer, data_ptr: rawptr, data_size: c.int, result: c.int, user_data: rawptr),
    begin_default_pass:          proc "c" (pass_action: ^Pass_Action, width, height: c.int, user_data: rawptr),
    begin_pass:                  proc "c" (pass: Pass, pass_action: ^Pass_Action, user_data: rawptr),
    apply_viewport:              proc "c" (x, y, width, height: c.int, origin_top_left: bool, user_data: rawptr),
    apply_scissor_rect:          proc "c" (x, y, width, height: c.int, origin_top_left: bool, user_data: rawptr),
    apply_pipeline:              proc "c" (pip: Pipeline, user_data: rawptr),
    apply_bindings:              proc "c" (bindings: ^Bindings, user_data: rawptr),
    apply_uniforms:              proc "c" (stage: Shader_Stage, ub_index: c.int, data: rawptr, num_bytes: c.int, user_data: rawptr),
    draw:                        proc "c" (base_element, num_elements, num_instances: c.int, user_data: rawptr),
    end_pass:                    proc "c" (user_data: rawptr),
    commit:                      proc "c" (user_data: rawptr),
    alloc_buffer:                proc "c" (result: Buffer,   user_data: rawptr),
    alloc_image:                 proc "c" (result: Image,    user_data: rawptr),
    alloc_shader:                proc "c" (result: Shader,   user_data: rawptr),
    alloc_pipeline:              proc "c" (result: Pipeline, user_data: rawptr),
    alloc_pass:                  proc "c" (result: Pass,     user_data: rawptr),
    init_buffer:                 proc "c" (buf_id: Buffer,    desc: ^Buffer_Desc,   user_data: rawptr),
    init_image:                  proc "c" (img_id: Image,     desc: ^Image_Desc,    user_data: rawptr),
    init_shader:                 proc "c" (shd_id: Shader,    desc: ^Shader_Desc,   user_data: rawptr),
    init_pipeline:               proc "c" (pip_id: Pipeline,  desc: ^Pipeline_Desc, user_data: rawptr),
    init_pass:                   proc "c" (pass_id: Pass,     desc: ^Pass_Desc,     user_data: rawptr),
    fail_buffer:                 proc "c" (buf_id: Buffer,   user_data: rawptr),
    fail_image:                  proc "c" (img_id: Image,    user_data: rawptr),
    fail_shader:                 proc "c" (shd_id: Shader,   user_data: rawptr),
    fail_pipeline:               proc "c" (pip_id: Pipeline, user_data: rawptr),
    fail_pass:                   proc "c" (pass_id: Pass,    user_data: rawptr),
    push_debug_group:            proc "c" (name: cstring,    user_data: rawptr),
    pop_debug_group:             proc "c" (user_data: rawptr),
    err_buffer_pool_exhausted:   proc "c" (user_data: rawptr),
    err_image_pool_exhausted:    proc "c" (user_data: rawptr),
    err_shader_pool_exhausted:   proc "c" (user_data: rawptr),
    err_pipeline_pool_exhausted: proc "c" (user_data: rawptr),
    err_pass_pool_exhausted:     proc "c" (user_data: rawptr),
    err_context_mismatch:        proc "c" (user_data: rawptr),
    err_pass_invalid:            proc "c" (user_data: rawptr),
    err_draw_invalid:            proc "c" (user_data: rawptr),
    err_bindings_invalid:        proc "c" (user_data: rawptr),
};

/*
    buffer_info
    image_info
    shader_info
    pipeline_info
    pass_info

    These structs contain various internal resource attributes which
    might be useful for debug-inspection. Please don't rely on the
    actual content of those structs too much, as they are quite closely
    tied to sokol_gfx.h internals and may change more frequently than
    the other public API elements.

    The *_info structs are used as the return values of the following functions:

    query_buffer_info()
    query_image_info()
    query_shader_info()
    query_pipeline_info()
    query_pass_info()
*/
Slot_Info :: struct {
    state: Resource_State, /* the current state of this resource slot */
    res_id: u32,           /* type-neutral resource if (e.g. buffer.id) */
    ctx_id: u32,           /* the context this resource belongs to */
};

Buffer_Info :: struct {
    slot:               Slot_Info, /* resource pool slot info */
    update_frame_index: u32,       /* frame index of last update_buffer() */
    append_frame_index: u32,       /* frame index of last append_buffer() */
    append_pos:         c.int,     /* current position in buffer for append_buffer() */
    append_overflow:    bool,      /* is buffer in overflow state (due to append_buffer) */
    num_slots:          c.int,     /* number of renaming-slots for dynamically updated buffers */
    active_slot:        c.int,     /* currently active write-slot for dynamically updated buffers */
};

Image_Info :: struct {
    slot:            Slot_Info, /* resource pool slot info */
    upd_frame_index: u32,       /* frame index of last update_image() */
    num_slots:       c.int,     /* number of renaming-slots for dynamically updated images */
    active_slot:     c.int,     /* currently active write-slot for dynamically updated images */
};

Shader_Info :: struct {
    slot: Slot_Info, /* resoure pool slot info */
};

Pipeline_Info :: struct {
    slot: Slot_Info, /* resource pool slot info */
};

Pass_Info :: struct {
    slot: Slot_Info, /* resource pool slot info */
};

/*
    desc

    The desc struct contains configuration values for sokol_gfx,
    it is used as parameter to the setup() call.

    The default configuration is:

    .buffer_pool_size:      128
    .image_pool_size:       128
    .shader_pool_size:      32
    .pipeline_pool_size:    64
    .pass_pool_size:        16
    .context_pool_size:     16

    GL specific:
    .gl_force_gles2
        if this is true the GL backend will act in "GLES2 fallback mode" even
        when compiled with SOKOL_GLES3, this is useful to fall back
        to traditional WebGL if a browser doesn't support a WebGL2 context

    Metal specific:
        (NOTE: All Objective-C object references are transferred through
        a bridged (const void*) to sokol_gfx, which will use a unretained
        bridged cast (__bridged id<xxx>) to retrieve the Objective-C
        references back. Since the bridge cast is unretained, the caller
        must hold a strong reference to the Objective-C object for the
        duration of the sokol_gfx call!

    .mtl_device
        a pointer to the MTLDevice object
    .mtl_renderpass_descriptor_cb
        a C callback function to obtain the MTLRenderPassDescriptor for the
        current frame when rendering to the default framebuffer, will be called
        in begin_default_pass()
    .mtl_drawable_cb
        a C callback function to obtain a MTLDrawable for the current
        frame when rendering to the default framebuffer, will be called in
        end_pass() of the default pass
    .mtl_global_uniform_buffer_size
        the size of the global uniform buffer in bytes, this must be big
        enough to hold all uniform block updates for a single frame,
        the default value is 4 MByte (4 * 1024 * 1024)
    .mtl_sampler_cache_size
        the number of slots in the sampler cache, the Metal backend
        will share texture samplers with the same state in this
        cache, the default value is 64

    D3D11 specific:
    .d3d11_device
        a pointer to the ID3D11Device object, this must have been created
        before setup() is called
    .d3d11_device_context
        a pointer to the ID3D11DeviceContext object
    .d3d11_render_target_view_cb
        a C callback function to obtain a pointer to the current
        ID3D11RenderTargetView object of the default framebuffer,
        this function will be called in begin_pass() when rendering
        to the default framebuffer
    .d3d11_depth_stencil_view_cb
        a C callback function to obtain a pointer to the current
        ID3D11DepthStencilView object of the default framebuffer,
        this function will be called in begin_pass() when rendering
        to the default framebuffer
*/
Desc :: struct {
    _start_canary:                  u32,
    buffer_pool_size:               c.int,
    image_pool_size:                c.int,
    shader_pool_size:               c.int,
    pipeline_pool_size:             c.int,
    pass_pool_size:                 c.int,
    context_pool_size:              c.int,
    /* GL specific */
    gl_force_gles2:                 bool,
    /* Metal-specific */
    mtl_device:                     rawptr,
    mtl_renderpass_descriptor_cb:   proc "c" () -> rawptr,
    mtl_drawable_cb:                proc "c" () -> rawptr,
    mtl_global_uniform_buffer_size: c.int,
    mtl_sampler_cache_size:         c.int,
    /* D3D11-specific */
    d3d11_device:                   rawptr,
    d3d11_device_context:           rawptr,
    d3d11_render_target_view_cb:    proc "c" () -> rawptr,
    d3d11_depth_stencil_view_cb:    proc "c" () -> rawptr,
    _end_canary:                    u32,
};
