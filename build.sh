PATH=/Library/Frameworks:$PATH
odin run src/main.odin -out:sokol.app -extra-linker-flags:"-framework Cocoa -framework Metal -framework MetalKit -framework QuartzCore"
