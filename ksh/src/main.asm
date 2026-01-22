%include "include/io.inc"

global _start

section .data
msg:    db "welcome to ksh!", 10
msl:    equ $ - msg

shs:    db " > "
shl:    equ $ - shs

kms:    db 27, "[1;38;5;2;49m", "ksh stands for kulich shell", 27, "[0;39;49m", 10
mkl:    equ $ - kms

clr:    db 27, '[', '2', 'J', 27, '[', 'H'
cll:    equ $ - clr

nln:    db 10

section .bss
argv    resq 8

section .text
_start:
    mov rsi, msg
    mov rdx, msl
    call print

main_loop:
    mov rsi, shs
    mov rdx, shl
    call print

    call read
    cmp rax, 0
    jle main_loop

    cmp byte [buf], 'e'
    jne .check_clear
    cmp byte [buf+1], 'x'
    jne .check_clear
    cmp byte [buf+2], 'i'
    jne .check_clear
    cmp byte [buf+3], 't'
    jne .check_clear
    cmp byte [buf+4], 0
    je _exit

.check_clear:
    cmp byte [buf], 'c'
    jne .check_info
    cmp byte [buf+1], 'l'
    jne .check_info
    cmp byte [buf+2], 'e'
    jne .check_info
    cmp byte [buf+3], 'a'
    jne .check_info
    cmp byte [buf+4], 'r'
    jne .check_info
    cmp byte [buf+5], 0
    je .do_clear

.check_info:
    cmp byte [buf], 'i'
    jne .parse
    cmp byte [buf+1], 'n'
    jne .parse
    cmp byte [buf+2], 'f'
    jne .parse
    cmp byte [buf+3], 'o'
    jne .parse
    cmp byte [buf+4], 0
    je .do_info

.parse:
    lea rdi, [argv]
    lea rsi, [buf]
    mov [rdi], rsi
    xor rcx, rcx
    mov rbx, 1

.build:
    cmp byte [buf + rcx], 0
    je .finish
    cmp byte [buf + rcx], ' '
    jne .next
    mov byte [buf + rcx], 0
    inc rcx
.skip_spaces:
    cmp byte [buf + rcx], ' '
    jne .set_arg
    inc rcx
    jmp .skip_spaces
.set_arg:
    cmp byte [buf + rcx], 0
    je .finish
    lea rsi, [buf + rcx]
    mov [argv + rbx*8], rsi
    inc rbx
    jmp .build
.next:
    inc rcx
    jmp .build
.finish:
    mov qword [argv + rbx*8], 0

    mov rax, 57
    syscall
    test rax, rax
    jz .child
    jl main_loop

    mov rdi, rax
    mov rax, 61
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall
    jmp main_loop

.child:
    mov rdi, [argv]
    lea rsi, [argv]
    xor rdx, rdx
    mov rax, 59
    syscall

    mov rax, 60
    mov rdi, 1
    syscall

.do_clear:
    mov rsi, clr
    mov rdx, cll
    call print
    jmp main_loop

.do_info:
    mov rsi, kms
    mov rdx, mkl
    call print
    jmp main_loop

_exit:
    mov rax, 60
    xor rdi, rdi
    syscall
