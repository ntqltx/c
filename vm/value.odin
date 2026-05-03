package vm

QNAN      :: u64(0x7FFC_0000_0000_0000)
SIGN_BIT  :: u64(0x8000_0000_0000_0000)
TAG_NIL   :: u64(1)
TAG_FALSE :: u64(2)
TAG_TRUE  :: u64(3)
PTR_MASK  :: u64(0x0000_FFFF_FFFF_FFFF)

Value :: distinct u64
ValueArray :: [dynamic]Value

NIL_VAL   :: Value(QNAN | TAG_NIL)
TRUE_VAL  :: Value(QNAN | TAG_TRUE)
FALSE_VAL :: Value(QNAN | TAG_FALSE)

number_val :: #force_inline proc(n: f64) -> Value {
    return Value(transmute(u64) n)
}
bool_val :: #force_inline proc(b: bool) -> Value {
    return TRUE_VAL if b else FALSE_VAL
}
obj_val :: #force_inline proc(p: ^Obj) -> Value {
    return Value(SIGN_BIT | QNAN | u64(uintptr(p)))
}

is_number :: #force_inline proc(v: Value) -> bool {
    return (u64(v) & QNAN) != QNAN
}
is_bool :: #force_inline proc(v: Value) -> bool {
    return (u64(v) | 1) == u64(TRUE_VAL)
}
is_obj :: #force_inline proc(v: Value) -> bool {
    return (u64(v) & (SIGN_BIT | QNAN)) == (SIGN_BIT | QNAN)
}
is_nil :: #force_inline proc(v: Value) -> bool {
    return v == NIL_VAL
}

as_number :: #force_inline proc(v: Value) -> f64 {
    return transmute(f64) u64(v)
}
as_bool :: #force_inline proc(v: Value) -> bool {
    return v == TRUE_VAL
}
as_obj :: #force_inline proc(v: Value) -> ^Obj {
    return cast(^Obj) uintptr(u64(v) & PTR_MASK)
}