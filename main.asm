global _start       ; linux entry point 

; 32 - space
; 10 - new line

section .data
    msg db "Some number here > "
    len equ $ - msg

section .bss
    buf resb 10

section .text
_start:
    mov rax, 1      ; out; system call "type" address; 1 - sys_write
    mov rdi, 1      ;      0 - stdin; 1 - stdout; 2 - stderr;
    mov rsi, msg 
    mov rdx, len
    syscall

    mov rax, 0      ; in
    mov rdi, 0
    mov rsi, buf
    mov rdx, 100
    syscall

    mov rdx, rax    ; mov in len to rdx

    mov rax, 1      ; out
    mov rdi, 1
    mov rsi, buf
    syscall

    jmp exit 

exit:
    mov rax, 60
    xor rdi, rdi
    syscall
