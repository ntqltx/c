package compiler

import "../vm"

compile_to_bytecode :: proc(tokens: []Token) -> ^vm.Chunk {
    chunk := vm.make_chunk()

    vm.add_constant(chunk, 3, 1)
    vm.add_op(chunk, .OP_RETURN, 2)

    return chunk
}

compile :: proc(source: string) -> ^vm.Chunk {
    // tokenize
    tokens := tokenize(source)

    // output bytecode operations
    chunk := compile_to_bytecode(tokens)
    return chunk
}