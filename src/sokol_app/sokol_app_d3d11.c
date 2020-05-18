#define SOKOL_IMPL
#define SOKOL_NO_ENTRY
#define SOKOL_DLL
#define SOKOL_D3D11

#ifdef DEBUG
#define SOKOL_DEBUG (1)
#endif

#define SOKOL_ASSERT(cond) { \
				if (!(cond)) { \
					if (g_log_cb_app.assert_cb) { \
						g_log_cb_app.assert_cb(#cond, __FILE__, __LINE__); \
					} else { \
						assert(cond); \
					} \
				} \
			}

#define SOKOL_LOG(s) { \
				if (g_log_cb_app.log_cb) { \
					g_log_cb_app.log_cb(s); \
				} \
			}


typedef struct {
	void (*log_cb)(const char*);
	void (*assert_cb)(const char*, const char*, int);
} log_cb_app_s;

log_cb_app_s g_log_cb_app = { .log_cb = 0, .assert_cb = 0 };

__declspec(dllexport) void sokol_app_log_callback(void (*cb)(const char *)) {
	g_log_cb_app.log_cb = cb;
}
__declspec(dllexport) void sokol_app_assert_callback(void (*cb)(const char *, const char *, int)) {
	g_log_cb_app.assert_cb = cb;
}


#include <assert.h>
#include <stdio.h>
#include "sokol_app.h"
