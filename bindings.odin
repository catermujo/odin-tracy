package tracy

@(require) import "core:c"

when ODIN_OS == .Darwin {
    foreign import tracy "tracy.dylib"
} else when ODIN_OS == .Windows {
    foreign import tracy "tracy.lib"
} else when ODIN_OS == .Linux {
    foreign import tracy "tracy.so"
}

TracyPlotFormat :: enum i32 {
    number,
    memory,
    percentage,
    watt,
}

SourceLocation :: struct {
    name:     cstring,
    function: cstring,
    file:     cstring,
    line:     u32,
    color:    u32,
}

ZoneCtx :: struct {
    id:     u32,
    active: b32,
}

GpuTime :: struct {
    gpuTime: i64,
    queryId: u16,
    ctx:     u8,
}

GpuZoneBegin :: struct {
    srcloc:  u64,
    queryId: u16,
    ctx:     u8,
}

GpuZoneBeginCallstack :: struct {
    srcloc:  u64,
    depth:   i32,
    queryId: u16,
    ctx:     u8,
}

GpuZoneEnd :: struct {
    queryId: u16,
    ctx:     u8,
}

GpuNewContext :: struct {
    gpuTime: i64,
    period:  f32,
    ctx:     u8,
    flags:   u8,
    type:    u8,
}

GpuContextName :: struct {
    ctx:  u8,
    name: cstring,
    len:  u16,
}

GpuCalibration :: struct {
    gpuTime:  i64,
    cpuDelta: i64,
    ctx:      u8,
}

GpuTimeSync :: struct {
    gpuTime: i64,
    ctx:     u8,
}

LockCtx :: struct {}

when #config(TRACY_MANUAL_LIFETIME, false) {
    @(default_calling_convention = "c")
    foreign tracy {
        startup_profiler :: proc() ---
        shutdown_profiler :: proc() ---
        profiler_started :: proc() -> b32 ---
    }
}

@(default_calling_convention = "c", link_prefix = "___tracy_")
foreign tracy {
    emit_gpu_zone_begin :: proc(_: GpuZoneBegin) ---
    emit_gpu_zone_begin_callstack :: proc(_: GpuZoneBeginCallstack) ---
    emit_gpu_zone_begin_alloc :: proc(_: GpuZoneBegin) ---
    emit_gpu_zone_begin_alloc_callstack :: proc(_: GpuZoneBeginCallstack) ---
    emit_gpu_zone_end :: proc(_: GpuZoneEnd) ---
    emit_gpu_time :: proc(_: GpuTime) ---
    emit_gpu_new_context :: proc(_: GpuNewContext) ---
    emit_gpu_context_name :: proc(_: GpuContextName) ---
    emit_gpu_calibration :: proc(_: GpuCalibration) ---
    emit_gpu_time_sync :: proc(_: GpuTimeSync) ---

    emit_gpu_zone_begin_serial :: proc(_: GpuZoneBegin) ---
    emit_gpu_zone_begin_callstack_serial :: proc(_: GpuZoneBeginCallstack) ---
    emit_gpu_zone_begin_alloc_serial :: proc(_: GpuZoneBegin) ---
    emit_gpu_zone_begin_alloc_callstack_serial :: proc(_: GpuZoneBeginCallstack) ---
    emit_gpu_zone_end_serial :: proc(_: GpuZoneEnd) ---
    emit_gpu_time_serial :: proc(_: GpuTime) ---
    emit_gpu_new_context_serial :: proc(_: GpuNewContext) ---
    emit_gpu_context_name_serial :: proc(_: GpuContextName) ---
    emit_gpu_calibration_serial :: proc(_: GpuCalibration) ---
    emit_gpu_time_sync_serial :: proc(_: GpuTimeSync) ---
}


@(default_calling_convention = "c", link_prefix = "___tracy", private)
foreign tracy {
    _set_thread_name :: proc(name: cstring) ---

    _alloc_srcloc :: proc(line: u32, source: cstring, sourceSz: c.size_t, function: cstring, functionSz: c.size_t, color: u32 = 0) -> u64 ---
    _alloc_srcloc_name :: proc(line: u32, source: cstring, sourceSz: c.size_t, function: cstring, functionSz: c.size_t, name: cstring, nameSz: c.size_t, color: u32 = 0) -> u64 ---

    _emit_zone_begin :: proc(srcloc: ^SourceLocation, active: b32) -> ZoneCtx ---
    _emit_zone_begin_callstack :: proc(srcloc: ^SourceLocation, depth: i32, active: b32) -> ZoneCtx ---
    _emit_zone_begin_alloc :: proc(srcloc: u64, active: b32) -> ZoneCtx ---
    _emit_zone_begin_alloc_callstack :: proc(srcloc: u64, depth: i32, active: b32) -> ZoneCtx ---
    _emit_zone_end :: proc(ctx: ZoneCtx) ---
    _emit_zone_text :: proc(ctx: ZoneCtx, txt: cstring, size: c.size_t) ---
    _emit_zone_name :: proc(ctx: ZoneCtx, txt: cstring, size: c.size_t) ---
    _emit_zone_color :: proc(ctx: ZoneCtx, color: u32) ---
    _emit_zone_value :: proc(ctx: ZoneCtx, value: u64) ---

    _connected :: proc() -> b32 ---

    _emit_memory_alloc :: proc(ptr: rawptr, size: c.size_t, secure: b32) ---
    _emit_memory_alloc_callstack :: proc(ptr: rawptr, size: c.size_t, depth: i32, secure: b32) ---
    _emit_memory_free :: proc(ptr: rawptr, secure: b32) ---
    _emit_memory_free_callstack :: proc(ptr: rawptr, depth: i32, secure: b32) ---
    _emit_memory_alloc_named :: proc(ptr: rawptr, size: c.size_t, secure: b32, name: cstring) ---
    _emit_memory_alloc_callstack_named :: proc(ptr: rawptr, size: c.size_t, depth: i32, secure: b32, name: cstring) ---
    _emit_memory_free_named :: proc(ptr: rawptr, secure: b32, name: cstring) ---
    _emit_memory_free_callstack_named :: proc(ptr: rawptr, depth: i32, secure: b32, name: cstring) ---

    _emit_message :: proc(txt: cstring, size: c.size_t, callstack: i32) ---
    _emit_messageL :: proc(txt: cstring, callstack: i32) ---
    _emit_messageC :: proc(txt: cstring, size: c.size_t, color: u32, callstack: i32) ---
    _emit_messageLC :: proc(txt: cstring, color: u32, callstack: i32) ---

    _emit_frame_mark :: proc(name: cstring) ---
    _emit_frame_mark_start :: proc(name: cstring) ---
    _emit_frame_mark_end :: proc(name: cstring) ---
    _emit_frame_image :: proc(image: rawptr, w, h: u16, offset: u8, flip: b32) ---

    _emit_plot :: proc(name: cstring, val: f64) ---
    _emit_plot_float :: proc(name: cstring, val: f32) ---
    _emit_plot_int :: proc(name: cstring, val: i64) ---
    _emit_plot_config :: proc(name: cstring, type: TracyPlotFormat, step, fill: b32, color: u32) ---
    _emit_message_appinfo :: proc(txt: cstring, size: c.size_t) ---

    _announce_lockable_ctx :: proc(srcloc: ^SourceLocation) -> ^LockCtx ---
    _terminate_lockable_ctx :: proc(lockdata: ^LockCtx) ---
    _before_lock_lockable_ctx :: proc(lockdata: ^LockCtx) -> b32 ---
    _after_lock_lockable_ctx :: proc(lockdata: ^LockCtx) ---
    _after_unlock_lockable_ctx :: proc(lockdata: ^LockCtx) ---
    _after_try_lock_lockable_ctx :: proc(lockdata: ^LockCtx, acquired: b32) ---
    _mark_lockable_ctx :: proc(lockdata: ^LockCtx, srcloc: ^SourceLocation) ---
    _custom_name_lockable_ctx :: proc(lockdata: ^LockCtx, name: cstring, nameSz: c.size_t) ---
}

when TRACY_FIBERS {
    @(default_calling_convention = "c", link_prefix = "___tracy_")
    foreign tracy {
        _fiber_enter :: proc(fiber: cstring) ---
        _fiber_leave :: proc() ---
    }
}

