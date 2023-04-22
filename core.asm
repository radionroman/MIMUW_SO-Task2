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
        mov     rax, 0
        mov     al, byte [r13]          ; Odczytany znak to '+',
        inc     r13
        test    al, al
        jz      .ret
        cmp     al, 'G'
        je      .G
        cmp     al, 'P'
        je      .P
        cmp     al , 'n'
        je      .n

        pop     r10

        cmp     al, '+'
        je      .plus
        cmp     al, '-'
        je      .minus
        cmp     al, 'D'
        je      .D
        cmp     al, 'C'
        je      .loop1
        cmp     al, 'B'
        je      .B
        cmp     al, 'E'
        je      .E
        cmp     al, '*'
        je      .mult
        cmp     al, 'S'
        je      .S
.liczba:
        sub     rax, '0'
        push    r10
        jmp     .pushrax
.plus:
        ;pop     r10
        add     [rsp], r10
        jmp     .loop1
.minus:
        ;pop     r10
        neg     r10
        ;push    r10
        jmp     .pushr10
.mult:
        ;pop     r10
        pop     rax
        imul    r10
        ;push    rax
        jmp     .pushrax
.n:
        push    r12
        jmp     .loop1
.B:
        ;pop     r10
        pop     rax
        cmp     rax, 0
        je      .pushrax
        add     r13, r10
        jmp     .pushrax

.D:
        ;pop     r10
        push    r10
        ;push    r10
.pushr10:
        push    r10
        jmp     .loop1
.E:
        ;pop     r10
        pop     rax
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

        pop     qword[r15 + r12 * 8]
        mov     rax, r10
        xchg    qword[rbx + r12 * 8], rax
.wait1:
        mov     rax, r12
        lock \
        cmpxchg qword[rbx + r10 * 8], r12
        jne     .wait1
        push    qword[r15 + r10 * 8]
        mov     qword[rbx + r10 * 8], N
.wait2:
        mov     rax, N
        lock \
        cmpxchg qword[rbx + r12 * 8], rax
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
