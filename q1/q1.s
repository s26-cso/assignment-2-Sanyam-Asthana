.section .rodata
    pointer_fmt: .string "%p\n"
    int_fmt: .string "%d\n"

.section .bss

.section .text

.globl make_node
.globl insert
.globl get
.globl getAtMost

make_node:
    addi sp, sp, -16
    sd ra, 0(sp)
    sd s1, 8(sp)

    mv s1, a0 # storing val in s1
    addi a0, x0, 24 # 8 (int val + padding) + 8 (left pointer) + 8 (right pointer)
    call malloc

    sw s1, 0(a0) # storing val at the first field of the struct (int, 4 bytes)
    sd x0, 8(a0) # storing NULL at the left field of the struct
    sd x0, 16(a0) # storing NULL at the right field of the struct

    ld ra, 0(sp)
    ld s1, 8(sp)
    addi sp, sp, 16
    ret

insert:
    addi sp, sp, -32
    sd ra, 0(sp)
    sd s1, 8(sp)
    sd s2, 16(sp)
    sd s3, 24(sp)

    mv s1, a0 # storing the address of root in s1
    mv s3, a1 # storing val in s3

    beq s1, x0, insert_null # if root is NULL, create a new node and return it

    lw s2, 0(s1) # s2 holds the value of the root node (int, 4 bytes)

    bge s3, s2, insert_right

insert_left:
    ld t2, 8(s1) # t2 holds the address of the left child of the root node

    beq t2, x0, insert_left_leaf # if the left child is NULL, insert the node

    mv a0, t2 # storing the address of the left child in first argument
    mv a1, s3 # storing val in second argument
    call insert # recurse into left subtree

    j insert_ret

insert_left_leaf:
    mv a0, s3 # storing val in first argument
    call make_node # allocate the new node only here

    sd a0, 8(s1) # storing the address of the new node in the left field of the root node

    j insert_ret

insert_right:
    ld t2, 16(s1) # t2 holds the address of the right child of the root node

    beq t2, x0, insert_right_leaf # if the right child is NULL, insert the node

    mv a0, t2 # storing the address of the right child in first argument
    mv a1, s3 # storing val in second argument
    call insert # recurse into right subtree

    j insert_ret

insert_right_leaf:
    mv a0, s3 # storing val in first argument
    call make_node # allocate the new node only here

    sd a0, 16(s1) # storing the address of the new node in the right field of the root node

    j insert_ret

insert_null:
    mv a0, s3 # storing val in first argument
    call make_node # allocate the new node and return it as the new root

    j insert_done # a0 already holds the new node, skip the mv below

insert_ret:
    mv a0, s1 # return the original root

insert_done:
    ld ra, 0(sp)
    ld s1, 8(sp)
    ld s2, 16(sp)
    ld s3, 24(sp)
    addi sp, sp, 32
    ret


get:
    addi sp, sp, -16
    sd ra, 0(sp)
    sd s1, 8(sp)

    mv s1, a0 # storing the address of root in s1

    beq s1, x0, get_not_found # if root is NULL, return NULL

    ld t1, 0(s1) # t1 holds the value of the root node

    beq a1, t1, get_found # if val of the current node is equal to target val, return root

    blt a1, t1, get_left # if val of the current node is greater than the target val, search left subtree

get_right:
    ld a0, 16(s1) # a0 holds the address of the right child
    call get # recurse into right subtree

    j get_done

get_left:
    ld a0, 8(s1) # a0 holds the address of the left child
    call get # recurse into left subtree

    j get_done

get_found:
    mv a0, s1 # return the current node

    j get_done

get_not_found:
    mv a0, x0 # return NULL

get_done:
    ld ra, 0(sp)
    ld s1, 8(sp)
    addi sp, sp, 16
    ret


getAtMost:
    addi sp, sp, -32
    sd ra, 0(sp)
    sd s1, 8(sp)
    sd s2, 16(sp)
    sd s3, 24(sp)

    mv s2, a0 # storing val in s2
    mv s1, a1 # storing the address of root in s1

    li s3, -1 # s3 holds the best result yet (default -1)

getAtMost_loop:
    beq s1, x0, getAtMost_done # if current node is NULL, we are done

    ld t1, 0(s1) # t1 holds the value of the current node (int, 4 bytes)

    bgt t1, s2, getAtMost_go_left # if val of the current node is greater than target val, go left

    mv s3, t1 # update best result
    ld s1, 16(s1) # go right to look for a larger valid result

    j getAtMost_loop

getAtMost_go_left:
    ld s1, 8(s1) # s1 holds the left child of the node

    j getAtMost_loop

getAtMost_done:
    mv a0, s3 # return the best result

    ld ra, 0(sp)
    ld s1, 8(sp)
    ld s2, 16(sp)
    ld s3, 24(sp)
    addi sp, sp, 32
    ret
