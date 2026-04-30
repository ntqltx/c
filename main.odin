package main

import "core:flags"
import "core:fmt"
import "core:os"

import "vm"
import comp "compiler"

// Options :: struct {

// }

interpret :: proc(source: string) -> vm.InterpretResult {
    // execute
    chunk := comp.compile(source)
    defer vm.delete_chunk(chunk)

    result := vm.interpret(chunk)
    return .OK
}

repl :: proc() {
    vm.init_vm()
    defer vm.free_vm()
    
    buffer := make([]u8, 1024)
    
    for {
        fmt.print("> ")
        n_bytes_read, err := os.read(os.stdin, buffer)
        
        if n_bytes_read == 0 {
            break
        }

        input := cast(string) buffer[:n_bytes_read - 1]
        result := interpret(input)

        if result != .OK {
            fmt.println("Failed to interpret")
            break
        }

        fmt.println("\nGot:", input)
    }

    fmt.println("")
    // fmt.println("result, ok:", result, ok)
    // fmt.println("buffer:", buffer[:20])
}

main :: proc() {
    args := os.args

    switch len(args) {
        case 1:
            // no input file given, start repl
            repl()
        case 2:
            // assume we were given a file, read it, compile and execute
            bytes, success := os.read_entire_file_from_path(args[1], context.allocator)
            file_contains := cast(string) bytes
            fmt.println(file_contains)

            // fmt.println("Got two args")
        case:
            fmt.println("Got something else")
    }
}