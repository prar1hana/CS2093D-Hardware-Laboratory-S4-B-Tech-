#Check if a given number is an Armstrong number or not. [Example: Armstrong Number is 153 as (1*1*1) +(5*5*5) +(3*3*3) = 153.
#Find the number of prime numbers and print them in a given range.
.data
prompt:     .asciiz "Enter a number: "
result_msg: .asciiz "Sum of the cubes of digits: "
newline:    .asciiz "\n"
yes_msg:    .asciiz "Yes, it is an Armstrong number\n"
no_msg:		.asciiz "No, it is not an Armstrong number\n"

.text
.globl main

main:
    # Display prompt
    li $v0, 4
    la $a0, prompt
    syscall

    # Read user input
    li $v0, 5
    syscall
    move $s0, $v0   # Save the entered number in $s0

    # Initialize sum to 0
    li $s1, 0       # $s1 will store the sum of cubes of digits as we will manipulate s0
    move $s2, $s0

loop:
    # Check if the number is zero
    beq $s0, $zero, end_loop

    # Find the last digit
    div $s0, $s0, 10      # Divide by 10
    mfhi $t1              # Remainder is the last digit

    # Compute cube of the digit
    mul $t2, $t1, $t1     # Square the digit
    mul $t2, $t2, $t1     # Cube the digit

    # Update sum
    add $s1, $s1, $t2

    j loop

end_loop:
    # Display the result msg
    li $v0, 4
    la $a0, result_msg
    syscall

    # Display the sum
    move $a0, $s1
    li $v0, 1
    syscall

    # Print newline
    li $v0, 4
    la $a0, newline
    syscall
    
    # Check if the sum equals the original number
    beq $s1, $s2, print_yes
    
     # Print "no"
    li $v0, 4
    la $a0, no_msg
    syscall

    # Exit
    li $v0, 10
    syscall

print_yes:
    # Print "yes"
    li $v0, 4
    la $a0, yes_msg
    syscall

    # Exit
    li $v0, 10
    syscall
