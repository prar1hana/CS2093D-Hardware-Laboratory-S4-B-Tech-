# q4 Convert a given 32-bit binary number to its decimal equivalent.
.data
    prompt: .asciiz "Enter a 32-bit binary number: "
    decimal: .asciiz "\n The decimal equivalent is: "
    buffer: .space 33  # Increase buffer size by 1 to store null terminator

.text
    main:
        # Prompt user to enter a 32-bit binary number
        li $v0, 4
        la $a0, prompt
        syscall

        # Read the binary number
        li $v0, 8
        la $a0, buffer
        li $a1, 33  # Read up to 33 characters plus null terminator
        syscall

        # Convert the binary number to decimal
        la $s0, buffer   # Address of the buffer
        addi $s0, $s0, 31  # Move to the last character (32nd character)
        li $s1, 0        # Decimal result
        li $t2, 1        # Tracks power of 2
        li $s4, 1
          li $s5, 1	

    loop:
        lb $s2, 0($s0)   # Load the current bit
        beq $s4, 32, MSB
        sub $s2, $s2, 48 # Convert from ASCII to integer ('0' = 48)
        mul $s2, $s2, $s5  # Multiply the bit by 2^i
        add $s1, $s1, $s2  # Add the result to the decimal
	
        mul $s5, $s5, 2  # Update the power of 2
        subi $s0, $s0, 1  # Move to the left bit
        addi $s4, $s4, 1
    
        
        j loop           # Repeat the loop

    MSB:
        sub $s2, $s2, 48  # Convert from ASCII to integer ('0' = 48)
     	beq $s2, 1, negative  
     	   # Print the decimal equivalent
        li $v0, 4
        la $a0, decimal
        syscall

        li $v0, 1
        move $a0, $s1
        syscall

        # Exit program
        li $v0, 10
        syscall
        
   negative:
   
   	mul $s1, $s1, -1
   	
        # Print the decimal equivalent
        li $v0, 4
        la $a0, decimal
        syscall

        li $v0, 1
        move $a0, $s1
        syscall

        # Exit program
        li $v0, 10
        syscall

