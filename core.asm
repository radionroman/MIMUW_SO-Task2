extern put_value, get_value

section .data
        waits times N dq -1
section .bss
        val: resq N

section .text
global core
core:
        push    rbp
        push    rbx
        push    r12
        push    r13
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

        pop     r10

        cmp     r9b, '+'
        je      .plus
        cmp     r9b, '-'
        je      .minus

        cmp     r9b, 'D'
        je      .D
        cmp     r9b, 'C'
        je      .loop1

        pop     rax

        cmp     r9b, '*'
        je      .mult
        cmp     r9b, 'B'
        je      .B
        cmp     r9b, 'E'
        je      .E
        cmp     r9b, 'S'
        je      .S
        jmp     .liczba

        ; mult,B,E,S
.plus:
        ;pop     r10
        add     [rsp], r10
        jmp     .loop1
.minus:
        ;pop     r10
        neg     r10
        push    r10
        jmp     .loop1
.mult:
        ;pop     r10
        ;pop     rax
        imul    r10
        ;push    rax
        jmp     .pushrax
.n:
        push    r12
        jmp     .loop1
.B:
        ;pop     r10
        ;pop     rax
        cmp     rax, 0
        ;push    rax
        je      .pushrax
        add     r13, r10
        jmp     .pushrax

.D:
        ;pop     r10
        push    r10
        push    r10
        jmp     .loop1
.E:
        ;pop     r10
        ;pop     rax
        push    r10
        ;push    rax
        jmp     .pushrax
.G:
        mov     rdi, r12
        test    rsp, 0x8
        jz     .GEven
        sub     rsp, 8
        call    get_value
        add     rsp, 8
        ;push    rax
        jmp     .pushrax
.GEven:
        call    get_value
        ;push    rax
        jmp     .pushrax
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
        ;pop     r10
        xchg    qword[r15 + r12 * 8], rax
        mov     rax, r10
        xchg    qword[rbx + r12 * 8], rax
.wait1:
        mov     rax, r12
        lock cmpxchg qword[rbx + r10 * 8], r12
        jne     .wait1
        push    qword[r15 + r10 * 8]
        mov     rax, -1
        xchg    qword[rbx + r10 * 8], rax
.wait2:
        mov     rax, -1
        lock cmpxchg qword[rbx + r12 * 8], rax
        jne     .wait2
        jmp     .loop1

.liczba:
        sub     r9, '0'
        push    rax
        push    r10
        push    r9
        jmp     .loop1
.pushrax:
        push    rax
        jmp     .loop1


.ret:

        pop     rax
        mov     rsp, rbp
        pop     r15
        pop     r13
        pop     r12
        pop     rbx
        pop     rbp
        ret
