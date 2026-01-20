; main.asm
; Approximate Pi using Leibniz series, scaled by 1_000_000
; Prints integer value to stdout

global _start

section .bss
    buf resb 32         ; output buffer

section .text
_start:
    ; Initialize registers
    mov r12, 0          ; accumulator (pi/4 * SCALE)
    mov r13, 1          ; denominator
    mov r14, 1_000_000  ; SCALE factor
    mov r15, 1          ; sign flag (1=+, 0=-)

pi_loop:
    ; Compute current term (SCALE / denominator)
    mov rax, r14
    mov rbx, r13
    xor rdx, rdx
    div rbx

    ; Add or subtract term
    cmp r15, 1
    je pi_add
    sub r12, rax
    jmp after

pi_add:
    add r12, rax

after:
    xor r15, 1          ; toggle sign
    add r13, 2          ; next odd denominator

    cmp r13, 1_000_000
    jl pi_loop

    ; Multiply by 4 to get pi
    imul r12, 4

    ; Print result
    mov rax, r12
    mov rdi, buf
    call print_number

    ; Exit
    mov rax, 60         ; sys_exit
    xor rdi, rdi
    syscall

; -------------------------------
; print_number: convert integer to ASCII and write to stdout
; Inputs: rax = number, rdi = buffer
; -------------------------------
print_number:
    mov rcx, 10
    lea rsi, [rdi+31]
    mov byte [rsi], 10
    dec rsi

.convert:
    xor rdx, rdx
    div rcx
    add dl, '0'
    mov [rsi], dl
    dec rsi
    test rax, rax
    jnz .convert

    inc rsi
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    lea rdx, [rel buf+32]
    sub rdx, rsi
    syscall

    ret
