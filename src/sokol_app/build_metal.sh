# NOTE (weshardee): without this deployment target, we'll get this warning when linking:
# ld: warning: object file [...] was built for newer macOS version (11.0) than being linked (10.8)
MACOSX_DEPLOYMENT_TARGET=10.8 \
clang -c -O2 -fobjc-arc sokol_app_metal.m 
ar rcs sokol_app_metal.a sokol_app_metal.o
rm *.o
