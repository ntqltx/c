package compiler

import "core:fmt"

Token :: struct {
    lexeme: string,
    type: TokenType,
    line: int,
}

Tokenizer :: struct {
    source: string,
    start: int,
    pointer: int,
    line: int,
}

init_tokenizer :: proc(source: string) {
    tokenizer.source = source
    tokenizer.pointer = 0
    tokenizer.line = 0
}

tokenizer : Tokenizer = Tokenizer {}
tokenize :: proc(source: string) -> []Token {
    init_tokenizer(source)
    current_line := -1

    for {
        token := scan_token()
        
        if token.line != current_line {
            fmt.printf("\nLINE: %4v ", token.line)
        }
        else {
            fmt.print(" | ")
        }
        
        tokenizer.line = token.line
        
        if token.type == .EOF {
            fmt.print("EOF")
            break
        } 
        else if token.type == .ERROR {
            fmt.printf("ERROR: '%v'", token.lexeme)
        } 
        else {
            fmt.printf("'%v'", token.lexeme)
        }
    }
    
    tokens := make([]Token, 1)
    return tokens
}

scan_token :: proc() -> Token {
    if is_at_end() {
        return make_token(.EOF)
    }
    current_char := tokenizer.source[tokenizer.pointer]
    
    for is_whitespace(current_char) {
        tokenizer.pointer += 1
        if is_at_end() {
            return make_token(.EOF)
        }
        current_char = tokenizer.source[tokenizer.pointer]
    }
    
    tokenizer.start = tokenizer.pointer
    
    if is_numeric(current_char) {
        number := ctoi(current_char)

        tokenizer.pointer += 1
        current_char := tokenizer.source[tokenizer.pointer]
        
        for is_numeric(current_char) {
            number *= 10
            number += ctoi(current_char)

            tokenizer.pointer += 1
            if is_at_end() {
                return make_token(.NUMBER)
            }
            current_char := tokenizer.source[tokenizer.pointer]
        }

        if is_whitespace(current_char) {
            return make_token(.NUMBER)
        }
        else {
            return make_token(.ERROR)
        }
    }
    
    return make_token(.ERROR)
}

make_token :: proc(type: TokenType) -> Token {
    return Token {
        lexeme = tokenizer.source[tokenizer.start:tokenizer.pointer],
        type = type, line = tokenizer.line
    }
}

is_numeric :: proc(ch: u8) -> bool {
    return ch >= cast(u8) '0' && ch <= cast(u8) '9'
}

is_whitespace :: proc(ch: u8) -> bool {
    return ch == ' ' || ch == '\t' || ch == '\r' || ch == '\n'
}

is_at_end :: proc() -> bool {
    return tokenizer.pointer == len(tokenizer.source)
}

ctoi :: proc(ch: u8) -> int {
    return cast(int) (ch - cast(u8) '0')
}