// 4.    Design and implement a register file in Verilog for a simple processor with the following specifications:

// a.       It should contain 8 registers, each capable of storing 8 bits of data.

// b.      The register file should support reading from and writing to any register.

// c.       It should have two read ports (read_port_1 and read_port_2) and one write port (write_port_1).

// d.      The register file should be able to read data from two different registers simultaneously for parallel operations. However, only one kind of operation should be allowed on the register file: either read or write.

// Please note that you should define the module with appropriate input and output ports and ensure that it correctly handles read and write operations

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

reg [DATA_WIDTH-1:0] register_data;

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
