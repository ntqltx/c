package vm

Chunk :: struct {
    code: [dynamic]u8,
    line_numbers: map[int]int,
    constants: ValueArray,
}

add_constant :: proc(chunk: ^Chunk, value: Value, line_number: int) {
    append(&chunk.constants, value)
    constant_idx := len(chunk.constants) - 1

    add_op(chunk, .OP_CONSTANT, line_number)
    append(&chunk.code, cast(u8) constant_idx)
}

add_op :: proc(chunk: ^Chunk, op: OpCode, line_number: int) {
    append(&chunk.code, cast(u8) op)

    chunk.line_numbers[len(chunk.code) - 1] = line_number
}

make_chunk :: proc(code_cap := 0, constants_cap := 0) -> ^Chunk {
    chunk := new(Chunk)

    chunk.code = make([dynamic]u8, 0, code_cap)
    chunk.line_numbers = make(map[int] int)
    chunk.constants = make(ValueArray, 0, constants_cap)

    return chunk
}

delete_chunk :: proc(chunk: ^Chunk) {
    delete(chunk.code)
    delete(chunk.constants)
    delete(chunk.line_numbers)

    free(chunk)
}