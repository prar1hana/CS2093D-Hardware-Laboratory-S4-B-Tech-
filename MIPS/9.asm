#fiboncci series 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233
#9. Find the nth Fibonacci number for the given number n.
.data
prompt: .asciiz "Enter the value of n: "
result: .asciiz "The nth Fibonacci number is: "
newline: .asciiz "\n"

.text
.globl main

main:
    # Print prompt message
    li $v0, 4
    la $a0, prompt
    syscall

    # Read input n
    li $v0, 5
    syscall
    move $s0, $v0  # save n to $s0

    # Initialize variables
    li $t0, 0   # fib(n-2)
    li $t1, 1   # fib(n-1)
    li $t2, 0   # fib(n)

    # Calculate Fibonacci sequence iteratively
    li $t3, 2   # counter
loop:
    beq $t3, $s0, done    # exit loop if counter equals n

    # Calculate next Fibonacci number: fib(n) = fib(n-1) + fib(n-2)
    add $t2, $t0, $t1     # fib(n) = fib(n-2) + fib(n-1)
    move $t0, $t1          # fib(n-2) = fib(n-1)
    move $t1, $t2          # fib(n-1) = fib(n)
    
    # Increment counter
    addi $t3, $t3, 1
    
    j loop

done:
    # Print the result
    li $v0, 4
    la $a0, result
    syscall

    li $v0, 1
    move $a0, $t2
    syscall

    # Exit
    li $v0, 10
    syscall
