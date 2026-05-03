package vm

import "core:fmt"
import "core:mem"

@(private="file")
tracker: mem.Tracking_Allocator

init_allocator :: proc(backing := context.allocator) -> mem.Allocator {
    mem.tracking_allocator_init(&tracker, backing)
    return mem.tracking_allocator(&tracker)
}

destroy_allocator :: proc() {
    leaks := len(tracker.allocation_map)
    bad := len(tracker.bad_free_array)

    if leaks > 0 {
        fmt.eprintfln("=== %v leaked allocations ===", leaks)
        for _, entry in tracker.allocation_map {
            fmt.eprintfln("  %v bytes @ %v", entry.size, entry.location)
        }
    }

    if bad > 0 {
        fmt.eprintfln("=== %v bad frees ===", bad)
        for entry in tracker.bad_free_array {
            fmt.eprintfln("  %v @ %v", entry.memory, entry.location)
        }
    }

    mem.tracking_allocator_destroy(&tracker)
}
