#2. Compute the factorial of a given positive number. 
.data
prompt: .asciiz "Enter a positive number: "
result: .asciiz "Factorial: "

.text
.globl main

main:
    # Display prompt
    li $v0, 4           # syscall code for printing string
    la $a0, prompt      # load address of prompt string
    syscall

    # Read input
    li $v0, 5           # syscall code for reading integer
    syscall
    move $t0, $v0       # store input in $t0

    # Check if input is positive
    blez $t0, end       # if input <= 0, skip calculation

    # Initialize variables
    li $t1, 1           # factorial = 1
    li $t2, 1           # counter = 1

loop:
    # Check if counter > input
    bgt $t2, $t0, end_loop

    # Multiply factorial by counter
    mul $t1, $t1, $t2

    # Increment counter
    addi $t2, $t2, 1

    # Repeat loop
    j loop

end_loop:
    # Display result
    li $v0, 4           # syscall code for printing string
    la $a0, result      # load address of result string
    syscall

    # Print factorial
    li $v0, 1           # syscall code for printing integer
    move $a0, $t1       # load factorial value
    syscall

end:
    # Exit program
    li $v0, 10          # syscall code for exit
    syscall
