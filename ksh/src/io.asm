section .bss
global buf
buf:    resb 128

section .text
global print
global read

print:
    mov rax, 1
    mov rdi, 1
    syscall
    ret

read:
    xor rcx, rcx
.clear_buf:
    cmp rcx, 128
    je .done_clear
    mov byte [buf+rcx], 0
    inc rcx
    jmp .clear_buf
.done_clear:

    mov rax, 0
    mov rdi, 0
    mov rsi, buf
    mov rdx, 128
    syscall

    ; remove \n
    test rax, rax
    jz .done
    dec rax
    cmp byte [buf+rax], 10
    jne .done
    mov byte [buf+rax], 0
.done:
    ret
