global _start       ; linux entry point 
; 32 - space
; 10 - new line

section .data
    msg db "Hello", 32, "World!", 10
    len equ $ - msg

section .text
_start:
    mov rax, 1      ; system call "type" adress; 1 - sys_write
    mov rdi, 1      ; 0 - stdin; 1 - stdout; 2 - stderr;
    mov rsi, msg 
    mov rdx, len
    syscall

    jmp exit 

exit:
    mov rax, 60
    xor rdi, rdi
    syscall   
