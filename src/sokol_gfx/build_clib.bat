@echo off
setlocal

cl /DDEBUG /c /Zi /Fosokol_gfx_d3d11d.obj /Fdsokol_gfx_d3d11d.pdb sokol_app_d3d11.c
lib /out:sokol_gfx_d3d11d.lib sokol_gfx_d3d11d.obj

cl /DNDEBUG /O2 /c /Fosokol_gfx_d3d11.obj sokol_app_d3d11.c
lib /out:sokol_gfx_d3d11.lib sokol_gfx_d3d11.obj

del *.obj
