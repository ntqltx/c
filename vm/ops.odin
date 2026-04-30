package vm

OpCode :: enum u8 {
    OP_CONSTANT,
    OP_ADD,
    OP_SUB,
    OP_MUL,
    OP_DIV,
    OP_NEGATE, // -x
    OP_RETURN,
}

apply :: proc(op: proc(a: Value, b: Value) -> Value) {
    b := pop(vm.stack)
    a := pop(vm.stack)

    result := op(a, b)
    push(vm.stack, result)
}