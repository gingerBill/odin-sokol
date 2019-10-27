package sokol_time

when ODIN_OS == "windows" do foreign import stime_lib "sokol_time_d3d11.lib"

import "core:c"

@(default_calling_convention="c")
@(link_prefix="stm_")
foreign stime_lib {
    setup :: proc() ---
    now :: proc() -> u64 ---
    diff :: proc(new: u64, old: u64) -> u64 ---
    since :: proc(start: u64) -> u64 ---
    laptime :: proc(last_time: ^u64) -> u64 ---

    sec :: proc(ticks: u64) -> f64 ---
    ms :: proc(ticks: u64) -> f64 ---
    us :: proc(ticks: u64) -> f64 ---
    ns :: proc(ticks: u64) -> f64 ---
}