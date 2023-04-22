extern put_value, get_value

section .data
        waits times N dq N
section .bss
        val: resq N

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
        lea     r15, [rel val]
        lea     rbx, [rel waits]

.loop1:
        mov     r9, 0
        mov     r9b, byte [r13]          ; Odczytany znak to '+',
        inc     r13
        test    r9b, r9b
        jz      .ret
        cmp     r9b, 'G'
        je      .G
        cmp     r9b, 'P'
        je      .P
        cmp     r9b, 'n'
        je      .n

        pop     rax

        cmp     r9b, '+'
        je      .plus
        cmp     r9b, '-'
        je      .minus
        cmp     r9b, 'D'
        je      .D
        cmp     r9b, 'C'
        je      .loop1

        pop     r10

        cmp     r9b, '*'
        je      .mult
        cmp     r9b, 'B'
        je      .B
        cmp     r9b, 'E'
        je      .E
        cmp     r9b, 'S'
        je      .S
.liczba:
        sub     r9, '0'
        push    r10
        push    rax
        push    r9
        jmp     .loop1

        ; mult,B,E,S
.plus:
        ;pop     rax
        add     [rsp], rax
        jmp     .loop1
.minus:
        ;pop     rax
        neg     rax
        ;push    rax
        jmp     .pushrax
.mult:
        ;pop     rax
        ;pop     r10
        imul    r10
        ;push    rax
        jmp     .pushrax
.n:
        push    r12
        jmp     .loop1
.B:
        ;pop     rax
        ;pop     r10
        cmp     r10, 0
        xchg    r10, rax
        je      .pushrax
        add     r13, r10
        jmp     .pushrax

.D:
        ;pop     rax
        push    rax
        ;push    rax
        jmp     .pushrax
.E:
        ;pop     rax
        ;pop     r10
        xchg    rax, r10
        push    r10
        ;push    rax
        jmp     .pushrax
.G:
        mov     rdi, r12
        mov     r14, 0x8
        and     r14, rsp
        sub     rsp, r14
        call    get_value
        add     rsp, r14

.pushrax:
        push    rax
        jmp     .loop1
.P:
        pop     rsi
        mov     rdi, r12
        mov     r14, 0x8
        and     r14, rsp
        sub     rsp, r14
        call    put_value
        add     rsp, r14
        jmp     .loop1


.S:
        ;pop     rax
        ;xchg    rax, r10
        mov     qword[r15 + r12 * 8], r10
        mov     r9, N
        mov     r10, rax
        mov     qword[rbx + r12 * 8], r10
.wait1:
        mov     rax, r12
        lock cmpxchg qword[rbx + r10 * 8], r9
        jne     .wait1
        push    qword[r15 + r10 * 8]
        ;mov     qword[rbx + r10 * 8], -1
.wait2:
        mov     rax, N
        lock cmpxchg qword[rbx + r12 * 8], rax
        jne     .wait2
        jmp     .loop1
.ret:
        pop     rax
        mov     rsp, rbp
        pop     r15
        pop     r14
        pop     r13
        pop     r12
        pop     rbx
        pop     rbp
        ret
