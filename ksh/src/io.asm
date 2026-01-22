section .bss
global buf
buf:    resb 128

section .text
global print
global read

; Print string to stdout
; rsi = buffer pointer
; rdx = length
print:
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    syscall
    ret

; Read input from stdin
; Returns: rax = bytes read
read:
    ; Clear buffer
    xor rcx, rcx
.clear_loop:
    cmp rcx, 128
    je .read_input
    mov byte [buf+rcx], 0
    inc rcx
    jmp .clear_loop

.read_input:
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, buf
    mov rdx, 128
    syscall
    
    ; Remove trailing newline if present
    test rax, rax
    jz .done
    dec rax
    cmp byte [buf+rax], 10
    jne .done
    mov byte [buf+rax], 0

.done:
    ret
