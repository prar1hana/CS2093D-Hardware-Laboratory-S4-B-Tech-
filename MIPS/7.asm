.data
prompt: .asciiz "Enter the upper bound of the range: "
lower_bound_prompt: .asciiz "Enter the lower bound: "
result: .asciiz "The prime numbers in the range are: "
count_msg: .asciiz "\nThe total number of prime numbers found: "
space: .asciiz " "

.text
.globl main

main:
    # Print prompt
    li $v0, 4
    la $a0, prompt
    syscall
    
    # Read user input (upper bound)
    li $v0, 5
    syscall
    move $s0, $v0  # $s0 = input number (upper bound)
    
    # Read lower bound
    li $v0, 4
    la $a0, lower_bound_prompt
    syscall
    
    # Read user input (lower bound)
    li $v0, 5
    syscall
    move $s1, $v0  # $s1 = lower bound
    
    # Print result message
    li $v0, 4
    la $a0, result
    syscall

    # Initialize counter for prime numbers
    li $s6, 0
    
    # Print prime numbers greater than or equal to lower bound and less than or equal to input number
    move $s2, $s1      # Initialize $s2 to lower bound
    
loop:
    # Check if $s2 is greater than input number, if so, exit loop
    bgt $s2, $s0, end_loop
    
    # Check if $s2 is a prime number
    move $a0, $s2  # Argument for is_prime function
    jal is_prime
    
    # If $t0 (result of is_prime) is 1, $s2 is prime
    beq $t0, 1, print_prime
    
    # Otherwise, increment $s2 and repeat loop
    addi $s2, $s2, 1
    j loop

print_prime:
    # Print prime number
    li $v0, 1
    move $a0, $s2
    syscall
    
    # Print space
    li $v0, 4
    la $a0, space
    syscall
    
    # Increment counter for prime numbers
    addi $s6, $s6, 1
    
    # Increment $s2 and repeat loop
    addi $s2, $s2, 1
    j loop

end_loop:
    # Print the total number of prime numbers found
    li $v0, 4
    la $a0, count_msg
    syscall

    # Print the count stored in $s6
    move $a0, $s6
    li $v0, 1
    syscall

    # Exit program
    li $v0, 10
    syscall

is_prime:
    # Check if input number in $a0 is prime
    # $a0: number to check for primality
    # $t0: 1 if prime, 0 otherwise
    
    li $t0, 1       # Assume number is prime
    li $s3, 2       # Initialize divisor to 2
    
    loop_prime:
        bge $s3, $a0, end_is_prime    # If divisor >= number, end loop
        
        div $a0, $s3    # Divide number by divisor
        mfhi $s4        # Remainder
        
        # If remainder is 0, number is not prime
        beq $s4, $zero, not_prime
        
        addi $s3, $s3, 1    # Increment divisor
        j loop_prime
    
    not_prime:
        li $t0, 0   # Set $t0 to 0 to indicate not prime
        j end_is_prime
    
    end_is_prime:
        jr $ra  # Return
