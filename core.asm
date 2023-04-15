global core
extern putchar, put_value, get_value

section .text

core:
        mov     r8, rsp
        mov     rcx, 0
        mov     r9, 0
.loop1:
        mov     r9b, byte [rsi]          ; Odczytany znak to '+',
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
        push    rdi
        jmp     .add1
.B:
        pop     rax
        pop     r10
        cmp     r10, 0
        push    r10
        je      .sub1
        add     rsi, rax
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
        test    rcx, 1
        jz      .G2
        sub     rsp, 8
        call    get_value
        add     rsp, 8
        push    rax
        jmp     .switchend
.G2:
        call    get_value
        push     rax
        jmp     .switchend
.P:

        mov     r10, rsi
        mov     r11, rdi
        test    rcx, 1
        jnz     .P2
        pop     rsi
        push    r10
        push    r11
        call    put_value
        pop     rdi
        pop     rsi
        jmp     .sub1
.P2:

        pop     rsi
        push    r10
        push    r11
        sub     rsp, 8
        call    put_value
        add     rsp, 8

.break:
        pop     rdi
        pop     rsi

        jmp     .sub1
.S:
        jmp     .switchend
.liczba:
        sub     r9, 48
        push    r9
        jmp     .add1
.sub1:
        dec     rcx
        jmp     .switchend
.add1:
        inc     rcx
.switchend:
        inc     rsi
        jmp     .loop1

.loop1exit:
        pop     rax
        ;mov     rsp, r8

        ret
