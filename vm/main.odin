package vm

import "core:fmt"
import "core:mem"
import "core:os"

Allocator :: mem.Allocator
Allocator_Mode :: mem.Allocator_Mode
Allocator_Error :: mem.Allocator_Error

MyAllocatorData :: struct {
    allocator: Allocator,
}

my_allocator :: proc(my_allocator_data: ^MyAllocatorData) -> Allocator {
    return Allocator {
        procedure = my_allocator_proc,
        data = my_allocator_data,
    }
}

my_allocator_data_init :: proc(d: ^MyAllocatorData) {
    d.allocator = context.allocator
}

my_allocator_proc :: proc(
    allocator_data: rawptr, mode: Allocator_Mode, size, alignment: int,
    old_memory: rawptr, old_size: int, location := #caller_location

) -> ([]byte, Allocator_Error)
{
    allocator := (cast(^MyAllocatorData) allocator_data).allocator

    #partial switch mode {
        case .Alloc:
            // fmt.println("ALLOC")
            bytes, error := mem.alloc_bytes(size, alignment, allocator, location)

            if error != nil {
                fmt.println("Failed to allocate")
                os.exit(1)
            }
            return bytes, nil

        case .Free:
            // fmt.println("FREE")
            return nil, mem.free(cast(rawptr) old_memory, allocator, location)

        case .Resize:
            // fmt.println("RESIZE")
            bytes, error := allocator.procedure(
                allocator_data, mode, size, alignment, 
                old_memory, old_size, location
            )

            if error != nil {
                fmt.println("Failed to resize")
                os.exit(1)
            }
            return bytes, nil

        case .Alloc_Non_Zeroed:
            // fmt.println("ALLOC_NON_ZEROED")
            bytes, error := allocator.procedure(
                allocator_data, mode, size, alignment, 
                old_memory, old_size, location
            )

            if error != nil {
                fmt.println("Failed to call to Alloc_Non_Zeroed")
                os.exit(1)
            }
            return bytes, nil
    }

    fmt.println("Mode", mode, "not supported")
    os.exit(1) 
}

main :: proc () {
    // stack : ^Stack = make_stack(8)
    // defer delete_stack(stack)
    // push(stack, 0.1)

    // fmt.println(stack.top^)
    // value := pop(stack)
    // fmt.println("Popped:", value)
    // fmt.println(stack.values)

    // my_data := MyAllocatorData {}
    // my_allocator_data_init(&my_data)
    // allocator := my_allocator(&my_data)

    // context.allocator = allocator

    init_vm()
    defer free_vm()

    // test bytecode
    chunk := make_chunk()
    defer delete_chunk(chunk)

    //// 2 * 2 + 8 - 15
    add_constant(chunk, 2, 1)
    add_constant(chunk, 2, 2)
    add_op(chunk, .OP_MUL, 3)
    
    add_constant(chunk, 8, 4)
    add_op(chunk, .OP_ADD, 5)
    add_constant(chunk, 15, 6)
    add_op(chunk, .OP_SUB, 7)
    
    add_op(chunk, .OP_RETURN, 8)

    // print bytecode for reference
    assembly := disassemble(chunk)
    fmt.println(assembly)

    interpret(chunk)
}