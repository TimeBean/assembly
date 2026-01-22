section .data
usr db "/usr/", 0

section .bss
global bff
bff:    resb 128        

global pth
pth:   resb 256      

section .text
global make_path
global _start

; -------------------------------------------------
; void make_path(char *buf, char *path)
; rdi = pointer path
; rsi = pointer buf
; -------------------------------------------------
make_path:
    push rbx

    lea rbx, [usr]
.copy_usr:
    lodsb
    stosb
    test al, al
    jne .copy_usr

    dec rdi          ; убрать лишний 0

.copy_bff:
    lodsb
    stosb
    test al, al
    jne .copy_bff

    pop rbx
    ret
