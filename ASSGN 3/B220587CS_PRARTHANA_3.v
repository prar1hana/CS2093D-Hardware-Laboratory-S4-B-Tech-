// 3.    Design and implement a register in Verilog for a custom processor's architecture with the following specifications:

// a.       It should be parameterized to support different data widths ranging from 8 bits to 32 bits.

// b.      It should have one read port (read_port_1) and one write port (write_port_1).

// c.       Both operations, read or write, are allowed at a time on the register.

// d.      If both operations are performed on the register, then the write operation has more priority over read operation.

// Please note that you should define the module with appropriate input and output ports and ensure that it meets all the specified requirements above.


module custom_register
#(
    parameter DATA_WIDTH = 8 // Default data width is 8 bits
)
(
    input wire clk,
    input wire reset,
    input wire read_en,
    input wire write_en,
    input wire [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out
);

reg [DATA_WIDTH-1:0] register_data = 0; // Initialize register_data to 0

always @(posedge clk or posedge reset) begin
    if (reset) begin
        register_data <= 0;
    end else begin
        if (write_en) begin
            register_data <= data_in;
        end
    end
    
    if (read_en) begin
        data_out <= register_data;
    end else begin
        data_out <= 'bz; // Tri-state output if read is not enabled
    end
end

endmodule
