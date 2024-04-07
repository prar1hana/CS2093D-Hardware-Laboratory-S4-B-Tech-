module MIPS_Processor_Testbench;

// Parameters
parameter CLK_PERIOD = 10; // Clock period in ns

// Signals
reg clk;
reg reset;
reg [15:0] instruction;
reg [15:0] data_in;
wire [15:0] data_out;
wire [7:0] reg_file [0:7];
wire carry_flag;
wire zero_flag;
wire [15:0] pc;

// Instantiate the MIPS processor module
MIPS_Processor dut (
    .clk(clk),
    .reset(reset),
    .instruction(instruction),
    .data_in(data_in),
    .data_out(data_out),
    .reg_file(reg_file),
    .carry_flag(carry_flag),
    .zero_flag(zero_flag),
    .pc(pc)
);

// Clock generation
always #((CLK_PERIOD)/2) clk = ~clk;

// Reset generation
initial begin
    clk = 0;
    reset = 1;
    #50; // Reset for 50 ns
    reset = 0;
end

// Test cases
initial begin
    // Test case 1: ADD instruction
    instruction = 16'b0000_0000_0000_0110; // ADD R6, R0, R0
    data_in = 0;
    #100;
    // Verify results
    $display("Test Case 1 Results:");
    $display("Register R6: %h", reg_file[6]);
    $display("Carry Flag: %b", carry_flag);
    $display("Zero Flag: %b", zero_flag);
    $display("PC: %h", pc);
    $display("");
    
    // Test case 2: LW instruction
    instruction = 16'b0100_0010_0000_0010; // LW R2, R0, 2
    data_in = 16'hABCD; // Sample data at memory address 2
    #100;
    // Verify results
    $display("Test Case 2 Results:");
    $display("Register R2: %h", reg_file[2]);
    $display("Zero Flag: %b", zero_flag);
    $display("");
    
    // Add more test cases here...
    
    // End simulation
    $finish;
end

endmodule
