set quiet

set shell := ["bash", "-cu"]
set windows-shell := ["powershell.exe", "-c"]

alias t   := test
alias tc  := test-nocapture
alias f   := fmt

alias run := run-repl
alias rf  := run-file

# run repl
[group("dev")]
[default, no-exit-message]
run-repl *ARGS: build-release
    odin run . {{ARGS}}

# compile and run file
[group("dev")]
run-file *ARGS: build-release
    odin run {{ARGS}}

# run binary
[group("dev")]
[unix, no-exit-message]
run-repl-binary *ARGS:
    ./true {{ARGS}}

[private]
build:
    cargo build --release

# build release rust library
[group("dev")]
[unix]
build-release: build

[group("dev")]
[windows]
build-release: build
    rename target\release\c.lib libc.a

# run vm
[group("dev")]
vm-run:
    odin run ./vm

# run all unit tests
[group("test")]
[no-exit-message]
test *ARGS:
    cargo test -- {{ARGS}}

# run all unit tests with print messages
[group("test")]
[no-exit-message]
test-nocapture: (test "--nocapture")

# format rust source files
[group("chore")]
fmt:
    cargo fmt