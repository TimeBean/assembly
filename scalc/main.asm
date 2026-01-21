global _start

section .data
    msg db 27, "[1;38;5;10;49m", "One expression simple calculator:", 27, "[0;39;49m", 10, \
           27, "[90m", "syntax: {num} {opr} {num} ", 27, "[0;39;49m", 10, \
           "{opr} + addition", 10, \
           "{opr} - subtraction", 10, \
           "{opr} * multiplication", 10, \
           "{opr} / integer division", 10, \
           27, "[4;38;5;2;49m", "only positive numbers", 27, "[0;39;49m", 10, 10, \
           "enter expression > "
    msg_len equ $ - msg

section .bss
    buf resb 32         ; input buffer
    fnm resb 16         ; first number as string
    snm resb 16         ; second number as string
    opr resb 4          ; operator area (we keep your parsing style)
    outb resb 32        ; output buffer for result

section .text
_start:
    ; ---- write prompt ----
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, msg
    mov rdx, msg_len
    syscall

    ; ---- read input ----
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, buf
    mov rdx, 32
    syscall

    ; ---- parse first number ----
    mov r12, 0          ; buf index
    mov r13, 0          ; local loop counter
fnm_loop:
    mov al, [buf + r12]
    add r12, 1
    mov [fnm + r13], al
    add r13, 1
    cmp al, 32          ; 32 - space
    jne fnm_loop
    mov byte [fnm + r13 - 1], 0
    mov r13, 0

    ; ---- parse operator ----
opr_loop:
    mov al, [buf + r12]
    add r12, 1
    mov [opr + r13], al
    add r13, 1
    cmp al, 32
    jne opr_loop
    mov r13, 0

    ; ---- parse second number ----
snm_loop:
    mov al, [buf + r12]
    add r12, 1
    mov [snm + r13], al
    add r13, 1
    cmp al, 10          ; 10 - newline
    jne snm_loop
    mov byte [snm + r13 - 1], 0

    ; ---- convert strings to numbers ----
    mov rdi, fnm
    call str2num
    mov r8, rax         ; r8 = first number

    mov rdi, snm
    call str2num
    mov r9, rax         ; r9 = second number

    ; ---- perform operation ----
    mov al, [opr]     
    cmp al, '+'
    je do_add
    cmp al, '-'
    je do_sub
    cmp al, '*'
    je do_mul
    cmp al, '/'
    je do_div
    jmp exit            ; unknown opr - exit

do_add:
    add r8, r9
    jmp print_result

do_sub:
    sub r8, r9
    jmp print_result

do_mul:
    mov rax, r8        
    mul r9            
    mov r8, rax      
    jmp print_result

do_div:
    mov rax, r8     
    xor rdx, rdx   
    div r9        
    mov r8, rax  
    jmp print_result

print_result:
    mov rax, r8       
    mov rdi, outb      
    call num2str        
    ; ---- write result ----
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    mov rsi, outb
    syscall

exit:
    mov rax, 60
    xor rdi, rdi
    syscall

; ----------------------
; str2num: rdi = addr ancii (NUL-terminated)
; returns: rax = digit (unsigned)
str2num:
    xor rax, rax
    xor rcx, rcx
    mov r10, 10
str2num_loop:
    mov bl, [rdi + rcx]
    cmp bl, 0
    je str2num_done
    sub bl, '0'
    movzx r11, bl
    imul rax, rax, 10
    add rax, r11
    inc rcx
    jmp str2num_loop
str2num_done:
    ret

; ===========================
; num2str: rax = digit, rdi = buffer
; ASCII gigit + LF
; return rax = length
num2str:
    cmp rax, 0
    jne num2str_nonzero
    mov byte [rdi], '0'
    mov byte [rdi+1], 10
    mov rax, 2
    ret

num2str_nonzero:
    mov rcx, 0           ; counter 
    mov rbx, 10
    mov r11, rax         ; copy digit

num2str_loop:
    xor rdx, rdx
    div rbx              ; rax / 10, rdx = r11 % 10
    add dl, '0'          
    push rdx
    inc rcx
    mov r11, rax
    cmp r11, 0
    jne num2str_loop

    mov rsi, rdi
pop_loop:
    pop rdx
    mov [rsi], dl       
    inc rsi
    dec rcx
    jnz pop_loop

    mov byte [rsi], 10   ; LF
    lea rax, [rsi+1]
    sub rax, rdi        
    ret
