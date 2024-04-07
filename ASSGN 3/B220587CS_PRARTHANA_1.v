// 1. Design and implement a register in Verilog for a custom processor's architecture with the following specifications:
// a.   	It should be a 16-bit register.
// b.  	It should have one read port (read_port_1) and one write port (write_port_1).
// c.   	Only one operation, either read or write, can be performed at a time on the register.
// d.  	Each read port should be able to access data from the register without any conflicts with write operations.
// Please note that you should define the module with appropriate input and output ports and ensure that it meets all the specified requirements above.

module register_16bit (
    input wire clk,
    input wire reset,
    input wire write_enable,
    input wire [15:0] write_data,
    input wire read_enable,
    output reg [15:0] read_data
);

// Internal register to hold the data, initialized to 16'h0000
reg [15:0] reg_data = 16'h0000;

// On positive edge of the clock
always @(posedge clk) begin
    // Reset the register if reset signal is asserted
    if (reset) begin
        reg_data <= 16'h0000;
        $display("Register has been reset");
    end
    // Read operation takes precedence over write operation
    else if (read_enable) begin
        read_data <= reg_data;
        $display("You have successfully read the value %d", reg_data);
    end
    // Write operation
    else if (write_enable) begin
        reg_data <= write_data;
        $display("You have successfully written the value %d", write_data);
    end
    // Neither read nor write operation
    else begin
        $display("You didn't choose");
    end
end

endmodule
