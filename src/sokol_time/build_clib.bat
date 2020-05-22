@echo off
setlocal

cl /DNDEBUG /O2 /c /Fosokol_time_d3d11.obj sokol_time_d3d11.c
lib /out:sokol_time_d3d11.lib sokol_time_d3d11.obj

del *.obj
