package vm

import "core:fmt"
import "core:mem"

_DEBUG      :: false
DEBUG       :: _DEBUG
DEBUG_TRACE :: _DEBUG

VM :: struct {
    chunk: ^Chunk,
    ip: ^u8,
    stack: ^Stack,
}

vm : VM

init_vm :: proc() {
    vm = VM {
        chunk = nil,
        stack = make_stack(STACK_CAP),
    }
}

free_vm :: proc() {
    // free(vm.chunk)
}

InterpretResult :: enum i32 {
    OK,
    COMPILE_ERROR,
    RUNTIME_ERROR,
}

interpret :: proc(chunk: ^Chunk) -> InterpretResult {
    if len(chunk.code) == 0 {
        fmt.println("Empty chunk, nothing to execute")
        return .OK
    }

    vm.chunk = chunk
    vm.ip = &chunk.code[0]

    return run()
}

read_byte :: #force_inline proc() -> u8 {
    value := vm.ip^
    vm.ip = mem.ptr_offset(vm.ip, 1)

    return value
}

read_constant :: proc() -> Value {
    address := read_byte()
    value := vm.chunk.constants[address]

    return value
}

run :: proc() -> InterpretResult {
    for {
        when DEBUG_TRACE {
            fmt.println("--- STACK ---")
            fmt.print("[")
            
            for &value, i in &vm.stack.values {
                if &value == vm.stack.top {
                    break
                }
                if i > 0 {
                    fmt.print(", ")
                }
                print_value(value)
            }

            fmt.println("]")
        }

        instruction := cast(OpCode) read_byte()
        switch instruction {
            case .OP_CONSTANT:
                value := read_constant()
                push(vm.stack, value)

                when DEBUG {
                    fmt.println("Value:", value)
                }

            case .OP_ADD: if r := binary_op(add); r != .OK do return r
            case .OP_SUB: if r := binary_op(sub); r != .OK do return r
            case .OP_MUL: if r := binary_op(mul); r != .OK do return r
            case .OP_DIV: if r := binary_op(div); r != .OK do return r

            case .OP_PRINT:
                value := pop(vm.stack)
                print_value(value)
                fmt.println()

            case .OP_POP:
                pop(vm.stack)

            case .OP_NEGATE:
                value := pop(vm.stack)
                if !is_number(value) {
                    runtime_error("operand must be number")
                    return .RUNTIME_ERROR
                }
                push(vm.stack, number_val(-as_number(value)))

            case .OP_RETURN:
                return .OK
        }
    }

    // no return op
    return .RUNTIME_ERROR
}