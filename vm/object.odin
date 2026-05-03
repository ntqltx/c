package vm

import "core:fmt"

ObjKind :: enum u8 {
    String = 0,
    Keyword,
}

Obj :: struct {
    kind: ObjKind,
}

ObjString :: struct {
    using obj: Obj,
    ptr: [^]u8,
    len: uint,
}

is_string :: #force_inline proc(v: Value) -> bool {
    return is_obj(v) && as_obj(v).kind == .String
}

as_string :: #force_inline proc(v: Value) -> string {
    s := cast(^ObjString) as_obj(v)
    return string(s.ptr[:s.len])
}

print_value :: proc(v: Value) {
    switch {
        case is_number(v): fmt.print(as_number(v))
        case is_nil(v): fmt.print("nil")
        case is_bool(v): fmt.print(as_bool(v))
        case is_obj(v):
            #partial switch as_obj(v).kind {
                case .String: fmt.print(as_string(v))
            }
    }
}
