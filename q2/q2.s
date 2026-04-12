.section .rodata
    int_fmt: .string "%d "
    newline_fmt: .string "\n"

.section .bss
    arr: .space 50000
    stack: .space 50000
    result: .space 50000

.section .text

.globl main

main:
    addi sp, sp, -48
    sd ra, 0(sp)
    sd s1, 8(sp)
    sd s2, 16(sp)
    sd s3, 24(sp)
    sd s4, 32(sp)
    sd s5, 40(sp)

    mv s1, a0 # putting the number of arguments in s1
    mv s2, a1 # putting the address of the arguments array in s2

    addi s3, s1, -1 # s3 holds the number of elements i.e. s1 - 1
    
    addi s4, x0, 1 # s4 is loop counter i = 1

parse_loop: # we need to put all of the elements from argv inside of arr one by one because each element in argv is char*
    bge s4, s1, parse_done # if i >= argc, break loop

    slli t0, s4, 3 # t0 = i * 8, argv has 64 bit pointers for each string in char*
    add t0, s2, t0 # t0 holds the address of the current string in argv
    ld a0, 0(t0) # a0 holds the address to the first character of the current string of argv
    call atoi # convert string to integer using atoi

    la t1, arr # load base address of arr in t1
    addi t2, s4, -1 # decrement index by 1
    slli t2, t2, 2 # t2 = index * 4, for 4 bytes per int
    add t1, t1, t2 # t1 holds address of the current position in arr
    sw a0, 0(t1) # putting the current string into the current position in the arr

    addi s4, s4, 1 # incrementing counter
    j parse_loop

parse_done:
    addi s4, x0, 0 # set loop counter to 0

init_result_loop:
    bge s4, s3, init_result_done # if i >= n, done initializing

    la t1, result # put base address of result in t1
    slli t2, s4, 2 # t2 = i * 4
    add t1, t1, t2 # t1 golds the address to the current element of result
    li t3, -1 # set t3 to -1
    sw t3, 0(t1) # set current element of array to -1

    addi s4, s4, 1 # increment the loop counter
    j init_result_loop

init_result_done:
    addi s4, s3, -1 # s4 is loop counter i = n - 1
    addi s5, x0, 0 # s5 holds the current stack size

main_loop:
    blt s4, x0, print_loop_init # if i < 0, all elements iterated

while_loop:
    beq s5, x0, while_done # if stack is empty, exit loop

    la t0, stack # load base address of stack in t0
    addi t1, s5, -1 # set index to size of stack - 1
    slli t1, t1, 2 # t1 = index * 4
    add t0, t0, t1 # t0 golds the address of the top element of the stack
    lw t1, 0(t0) # t1 holds the index of the top element of stack

    la t2, arr # load base address of arr
    slli t4, t1, 2 # t4 = top index of stack * 4
    add t2, t2, t4 # t2 holds the address of the corresponding element in the array
    lw t3, 0(t2) # t3 holds the corresponding element in the array

    la t4, arr # load base address of arr
    slli t6, s4, 2 # t6 = i * 4
    add t4, t4, t6 # t4 holds the address of the current element of arr
    lw t5, 0(t4) # t5 holds the value of the current element of arr

    bgt t3, t5, while_done # if the corresponding arr element at index of top of stack is greater than the current element of the arr, exit while loop

    # Pop from stack
    addi s5, s5, -1 # decrementing stack size
    j while_loop

while_done:
    beq s5, x0, skip_result # if stack is empty, skip updating the result

    la t0, stack # load base address of stack in t0
    addi t1, s5, -1 # setting index to stack size - 1
    slli t1, t1, 2 # t1 = index * 4
    add t0, t0, t1 # t0 holds the address of the top element of the stack
    lw t1, 0(t0) # t1 holds the index at the top of the stack

    la t2, result # load base address of result in t2
    slli t4, s4, 2 # t4 = i * 4
    add t2, t2, t4 # t2 stores the address of the current element of the result array
    sw t1, 0(t2) # setting current element of result array to top of stack

skip_result:
    la t0, stack # load base address of stack in t0
    slli t1, s5, 2 # t1 = stack size * 4
    add t0, t0, t1 # t0 holds the address of the last element of stack
    sw s4, 0(t0) # setting last element of stack to s4
    addi s5, s5, 1 # incrementing stack size

    addi s4, s4, -1 # decrementing loop counter
    j main_loop

print_loop_init:
    addi s4, x0, 0 # s4 holds the loop counter i = 0

print_loop:
    bge s4, s3, end_program # if i >= n, done printing

    la t0, result # load base address of result in t0
    slli t1, s4, 2 # t1 = i * 4
    add t0, t0, t1 # t0 holds address of current element of result array
    lw a1, 0(t0) # a1 holds current element of result array

    la a0, int_fmt # loading address of int_fmt in first argument
    call printf

    addi s4, s4, 1 # incrementing the loop counter
    j print_loop

end_program:
    la a0, newline_fmt # loading address of '\n' in a0
    call printf

    ld ra, 0(sp)
    ld s1, 8(sp)
    ld s2, 16(sp)
    ld s3, 24(sp)
    ld s4, 32(sp)
    ld s5, 40(sp)
    addi sp, sp, 48
    ret
