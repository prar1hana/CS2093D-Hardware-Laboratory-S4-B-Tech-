# Change the case (upper to lower and vice versa) of all the alphabets in a given string.
.data
prompt:     .asciiz "Enter a string: "   # Prompt message
buffer:     .space  100                  # Buffer to store user input
new_line:   .asciiz "\n"                 # New line character for formatting

.text
.globl main

main:
    # Print prompt message
    li $v0, 4            # syscall code 4 for print string
    la $a0, prompt       # load address of the prompt message
    syscall

    # Read user input
    li $v0, 8            # syscall code 8 for read string
    la $a0, buffer       # load address of the buffer
    li $a1, 100          # maximum number of characters to read
    syscall

    # Process the string to change case
    la $a0, buffer       # load address of the input string
    jal change_case      # jump to change_case subroutine

    # Print the modified string
    li $v0, 4            # syscall code 4 for print string
    la $a0, buffer       # load address of the modified string
    syscall

    # Print new line for formatting
    li $v0, 4            # syscall code 4 for print string
    la $a0, new_line     # load address of the new line character
    syscall

    # Exit the program
    li $v0, 10           # syscall code 10 for exit
    syscall

change_case:
    # Loop through the string until null terminator
loop:
    lb $t0, 0($a0)      # Load a byte from the string into $t0

    # Check if the byte is a lowercase alphabet (ASCII range: 97-122)
    li $t1, 97
    bge $t0, $t1, lower_check

    # Check if the byte is an uppercase alphabet (ASCII range: 65-90)
    li $t1, 65
    bge $t0, $t1, upper_check

    # If it's not an alphabet, continue to the next character
    j next_char

lower_check:
    # If the character is lowercase, convert it to uppercase
    li $t1, 122      # ASCII value of 'z'
    bgt $t0, $t1, next_char
    li $t1, 97       # ASCII value of 'a'
    sub $t0, $t0, $t1  # Convert to 0-based indexing
    li $t1, 65       # ASCII value of 'A'
    add $t0, $t0, $t1  # Convert to uppercase
    j next_char

upper_check:
    # If the character is uppercase, convert it to lowercase
    li $t1, 90       # ASCII value of 'Z'
    bgt $t0, $t1, next_char
    li $t1, 65       # ASCII value of 'A'
    sub $t0, $t0, $t1  # Convert to 0-based indexing
    li $t1, 97       # ASCII value of 'a'
    add $t0, $t0, $t1  # Convert to lowercase

next_char:
    sb $t0, 0($a0)   # Store the modified byte back to the string
    addi $a0, $a0, 1  # Move to the next character

    # Check for end of string
    lb $t0, 0($a0)
    beqz $t0, end_loop

    # Repeat the loop
    j loop

end_loop:
    jr $ra             # Return from subroutine
