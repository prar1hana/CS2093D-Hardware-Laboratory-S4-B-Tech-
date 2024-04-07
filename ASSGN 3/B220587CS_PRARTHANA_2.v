// 2. Design and implement a register in Verilog for a custom processor's architecture with the following specifications:
// a.   	It should be a 16-bit register.
// b.  	It should have one read port (read_port_1) and two write port (write_port_1 and write_port_2).
// c.   	Only one operation, either read or write, can be performed at a time on the register. However, write operations can be performed from write ports alternatively, i.e., if a previous write is done using write_port_1, then the next write will be done using write_port_2, and vice versa.
// d.  	Each read port should be able to access data from the register without any conflicts with write operations.
// Please note that you should define the module with appropriate input and output ports and ensure that it meets all the specified requirements above.
module custom_register (
    input wire clk,
    input wire rst,
    input wire write_enable,
    input wire read_enable,
    input wire [15:0] write_port_1,
    input wire [15:0] write_port_2,
    output reg [15:0] read_port
);

    reg [15:0] register_data = 16'h0000;
    reg toggle_write_port = 1;

    // Synchronous reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            register_data <= 16'h0000; // Reset the register data to 0
            toggle_write_port <= 1;    // Reset the toggle for write ports
        end
        else begin
            // read operation
             if (read_enable)begin
                read_port <= register_data;
             end
            // Write operation
            else if (write_enable) begin
                if (toggle_write_port == 1)
                    register_data <= write_port_1;
                else
                    register_data <= write_port_2;
                toggle_write_port <= ~toggle_write_port;
            end
        end
    end

    // Asynchronous read
    always @* begin
       
    end

endmodule
//note that synchronous operations typically have precedence or priority over asynchronous operations during clock signal transitions
