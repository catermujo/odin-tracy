package tracy

import "core:c"

TRACY_ENABLE :: #config(TRACY_ENABLE, false)
TRACY_CALLSTACK :: #config(TRACY_CALLSTACK, 5)
TRACY_HAS_CALLSTACK :: #config(TRACY_HAS_CALLSTACK, true)
TRACY_FIBERS :: #config(TRACY_FIBERS, false)

// zone markup

// NOTE: These automatically calls ZoneEnd() at end of scope.
@(deferred_out = zone_end)
zone :: #force_inline proc(
    active := true,
    depth: i32 = TRACY_CALLSTACK,
    loc := #caller_location,
) -> (
    ctx: ZoneCtx,
) { when TRACY_ENABLE { ctx = zone_begin(active, depth, loc) }; return }
@(deferred_out = zone_end)
zonen :: #force_inline proc(
    name: string,
    active := true,
    depth: i32 = TRACY_CALLSTACK,
    loc := #caller_location,
) -> (
    ctx: ZoneCtx,
) { when TRACY_ENABLE { ctx = zone_begin(active, depth, loc); zone_name(ctx, name) }; return }
@(deferred_out = zone_end)
zonec :: #force_inline proc(
    color: u32,
    active := true,
    depth: i32 = TRACY_CALLSTACK,
    loc := #caller_location,
) -> (
    ctx: ZoneCtx,
) { when TRACY_ENABLE { ctx = zone_begin(active, depth, loc); zone_color(ctx, color) }; return }
@(deferred_out = zone_end)
zonenc :: #force_inline proc(
    name: string,
    color: u32,
    active := true,
    depth: i32 = TRACY_CALLSTACK,
    loc := #caller_location,
) -> (
    ctx: ZoneCtx,
) { when TRACY_ENABLE { ctx = zone_begin(active, depth, loc); zone_name(ctx, name); zone_color(ctx, color) }; return }

// Dummy aliases to match C API (only difference is the `depth` parameter,
// which we declare as optional for the non-S procs.)
zones :: zone
zonens :: zonen
zonecs :: zonec
zonencs :: zonenc

@(disabled = !TRACY_ENABLE)
zone_text :: #force_inline proc(ctx: ZoneCtx, text: string) { _emit_zone_text(ctx, _sl(text)) }
@(disabled = !TRACY_ENABLE)
zone_name :: #force_inline proc(ctx: ZoneCtx, name: string) { _emit_zone_name(ctx, _sl(name)) }
@(disabled = !TRACY_ENABLE)
zone_color :: #force_inline proc(ctx: ZoneCtx, color: u32) { _emit_zone_color(ctx, color) }
@(disabled = !TRACY_ENABLE)
zone_value :: #force_inline proc(ctx: ZoneCtx, value: u64) { _emit_zone_value(ctx, value) }

// NOTE: scoped zone*() procs also exists, no need of calling this directly.
zone_begin :: proc(active: bool, depth: i32, loc := #caller_location) -> (ctx: ZoneCtx) {
    when TRACY_ENABLE {
        /* From manual, page 46:
		     The variable representing an allocated source location is of an opaque type.
		     After it is passed to one of the zone begin functions, its value cannot be
		     reused (the variable is consumed). You must allocate a new source location for
		     each zone begin event, even if the location data would be the same as in the
		     previous instance.
		*/
        id := _alloc_srcloc(u32(loc.line), _sl(loc.file_path), _sl(loc.procedure))
        when TRACY_HAS_CALLSTACK {
            ctx = _emit_zone_begin_alloc_callstack(id, depth, b32(active))
        } else {
            ctx = _emit_zone_begin_alloc(id, b32(active))
        }
    }
    return
}

// NOTE: scoped zone*() procs also exists, no need of calling this directly.
@(disabled = !TRACY_ENABLE)
zone_end :: #force_inline proc(ctx: ZoneCtx) { _emit_zone_end(ctx) }

// Memory profiling
// (See allocator.odin for an implementation of an Odin custom allocator using memory profiling.)
@(disabled = !TRACY_ENABLE)
alloc :: #force_inline proc(
    ptr: rawptr,
    size: c.size_t,
    depth: i32 = TRACY_CALLSTACK,
) {when TRACY_HAS_CALLSTACK { _emit_memory_alloc_callstack(ptr, size, depth, false) } else {emit_memory_alloc(
            ptr,
            size,
            false,
        )}}
@(disabled = !TRACY_ENABLE)
free :: #force_inline proc(
    ptr: rawptr,
    depth: i32 = TRACY_CALLSTACK,
) { when TRACY_HAS_CALLSTACK { _emit_memory_free_callstack(ptr, depth, false) } else { emit_memory_free(ptr, false) } }
@(disabled = !TRACY_ENABLE)
secure_alloc :: #force_inline proc(
    ptr: rawptr,
    size: c.size_t,
    depth: i32 = TRACY_CALLSTACK,
) {when TRACY_HAS_CALLSTACK { _emit_memory_alloc_callstack(ptr, size, depth, true) } else {emit_memory_alloc(
            ptr,
            size,
            true,
        )}}
@(disabled = !TRACY_ENABLE)
secure_free :: #force_inline proc(
    ptr: rawptr,
    depth: i32 = TRACY_CALLSTACK,
) { when TRACY_HAS_CALLSTACK { _emit_memory_free_callstack(ptr, depth, true) } else { emit_memory_free(ptr, true) } }
@(disabled = !TRACY_ENABLE)
allocn :: #force_inline proc(
    ptr: rawptr,
    size: c.size_t,
    name: cstring,
    depth: i32 = TRACY_CALLSTACK,
) {when TRACY_HAS_CALLSTACK {_emit_memory_alloc_callstack_named(
            ptr,
            size,
            depth,
            false,
            name,
        )} else { emit_memory_alloc_named(ptr, size, false, name) }}
@(disabled = !TRACY_ENABLE)
freen :: #force_inline proc(
    ptr: rawptr,
    name: cstring,
    depth: i32 = TRACY_CALLSTACK,
) {when TRACY_HAS_CALLSTACK { _emit_memory_free_callstack_named(
            ptr,
            depth,
            false,
            name,
        ) } else {emit_memory_free_named(ptr, false, name)}}
@(disabled = !TRACY_ENABLE)
secure_allocn :: #force_inline proc(
    ptr: rawptr,
    size: c.size_t,
    name: cstring,
    depth: i32 = TRACY_CALLSTACK,
) {when TRACY_HAS_CALLSTACK {_emit_memory_alloc_callstack_named(
            ptr,
            size,
            depth,
            true,
            name,
        )} else { emit_memory_alloc_named(ptr, size, true, name) }}
@(disabled = !TRACY_ENABLE)
secure_freen :: #force_inline proc(
    ptr: rawptr,
    name: cstring,
    depth: i32 = TRACY_CALLSTACK,
) {when TRACY_HAS_CALLSTACK { _emit_memory_free_callstack_named(ptr, depth, true, name) } else {emit_memory_free_named(
            ptr,
            true,
            name,
        )}}

// Dummy aliases to match C API (only difference is the `depth` parameter,
// which we declare as optional for the non-S procs.)
allocs :: alloc
frees :: free
secure_allocs :: secure_alloc
secure_frees :: secure_free
allocns :: allocn
freens :: freen
secure_allocns :: secure_allocn
secure_freens :: secure_freen

// Frame markup
@(disabled = !TRACY_ENABLE)
frame_mark :: #force_inline proc(name: cstring = nil) { _emit_frame_mark(name) }
@(disabled = !TRACY_ENABLE)
frame_mark_start :: #force_inline proc(name: cstring) { _emit_frame_mark_start(name) }
@(disabled = !TRACY_ENABLE)
frame_mark_end :: #force_inline proc(name: cstring) { _emit_frame_mark_end(name) }
@(disabled = !TRACY_ENABLE)
frame_image :: #force_inline proc(image: rawptr, w, h: u16, offset: u8, flip: b32) {_emit_frame_image(
        image,
        w,
        h,
        offset,
        flip,
    )}

// Plots and messages
@(disabled = !TRACY_ENABLE)
plot :: #force_inline proc(name: cstring, value: f64) { _emit_plot(name, value) }
@(disabled = !TRACY_ENABLE)
plotf :: #force_inline proc(name: cstring, value: f32) { _emit_plot_float(name, value) }
@(disabled = !TRACY_ENABLE)
ploti :: #force_inline proc(name: cstring, value: i64) { _emit_plot_int(name, value) }
@(disabled = !TRACY_ENABLE)
plot_config :: #force_inline proc(
    name: cstring,
    type: TracyPlotFormat,
    step, fill: b32,
    color: u32,
) { _emit_plot_config(name, type, step, fill, color) }
@(disabled = !TRACY_ENABLE)
message :: #force_inline proc(txt: string) { _emit_message(_sl(txt), TRACY_CALLSTACK when TRACY_HAS_CALLSTACK else 0) }
@(disabled = !TRACY_ENABLE)
messagec :: #force_inline proc(txt: string, color: u32) {_emit_message(
        _sl(txt),
        TRACY_CALLSTACK when TRACY_HAS_CALLSTACK else 0,
    )}
@(disabled = !TRACY_ENABLE)
app_info :: #force_inline proc(name: string) { _emit_message_appinfo(_sl(name)) }

@(disabled = !TRACY_ENABLE)
set_thread_name :: #force_inline proc(name: cstring) { _set_thread_name(name) }

// Connection status
is_connected :: #force_inline proc() -> bool { return bool(_connected()) when TRACY_ENABLE else false }

// Fibers
@(disabled = !TRACY_ENABLE)
fiber_enter :: #force_inline proc(name: cstring) { when TRACY_FIBERS { _fiber_enter(name) } }
@(disabled = !TRACY_ENABLE)
fiber_leave :: #force_inline proc() { when TRACY_FIBERS { _fiber_leave() } }

// Lock markup
//
// TODO(oskar): announce_lockable_ctx() and
// mark_lockable_ctx() does not provide an alloc variant to pass
// alloc_srcloc()'s allocated source locations. Casting to a pointer is
// what Tracy does internally but I don't think this is correct. We might have
// to try and find a solution for C macro local static storage somehow.
lock_announce :: #force_inline proc(loc := #caller_location) -> (ctx: ^LockCtx) {
    when TRACY_ENABLE {
        id := _alloc_srcloc(u32(loc.line), _sl(loc.file_path), _sl(loc.procedure))
        ctx = _announce_lockable_ctx((^SourceLocation)(uintptr(id)))
    }
    return
}
@(disabled = !TRACY_ENABLE)
lock_terminate :: #force_inline proc(lock: ^LockCtx) { _terminate_lockable_ctx(lock) }
@(disabled = !TRACY_ENABLE)
lock_before_lock :: #force_inline proc(lock: ^LockCtx) { _before_lock_lockable_ctx(lock) }
@(disabled = !TRACY_ENABLE)
lock_after_lock :: #force_inline proc(lock: ^LockCtx) { _after_lock_lockable_ctx(lock) }
@(disabled = !TRACY_ENABLE)
lock_after_unlock :: #force_inline proc(lock: ^LockCtx) { _after_unlock_lockable_ctx(lock) }
@(disabled = !TRACY_ENABLE)
lock_after_try_lock :: #force_inline proc(lock: ^LockCtx, acquired: bool) {_after_try_lock_lockable_ctx(
        lock,
        b32(acquired),
    )}
@(disabled = !TRACY_ENABLE)
LockMark :: #force_inline proc(lock: ^LockCtx, loc := #caller_location) {
    id := _alloc_srcloc(u32(loc.line), _sl(loc.file_path), _sl(loc.procedure))
    _mark_lockable_ctx(lock, (^SourceLocation)(uintptr(id)))
}
@(disabled = !TRACY_ENABLE)
LockCustomName :: #force_inline proc(lock: ^LockCtx, name: string) { _custom_name_lockable_ctx(lock, _sl(name)) }

// Helper for passing cstring+length to Tracy functions.
@(private = "file")
_sl :: proc(s: string) -> (cstring, c.size_t) {
    return cstring(raw_data(s)), c.size_t(len(s))
}

