.section .rodata

output_int_fmt:
    .string "%d\n"

file_name:
    .string "input.txt"

yes_str:
    .string "Yes"

no_str:
    .string "No"

.section .bss

file_buffer:
    .space 1024

.section .text

.globl main

main:
    add sp, sp, -16
    sd ra, 0(sp)

    addi a7, x0, 56 # setting a7 to 56, which is syscall instruction for openat
    addi a0, x0, -100 # AT_FDCWD (current working directory)
    la a1, file_name # loading the file_name string's address in first argument
    addi a2, x0, 0 # Read-only mode
    addi a3, x0, 0 # mode
    ecall
    mv s0, a0 # moving the fd into s0

    add a7, x0, 63 # syscall for read
    mv a0, s0 # reading the fd
    la a1, file_buffer # loading the address of the file_buffer into first argument
    li a2, 256 # max number of bytes to be read
    ecall
    mv s1, a0

    j do_operations

cleanup:
    addi a7, x0, 57 # syscall for closing file
    mv a0, s0
    ecall

    addi a0, x0, 0
    ld ra, 0(sp)
    add sp, sp, 16
    ret

do_operations:
    la a0, file_buffer
    call strlen
    mv t0, a0 # t0 holds the length of the string
    
    la a4, file_buffer # a4 holds the address of the start of the string
    add a5, a4, t0 # a5 holds the address of the end of the string
    addi a5, a5, -2 # decrementing a5 to skip null character and newline character

    j loop

loop:
    lb t3, 0(a4) # loading character at position of the front pointer
    lb t4, 0(a5) # loading character at position of the rear pointer

    bne t3, t4, not_palindrome # if the front and rear character are not equal, jump to negative branch

    addi a4, a4, 1 # increment front pointer by 1
    addi a5, a5, -1 # decrement rear pointer by 1

    bge a5, a4, loop # if the rear pointer is greater than or equal to the front pointer, continue the loop 

    j palindrome # if there were no breaks, the string is a palindrome, jump to positive branch

palindrome:
    la a0, yes_str
    call puts
    call cleanup

not_palindrome:
    la a0, no_str
    call puts
    call cleanup

    
