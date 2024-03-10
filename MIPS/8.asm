#8. Find a given element (key) from the input array using a linear search.
.data
prompt_array_size:  .asciiz "Enter the size of the array: "
prompt_array_element: .asciiz "Enter element "
prompt_key:         .asciiz "Enter the key to search for: "
found_message:      .asciiz "least index at ehich the key is found "
not_found_message:  .asciiz "Key not found in the array"
newline:            .asciiz "\n"
base_address:       .word 0  # Memory location to store the base address

.text
.globl main

main:
    # Prompt user to enter array size
    li $v0, 4
    la $a0, prompt_array_size
    syscall
    
    # Read array size from user input
    li $v0, 5
    syscall
    move $s1, $v0  # $s1 = array size
    
    # Allocate memory for the array
    sll $s2, $s1, 2 # $s2 = array size * 4
    li $v0, 9       # Allocates memory of size a0 and returns base address to v0
    move $a0, $s2   # $a0 = memory size
    syscall
    move $s0, $v0   # $s0 = base address of the array
    sw $s0, base_address  # Store the base address in memory
    
    # Prompt user to enter array elements
    li $s3, 0       # $s3 = loop counter
fill_array_loop:
    beq $s3, $s1, search_key
    addi $s3, $s3, 1
    li $v0, 4
    la $a0, prompt_array_element
    syscall
    li $v0, 5       # Read integer number from user
    syscall
    sw $v0, ($s0)   # Store array element at base address + offset
    addi $s0, $s0, 4 # Move to the next element
    j fill_array_loop

search_key:
    # Prompt user to enter the key
    li $v0, 4
    la $a0, prompt_key
    syscall

    # Read key from user input
    li $v0, 5
    syscall
    move $s5, $v0   # $s5 = key
    
    # Load base address of the array
    lw $s0, base_address  # Load the base address from memory
    
    # Linear search
    li $s3, 0       # $s3 = loop counter
search_loop:
    beq $s3, $s1, key_not_found
    lw $s6, ($s0)   # Load array element at base address + offset
    beq $s6, $s5, key_found
    addi $s0, $s0, 4 # Move to the next element
    addi $s3, $s3, 1 # Increment loop counter
    j search_loop

key_found:
    li $v0, 4
    la $a0, found_message
    syscall
    move $a0, $s3   # Index of the found key
    li $v0, 1
    syscall
    j end_program

key_not_found:
    li $v0, 4
    la $a0, not_found_message
    syscall

end_program:
    li $v0, 10      # Exit program
    syscall
