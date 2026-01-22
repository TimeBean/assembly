%include "include/io.inc"

global _start

section .data
msg:    db "welcome to ksh!", 10
msl:    equ $ - msg

prompt: db " > "
prl:    equ $ - prompt

info_msg: db 27, "[1;38;5;2;49m", "ksh stands for kulich shell", 27, "[0;39;49m", 10
iml:    equ $ - info_msg

clear_screen: db 27, '[2J', 27, '[H'
csl:    equ $ - clear_screen

; Command strings for comparison
cmd_exit:   db "exit", 0
cmd_clear:  db "clear", 0
cmd_info:   db "info", 0

section .bss
argv:   resq 8

section .text
_start:
    mov rsi, msg
    mov rdx, msl
    call print

main_loop:
    ; Show prompt
    mov rsi, prompt
    mov rdx, prl
    call print
    
    ; Read user input
    call read
    cmp rax, 0
    jle main_loop
    
    ; Check for built-in commands
    call check_builtin
    test rax, rax
    jnz main_loop
    
    ; Parse and execute external command
    call parse_args
    call execute_command
    jmp main_loop

; Check if input is a built-in command
; Returns: rax = 1 if built-in handled, 0 otherwise
check_builtin:
    ; Check "exit"
    mov rsi, buf
    mov rdi, cmd_exit
    call strcmp
    test rax, rax
    jz exit_shell
    
    ; Check "clear"
    mov rsi, buf
    mov rdi, cmd_clear
    call strcmp
    test rax, rax
    jz do_clear
    
    ; Check "info"
    mov rsi, buf
    mov rdi, cmd_info
    call strcmp
    test rax, rax
    jz do_info
    
    ; Not a built-in command
    xor rax, rax
    ret

do_clear:
    mov rsi, clear_screen
    mov rdx, csl
    call print
    mov rax, 1
    ret

do_info:
    mov rsi, info_msg
    mov rdx, iml
    call print
    mov rax, 1
    ret

exit_shell:
    mov rax, 60         ; sys_exit
    xor rdi, rdi
    syscall

; Compare two null-terminated strings
; rsi = string 1, rdi = string 2
; Returns: rax = 0 if equal, non-zero otherwise
strcmp:
    push rbx
    xor rbx, rbx
.loop:
    mov al, [rsi + rbx]
    mov cl, [rdi + rbx]
    cmp al, cl
    jne .not_equal
    test al, al
    jz .equal
    inc rbx
    jmp .loop
.equal:
    xor rax, rax
    pop rbx
    ret
.not_equal:
    mov rax, 1
    pop rbx
    ret

; Parse command line into argv array
parse_args:
    lea rdi, [argv]
    lea rsi, [buf]
    mov [rdi], rsi      ; argv[0] = start of buffer
    xor rcx, rcx
    mov rbx, 1          ; argv index

.scan:
    cmp byte [buf + rcx], 0
    je .done
    cmp byte [buf + rcx], ' '
    jne .next_char
    
    ; Found space - null-terminate current arg
    mov byte [buf + rcx], 0
    inc rcx
    
    ; Skip multiple spaces
.skip_spaces:
    cmp byte [buf + rcx], ' '
    jne .new_arg
    inc rcx
    jmp .skip_spaces
    
.new_arg:
    cmp byte [buf + rcx], 0
    je .done
    lea rsi, [buf + rcx]
    mov [argv + rbx*8], rsi
    inc rbx
    jmp .scan

.next_char:
    inc rcx
    jmp .scan

.done:
    mov qword [argv + rbx*8], 0  ; NULL-terminate argv
    ret

; Execute external command using fork/exec
execute_command:
    mov rax, 57         ; sys_fork
    syscall
    test rax, rax
    jz .child
    jl .error
    
    ; Parent process - wait for child
    mov rdi, rax
    mov rax, 61         ; sys_wait4
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall
    ret

.child:
    ; Child process - execute command
    mov rdi, [argv]
    lea rsi, [argv]
    xor rdx, rdx
    mov rax, 59         ; sys_execve
    syscall
    
    ; If execve returns, command failed
    mov rax, 60
    mov rdi, 1
    syscall

.error:
    ret
