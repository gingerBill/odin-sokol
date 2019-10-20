package sokol_app

when ODIN_OS == "windows" do foreign import sapp_lib "sokol_app_d3d11.lib"

import "core:c"

c_int :: c.int;

MAX_TOUCHPOINTS  :: 8;
MAX_MOUSEBUTTONS :: 3;
MAX_KEYCODES     :: 512;

Event_Type :: enum i32 {
    INVALID,
    KEY_DOWN,
    KEY_UP,
    CHAR,
    MOUSE_DOWN,
    MOUSE_UP,
    MOUSE_SCROLL,
    MOUSE_MOVE,
    MOUSE_ENTER,
    MOUSE_LEAVE,
    TOUCHES_BEGAN,
    TOUCHES_MOVED,
    TOUCHES_ENDED,
    TOUCHES_CANCELLED,
    RESIZED,
    ICONIFIED,
    RESTORED,
    SUSPENDED,
    RESUMED,
    UPDATE_CURSOR,
    QUIT_REQUESTED,
};

/* key codes are the same names and values as GLFW */
Key_Code :: enum i32 {
    INVALID          = 0,
    SPACE            = 32,
    APOSTROPHE       = 39,  /* ' */
    COMMA            = 44,  /* , */
    MINUS            = 45,  /* - */
    PERIOD           = 46,  /* . */
    SLASH            = 47,  /* / */
    NUM_0            = 48,
    NUM_1            = 49,
    NUM_2            = 50,
    NUM_3            = 51,
    NUM_4            = 52,
    NUM_5            = 53,
    NUM_6            = 54,
    NUM_7            = 55,
    NUM_8            = 56,
    NUM_9            = 57,
    SEMICOLON        = 59,  /* ; */
    EQUAL            = 61,  /* = */
    A                = 65,
    B                = 66,
    C                = 67,
    D                = 68,
    E                = 69,
    F                = 70,
    G                = 71,
    H                = 72,
    I                = 73,
    J                = 74,
    K                = 75,
    L                = 76,
    M                = 77,
    N                = 78,
    O                = 79,
    P                = 80,
    Q                = 81,
    R                = 82,
    S                = 83,
    T                = 84,
    U                = 85,
    V                = 86,
    W                = 87,
    X                = 88,
    Y                = 89,
    Z                = 90,
    LEFT_BRACKET     = 91,  /* [ */
    BACKSLASH        = 92,  /* \ */
    RIGHT_BRACKET    = 93,  /* ] */
    GRAVE_ACCENT     = 96,  /* ` */
    WORLD_1          = 161, /* non-US #1 */
    WORLD_2          = 162, /* non-US #2 */
    ESCAPE           = 256,
    ENTER            = 257,
    TAB              = 258,
    BACKSPACE        = 259,
    INSERT           = 260,
    DELETE           = 261,
    RIGHT            = 262,
    LEFT             = 263,
    DOWN             = 264,
    UP               = 265,
    PAGE_UP          = 266,
    PAGE_DOWN        = 267,
    HOME             = 268,
    END              = 269,
    CAPS_LOCK        = 280,
    SCROLL_LOCK      = 281,
    NUM_LOCK         = 282,
    PRINT_SCREEN     = 283,
    PAUSE            = 284,
    F1               = 290,
    F2               = 291,
    F3               = 292,
    F4               = 293,
    F5               = 294,
    F6               = 295,
    F7               = 296,
    F8               = 297,
    F9               = 298,
    F10              = 299,
    F11              = 300,
    F12              = 301,
    F13              = 302,
    F14              = 303,
    F15              = 304,
    F16              = 305,
    F17              = 306,
    F18              = 307,
    F19              = 308,
    F20              = 309,
    F21              = 310,
    F22              = 311,
    F23              = 312,
    F24              = 313,
    F25              = 314,
    KP_0             = 320,
    KP_1             = 321,
    KP_2             = 322,
    KP_3             = 323,
    KP_4             = 324,
    KP_5             = 325,
    KP_6             = 326,
    KP_7             = 327,
    KP_8             = 328,
    KP_9             = 329,
    KP_DECIMAL       = 330,
    KP_DIVIDE        = 331,
    KP_MULTIPLY      = 332,
    KP_SUBTRACT      = 333,
    KP_ADD           = 334,
    KP_ENTER         = 335,
    KP_EQUAL         = 336,
    LEFT_SHIFT       = 340,
    LEFT_CONTROL     = 341,
    LEFT_ALT         = 342,
    LEFT_SUPER       = 343,
    RIGHT_SHIFT      = 344,
    RIGHT_CONTROL    = 345,
    RIGHT_ALT        = 346,
    RIGHT_SUPER      = 347,
    MENU             = 348,
};

Touchpoint :: struct {
    identifier: rawptr,
    pos_x:      f32,
    pos_y:      f32,
    changed:    bool,
};

Mouse_Button :: enum i32 {
    INVALID = -1,
    LEFT    = 0,
    RIGHT   = 1,
    MIDDLE  = 2,
};

Modifier :: enum u32 {
    SHIFT = 0,
    CTRL  = 1,
    ALT   = 2,
    SUPER = 3,
}
Modifier_Set :: distinct bit_set[Modifier; u32];

Event :: struct {
    frame_count:        u64,
    type:               Event_Type,
    key_code:           Key_Code,
    char_code:          rune,
    key_repeat:         bool,
    modifiers:          Modifier_Set,
    mouse_button:       Mouse_Button,
    mouse_x:            f32,
    mouse_y:            f32,
    scroll_x:           f32,
    scroll_y:           f32,
    num_touches:        c_int,
    touches:            [MAX_TOUCHPOINTS]Touchpoint,
    window_width:       c_int,
    window_height:      c_int,
    framebuffer_width:  c_int,
    framebuffer_height: c_int,
};

Desc :: struct {
    init_cb:    proc "c" (), /* these are the user-provided callbacks without user data */
    frame_cb:   proc "c" (),
    cleanup_cb: proc "c" (),
    event_cb:   proc "c" (e: ^Event),
    fail_cb:    proc "c" (msg: cstring),

    user_data:           rawptr, /* these are the user-provided callbacks with user data */
    init_userdata_cb:    proc "c" (user_data: rawptr),
    frame_userdata_cb:   proc "c" (user_data: rawptr),
    cleanup_userdata_cb: proc "c" (user_data: rawptr),
    event_userdata_cb:   proc "c" (e: ^Event, user_data: rawptr),
    fail_userdata_cb:    proc "c" (msg: cstring,  user_data: rawptr),

    width:         c_int,                   /* the preferred width of the window / canvas */
    height:        c_int,                   /* the preferred height of the window / canvas */
    sample_count:  c_int,                   /* MSAA sample count */
    swap_interval: c_int,                   /* the preferred swap interval (ignored on some platforms) */
    high_dpi:      bool,                    /* whether the rendering canvas is full-resolution on HighDPI displays */
    fullscreen:    bool,                    /* whether the window should be created in fullscreen mode */
    alpha:         bool,                    /* whether the framebuffer should have an alpha channel (ignored on some platforms) */
    window_title:  cstring,                 /* the window title as UTF-8 encoded string */
    user_cursor:   bool,                    /* if true, user is expected to manage cursor image in EVENTTYPE_UPDATE_CURSOR */

    html5_canvas_name:             cstring, /* the name (id) of the HTML5 canvas element, default is "canvas" */
    html5_canvas_resize:           bool,    /* if true, the HTML5 canvas size is set to desc.width/height, otherwise canvas size is tracked */
    html5_preserve_drawing_buffer: bool,    /* HTML5 only: whether to preserve default framebuffer content between frames */
    html5_premultiplied_alpha:     bool,    /* HTML5 only: whether the rendered pixels use premultiplied alpha convention */
    html5_ask_leave_site:          bool,    /* initial state of the internal html5_ask_leave_site flag (see html5_ask_leave_site()) */
    ios_keyboard_resizes_canvas:   bool,    /* if true, showing the iOS keyboard shrinks the canvas */
    gl_force_gles2:                bool,    /* if true, setup GLES2/WebGL even if GLES3/WebGL2 is available */
};

@(default_calling_convention="c")
@(link_prefix="sapp_")
foreign sapp_lib {
    /* returns true after sokol-app has been initialized */
    @(link_name="sapp_isvalid") is_valid :: proc() -> bool ---
    /* returns true when high_dpi was requested and actually running in a high-dpi scenario */
    high_dpi       :: proc() -> bool ---
    /* returns the dpi scaling factor (window pixels to framebuffer pixels) */
    dpi_scale      :: proc() -> f32 ---
    /* show or hide the mobile device onscreen keyboard */
    show_keyboard  :: proc(visible: bool) ---
    /* return true if the mobile device onscreen keyboard is currently shown */
    keyboard_shown :: proc() -> bool ---
    /* return the userdata pointer optionally provided in desc */
    userdata       :: proc() -> rawptr ---
    /* return a copy of the desc structure */
    query_desc     :: proc() -> Desc ---
    /* initiate a "soft quit" (sends EVENTTYPE_QUIT_REQUESTED) */
    request_quit   :: proc() ---
    /* cancel a pending quit (when EVENTTYPE_QUIT_REQUESTED has been received) */
    cancel_quit    :: proc() ---
    /* intiate a "hard quit" (quit application without sending EVENTTYPE_QUIT_REQUSTED) */
    quit           :: proc() ---
    /* get the current frame counter (for comparison with event.frame_count) */
    frame_count    :: proc() -> u64 ---


    /* GL: return true when GLES2 fallback is active (to detect fallback from GLES3) */
    gles2 :: proc() -> bool ---

    /* HTML5: enable or disable the hardwired "Leave Site?" dialog box */
    html5_ask_leave_site        :: proc(ask: bool) ---

    /* Metal: get ARC-bridged pointer to Metal device object */
    metal_get_device                     :: proc() -> rawptr ---
    /* Metal: get ARC-bridged pointer to this frame's renderpass descriptor */
    metal_get_renderpass_descriptor      :: proc() -> rawptr ---
    /* Metal: get ARC-bridged pointer to current drawable */
    metal_get_drawable                   :: proc() -> rawptr ---
    /* macOS: get ARC-bridged pointer to macOS NSWindow */
    macos_get_window                     :: proc() -> rawptr ---
    /* iOS: get ARC-bridged pointer to iOS UIWindow */
    ios_get_window                       :: proc() -> rawptr ---

    /* D3D11: get pointer to ID3D11Device object */
    d3d11_get_device             :: proc() -> rawptr ---
    /* D3D11: get pointer to ID3D11DeviceContext object */
    d3d11_get_device_context     :: proc() -> rawptr ---
    /* D3D11: get pointer to ID3D11RenderTargetView object */
    d3d11_get_render_target_view :: proc() -> rawptr ---
    /* D3D11: get pointer to ID3D11DepthStencilView */
    d3d11_get_depth_stencil_view :: proc() -> rawptr ---
    /* Win32: get the HWND window handle */
    win32_get_hwnd               :: proc() -> rawptr ---

    /* Android: get native activity handle */
    android_get_native_activity :: proc() -> rawptr ---
}

/* returns the current framebuffer width in pixels */
width :: proc() -> int { return int(sapp_width()); }
/* returns the current framebuffer height in pixels */
height :: proc() -> int { return int(sapp_height()); }


/* returns the current framebuffer dimensions in pixels */
framebuffer_size :: proc() -> (w, h: int) {
    return width(), height();
}

run :: proc(desc: Desc) -> int {
    d := desc;
    return int(sapp_run(&d));
}


@(default_calling_convention="c")
foreign sapp_lib {
    /* returns the current framebuffer width in pixels */
    sapp_width  :: proc() -> c_int ---
    /* returns the current framebuffer height in pixels */
    sapp_height :: proc() -> c_int ---

    /* special run-function for SOKOL_NO_ENTRY (in standard mode this is an empty stub) */
    sapp_run :: proc(d: ^Desc) -> c_int ---
}


