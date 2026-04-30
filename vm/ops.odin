package vm

OpCode :: enum u8 {
    OP_CONSTANT,
    OP_NEGATE, // -x
    OP_RETURN,
}