extern put_value, get_value

section .data
        waits times N dq N  ; global array initialized to N value,
        ; waits[i] = j, i-th thread awaits j-th thread

section .bss
        val: resq N ; values threads pop from stack

section .text
global core
core:
        ; pushing all the values from preserved registers on stack
        ; so we can use these registers to safely store our variables
        push    rbp
        push    rbx
        push    r12
        push    r13
        push    r14
        push    r15
        ; storing the pointer to part of the stack with the preserved registers
        ; to retrieve them before end
        mov     rbp, rsp
        mov     r12, rdi    ; r12 - n value
        mov     r13, rsi    ; r13 - pointer to string with instructions
        lea     r15, [rel val]  ; r15 - pointer to global array with values
        lea     rbx, [rel waits]    ; rbx - pointer to global array with locks
.loop1:
        ; main loop iterating through string
        mov     rax, 0  ; cleaning rax register
        mov     al, byte [r13]  ; storing char in the lower 8 bits of rax
        inc     r13     ; move pointer to the next char in string
        test    al, al  ; if al is 0 we encountered the end of the string
        jz      .ret    ; if so jump out of the loop
        ; next we check the char to determine to which instruction we need to jump
        cmp     al, 'G'
        je      .G
        cmp     al, 'P'
        je      .P
        cmp     al , 'n'
        je      .n
        ; all the following instructions use the value from the stack
        ; so we pop it once here, to avoid repetition of this pop later on
        ; in each of the instructions
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
        ; if the char != 0 and none of the above
        ; it represents digit from which we subtract '0'
        ; to turn it into int value
        sub     rax, '0'
        ;push    r10
        jmp     .pushr10rax    ; this label is used to minimize number of "push r10 push rax" through the code
.plus:
        ; instruction that adds together two upper values of the stack
        ; use previously popped r10 to add it to the value at the top of the stack
        ;pop     r10
        add     [rsp], r10
        jmp     .loop1
.minus:
        ; instruction that negates the number at the top of the stack
        ; use previously popped r10 to negate it and push back at the top of the stack
        ;pop     r10
        neg     r10
        push    r10
        jmp     .loop1
.mult:
        ; instruction multiplies two upper values of the stack
        ; multiplies rax by r10 and pushes the result
        ;pop     r10
        pop     rax
        imul    r10
        ;push    rax
        jmp     .pushrax    ; this label is used to minimize number of "push rax" through the code
.n:
        ; instruction pushes n onto the stack
        push    r12
        jmp     .loop1
.B:
        ; instruction pops two values from the stack and adds the first one
        ; to the string pointer if the second one != 0
        ;pop     r10
        pop     rax
        test    rax, rax
        jz      .pushrax
        add     r13, r10
        jmp     .pushrax
.D:
        ; instruction pops a value from stack and pushes it back twice
        ;pop     r10
        mov     rax, r10
        ;push    r10
        ;push    rax
.pushr10rax:
        ; if instruction has to push 2 values on the stack at the end
        ; it jumps to this label
        push    r10
.pushrax:
        ; if an instruction has to push only rax on the stack at the end then
        ; it jumps to this label
        push    rax
        jmp     .loop1
.E:
        ; this instruction pops two values from stack
        ; and pushes them back in reverse order
        ;pop     r10
        pop     rax
        ;push    r10
        ;push    rax
        jmp     .pushr10rax
.G:
        ; this instruction puts n in place for first argument
        ; checks if it needs to align the stack
        ; and then calls get_value function
        ; and pushes the result onto the stack
        mov     rdi, r12
        mov     r14, 0x8
        and     r14, rsp
        sub     rsp, r14
        call    get_value
        add     rsp, r14
        ;push    rax
        jmp     .pushrax

.P:
        ; this instruction puts n in place for first argument
        ; and pops value from the stack as second argument
        ; checks if it needs to align the stack
        ; and then calls put_value function
        pop     rsi
        mov     rdi, r12
        mov     r14, 0x8
        and     r14, rsp
        sub     rsp, r14
        call    put_value
        add     rsp, r14
        jmp     .loop1
.S:
        ; this instruction synchronizes two threads
        ; and exchanges values at the tops of their stacks
        pop     qword[r15 + r12 * 8]    ; puts value in values[n]
        mov     rax, r10    ; move m to rax
        xchg    qword[rbx + r12 * 8], rax   ; atomically sets waits[n] = m
.wait1:
        ; spinlock that spins while waits[m] != n
        mov     rax, r12
        lock \
        cmpxchg qword[rbx + r10 * 8], r12
        jne     .wait1
        push    qword[r15 + r10 * 8]    ; pushes values[m] onto the stack
        mov     qword[rbx + r10 * 8], N ; sets waits[m] = N
.wait2:
        ; spins while waits[m] != N
        mov     rax, N
        lock \
        cmpxchg qword[rbx + r12 * 8], rax
        jne     .wait2
        jmp     .loop1
.ret:
        ; exit from loop label
        ; pop into rax the top of stack
        pop     rax
        mov     rsp, rbp ; restore rsp pointer to saved registers
        ; pop all the saved registers in reverse order
        pop     r15
        pop     r14
        pop     r13
        pop     r12
        pop     rbx
        pop     rbp
        ret
