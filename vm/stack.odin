package vm

import "core:fmt"
import "core:mem"
import "core:os"

STACK_CAP :: 256

Stack :: struct {
    top: ^Value, // points to the top of the stack
    values: []Value, // values of the stack
}

make_stack :: proc(N: int) -> ^Stack {
    values := make([]Value, N)
    stack := new(Stack)

    stack.top = &values[0]
    stack.values = values

    return stack
}

delete_stack :: proc(stack: ^Stack) {
    delete(stack.values)
    free(stack)
}

push :: #force_inline proc(stack: ^Stack, value: Value) {
    when ODIN_DEBUG {
        number_of_elements := mem.ptr_sub(stack.top, &stack.values[0])
        if number_of_elements > len(stack.values) {
            fmt.println("Stack overflow")
            os.exit(1)
        }
    }

    stack.top^ = value
    stack.top = mem.ptr_offset(stack.top, 1)
}

pop :: #force_inline proc(stack: ^Stack) -> Value {
    when ODIN_DEBUG {
        number_of_elements := mem.ptr_sub(stack.top, &stack.values[0])
        if number_of_elements == 0 {
            fmt.println("Stack underflow")
            os.exit(1)
        }
    }

    stack.top = mem.ptr_offset(stack.top, -1)
    value := stack.top^

    return value
}