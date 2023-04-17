%include "macro_print.asm"
extern putchar, put_value, get_value
section .bss
        shared_values: resq N
        shared_spinlocks: resq N
        spinlock: resq N

section .text
global core
core:
        lea     rdx, [rel spinlock]
        push    rbp
        push    rbx
        push    r12
        push    r13
        push    r14
        push    r15
        mov     rbp, rsp
        mov     r12, rdi
        mov     r13, rsi
        mov     r14, 0
        lea     r15, [rel shared_values]
        lea     rbx, [rel shared_spinlocks]
        mov     r9, 0
.loop1:
        mov     r9b, byte [r13]          ; Odczytany znak to '+',
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
        cmp     r9b, '0'
        jl      .loop1exit
        cmp     r9b, '9'
        jg      .loop1exit
        jmp     .liczba
.plus:
        pop     r10
        add     [rsp], r10
        jmp     .sub1
.minus:
        pop     rax
        neg     rax
        push    rax
        jmp     .switchend
.mult:
        pop     rax
        pop     r10
        imul    r10
        push    rax
        jmp     .sub1
.n:
        push    r12
        jmp     .add1
.B:
        pop     rax
        pop     r10
        cmp     r10, 0
        push    r10
        je      .sub1
        add     r13, rax
        jmp     .sub1
.C:
        pop     r10
        jmp     .sub1
.D:
        pop     r10
        push    r10
        push    r10
        jmp     .add1
.E:
        pop     rax
        pop     r10
        push    rax
        push    r10
        jmp     .switchend
.G:
;        test    r14, 1
;        jz      .G2
;        sub     rsp, 8
        mov     rdi, r12
        call    get_value
;        add     rsp, 8
        push    rax
        jmp     .switchend
;.G2:
;        call    get_value
;        push     rax
;        jmp     .switchend
.P:

        pop     rsi
        mov     rdi, r12
        call    put_value
        jmp     .sub1
;.P2:
;
;        pop     r13
;        push    r10
;        push    r11
;        sub     rsp, 8
;        call    put_value
;        add     rsp, 8
;        pop     r12
;        pop     r13
;        jmp     .sub1

.S:

        pop     r10
        pop     r11
        cmp     r10,r12
        je      .switchend  ; wants to swap with itself

        ;here should be mutex
        mov     rcx, 1
.mutex:
print   "czekam 1:", r12
        xchg    rcx, [rdx]
        test    rcx,rcx
        jnz     .mutex
       ; print  "left mutex: ", qword[rdx]
        cmp     qword[rbx + r10 * 8], 0
        jne     .second
        mov     qword[rbx + r12 * 8], 1
        mov     qword[rdx], 0
        mov     rcx, 1
.waitpartner:
print   "czekam 2:", r12
        xchg    rcx, [rbx + r12 * 8]
        test    rcx, rcx
        jnz     .waitpartner
        mov     qword[rbx + r12 * 8], 0
        mov     [r15 + r10 * 8], r11
        push    qword[r15 + r12 * 8]
        mov     qword[rbx + r10 * 8], 0
        jmp     .switchend

.second:

        ;open mutex

        mov     [r15 + r10 * 8], r11
        mov     qword[rbx + r12 * 8], 1
        mov     qword[rbx + r10 * 8], 0
        mov     qword[rdx], 0
        mov     rcx, 1
.waitfirst:
print   "czekam 3:", r12
        xchg    rcx, [rbx + r12 * 8]
        test    rcx, rcx
        jnz     .waitfirst
        mov     qword[rbx + r12 * 8], 0
        push    qword[r15 + r12 * 8]
        jmp     .switchend


;.S:
;        pop     r10
;        pop     r11
;        cmp     r10, r12
;        je      .switchend
;        mov     [r15 + r12 * 8], r11
;        mov     r9, qword [rbx + r10 * 8]
;        test    r9, r9
;        jnz     .issecond
;
;.isfirst:
;        mov     qword [rbx + r12 * 8], 1
;        mov     ecx, 1
;.lockwait:
;        xchg    ecx, [rbx + r12 * 8]
;        test    ecx, ecx
;        jnz      .lockwait
;
;        push    qword [r15 + r10 * 8]
;        mov     qword [rbx + r12 * 8], 0
;        mov     qword [rbx + r10 * 8], 0
;        jmp     .switchend
;.issecond:
;        push    qword [r15 + r10 * 8]
;        mov     qword [rbx + r10 * 8], 0
;        mov     qword [rbx + r12 * 8], 1
;        mov     ecx, 1
;.lock2wait:
;        xchg    ecx, [rbx + r12 * 8]
;        test    ecx, ecx
;        jnz      .lock2wait
;        mov     qword [rbx + r12 * 8], 1
;        jmp     .switchend
.liczba:
        sub     r9, '0'
        push    r9
        jmp     .add1
.sub1:
        dec     r14
        jmp     .switchend
.add1:
        inc     r14
.switchend:
        inc     r13
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
