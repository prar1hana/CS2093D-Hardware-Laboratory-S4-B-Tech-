#1. Check if the given positive number is odd or even
    .data
    prompt: .asciiz "Enter a positive number: "
    odd_msg: .asciiz "The number is odd.\n"
    even_msg: .asciiz "The number is even.\n"

    .text
    .globl main

main:
    # Display prompt
    li $v0, 4
    la $a0, prompt
    syscall
    
    # Read input number
    li $v0, 5
    syscall
    
    # Move the input number to $t0
    move $t0, $v0
    
    # Check if the number is odd or even
    andi $t1, $t0, 1   # Perform bitwise AND with 1
    beq $t1, $zero, even   # If result is 0, the number is even
    # If the result is not zero, the number is odd
    li $v0, 4
    la $a0, odd_msg
    syscall
    j end_program

even:
    li $v0, 4
    la $a0, even_msg
    syscall

end_program:
    # Exit the program
    li $v0, 10
    syscall
