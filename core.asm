%include "macro_print.asm"
extern putchar, put_value, get_value
section .bss
        shared_values: resq N
        shared_spinlocks: resq N
        spinlock: resq 1

section .text
global core
core:
        push    rbp
        push    rbx
        push    r12
        push    r13
        push    r14
        push    r15
        mov     rbp, rsp
        mov     r12, rdi
        mov     r13, rsi
        lea     r14, [rel spinlock]
        lea     r15, [rel shared_values]
        lea     rbx, [rel shared_spinlocks]

.loop1:
        mov     r9, 0
        mov     r9b, byte [r13]          ; Odczytany znak to '+',
        inc     r13
        test    r9b, r9b
        jz      .loop1exit
        cmp     r9b, '+'
        je      .plus
        cmp     r9b, '-'
        je      .minus
        cmp     r9b, '*'
        je      .mult
        cmp     r9b, 'n'
        je      .n
        cmp     r9b, 'B'
        je      .B
        cmp     r9b, 'C'
        je      .C
        cmp     r9b, 'D'
        je      .D
        cmp     r9b, 'E'
        je      .E
        cmp     r9b, 'G'
        je      .G
        cmp     r9b, 'P'
        je      .P
        cmp     r9b, 'S'
        je      .S
        jmp     .liczba
.plus:
        pop     r10
        add     [rsp], r10
        jmp     .loop1
.minus:
        pop     rax
        neg     rax
        push    rax
        jmp     .loop1
.mult:
        pop     rax
        pop     r10
        imul    rax, r10
        push    rax
        jmp     .loop1
.n:
        push    r12
        jmp     .loop1
.B:
        pop     rax
        pop     r10
        cmp     r10, 0
        push    r10
        je      .loop1
        add     r13, rax
        jmp     .loop1
.C:
        pop     r10
        jmp     .loop1
.D:
        pop     r10
        push    r10
        push    r10
        jmp     .loop1
.E:
        pop     rax
        pop     r10
        push    rax
        push    r10
        jmp     .loop1
.G:
        mov     rdi, r12
        test    rsp, 0x8
        jz     .GEven
        sub     rsp, 8
        call    get_value
        add     rsp, 8
        push    rax
        jmp     .loop1
.GEven:
        call    get_value
        push    rax
        jmp     .loop1
.P:
        pop     rsi
        mov     rdi, r12
        test    rsp, 0x8
        jz      .PEven
        sub     rsp, 8
        call    put_value
        add     rsp, 8
        jmp     .loop1
.PEven:
        call    put_value
        jmp     .loop1

.S:

        pop     r10
        pop     r11
        cmp     r10,r12
        je      .loop1  ; wants to swap with itself
        mov     rcx, 1
.mutex:
;print   "czekam 1:", r12
        xor     rax, rax
        lock cmpxchg [r14], rcx
        jne     .mutex
;print  "left mutex: ", qword[rdx]
        mov     rcx, r10
        inc     rcx
        mov     rax, r12
        inc     rax
        cmp     qword[rbx + r10 * 8], rax
        je      .second
        mov     qword[rbx + r12 * 8], rcx

        mov     qword[r14], 0
.waitsecond:
;print   "czekam 2:", r12
        xor     rax,rax
        lock cmpxchg [rbx + r12 * 8], rax
        jne     .waitsecond
        ;mov     qword[rbx + r12 * 8], 0
        mov     [r15 + r10 * 8], r11
        push    qword[r15 + r12 * 8]
        mov     qword[rbx + r10 * 8], 0
        jmp     .loop1
.second:
        ;open mutex
        mov     [r15 + r10 * 8], r11
        mov     qword[rbx + r12 * 8], rcx
        mov     qword[r14], 0
        mov     qword[rbx + r10 * 8], 0
.waitfirst:
;print   "czekam 3:", r12
        xor     rax,rax
        lock cmpxchg [rbx + r12 * 8], rax
        jne     .waitfirst
        ;mov     qword[rbx + r12 * 8], 0
        push    qword[r15 + r12 * 8]
        jmp     .loop1

.liczba:
        sub     r9, '0'
        push    r9
        jmp     .loop1

.loop1exit:
        pop     rax
        mov     rsp, rbp
        pop     r15
        pop     r14
        pop     r13
        pop     r12
        pop     rbx
        pop     rbp
        ret
