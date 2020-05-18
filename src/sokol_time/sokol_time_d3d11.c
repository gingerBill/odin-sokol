#define SOKOL_IMPL
#define SOKOL_DLL
#define SOKOL_D3D11

#define SOKOL_ASSERT(cond) { \
				if (!(cond)) { \
					if (g_log_cb_time.assert_cb) { \
						g_log_cb_time.assert_cb(#cond, __FILE__, __LINE__); \
					} else { \
						assert(cond); \
					} \
				} \
			}

typedef struct {
	void (*assert_cb)(const char*, const char*, int);
} log_cb_time_s;

log_cb_time_s g_log_cb_time = { .assert_cb = 0 };

__declspec(dllexport) void sokol_time_assert_callback(void (*cb)(const char *, const char *, int)) {
	g_log_cb_time.assert_cb = cb;
}

#include <assert.h>
#include "sokol_time.h"
