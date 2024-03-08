    .data
prompt: .asciiz "Enter an integer: "
result: .asciiz " is a perfect number.\n"
not_perfectt: .asciiz " is not a perfect number.\n"

    .text
    .globl main

main:
    # Display prompt
    li $v0, 4
    la $a0, prompt
    syscall

    # Read integer from user
    li $v0, 5
    syscall
    move $s0, $v0  # Store the input integer in $s0

    # Initialize sum and divisor
    li $t0, 0   # Sum of divisors
    li $t1, 1   # Divisor

loop_divisors:
    # Check if $t1 is a divisor of $s0
    div $s0, $t1
    mfhi $t2  # Remainder
    beq $t2, $0, add_divisor  # If remainder is 0, $t1 is a divisor

    # Increment divisor and check for termination
    addi $t1, $t1, 1
    blt $t1, $s0, loop_divisors

    # Check if the sum of divisors equals the input integer
    beq $t0, $s0, perfect_number
    j not_perfect

add_divisor:
    # Add divisor to sum
    add $t0, $t0, $t1

    # Increment divisor and check for termination
    addi $t1, $t1, 1
    blt $t1, $s0, loop_divisors

perfect_number:
    # Display result
    li $v0, 4
    la $a0, result
    syscall
    j end_program

not_perfect:
    # Display result
    li $v0, 4
    la $a0, not_perfectt
    syscall

end_program:
    # Exit program
    li $v0, 10
    syscall
