    .data
A_prompt: .asciiz "Enter the value of A (in binary): "
B_label:  .asciiz "The 2's complement of A (B) is: "
result_label: .asciiz "The result of A + B is: "
newline:  .asciiz "\n"

    .text
    .globl main

main:
    # Print prompt for A
    li $v0, 4             # Print string service
    la $a0, A_prompt      # Load address of prompt for A
    syscall               # Call system
    
    # Read input for A
    li $v0, 5             # Read integer service
    syscall               # Call system
    move $t0, $v0         # Store A in $t0
    
    # Compute 2's complement of A (B)
    nor $t1, $t0, $zero   # NOT A
    addi $t1, $t1, 1      # Add 1 to NOT A (2's complement)
    
    # Print B
    li $v0, 4             # Print string service
    la $a0, B_label       # Load address of label for B
    syscall               # Call system
    move $a0, $t1         # Load B into $a0
    li $v0, 1             # Print integer service
    syscall               # Call system
    li $v0, 4             # Print string service
    la $a0, newline       # Load address of newline
    syscall               # Call system
    
    # Add A and B
    add $t2, $t0, $t1
    
    # Print the result
    li $v0, 4             # Print string service
    la $a0, result_label  # Load address of label for result
    syscall               # Call system
    move $a0, $t2         # Load result into $a0
    li $v0, 1             # Print integer service
    syscall               # Call system
    li $v0, 4             # Print string service
    la $a0, newline       # Load address of newline
    syscall               # Call system
    
    # Exit
    li $v0, 10            # Exit program
    syscall
