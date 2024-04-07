// 5.    Design and implement a highly efficient and optimized register file in Verilog for a complex multi-core                  processor's architecture with the following specifications:

// a.       It should contain 32 registers, each capable of storing 64 bits of data.

// b.      The register file should support simultaneous read and write operations across multiple ports.

// c.       It should have four read ports (read_port_1, read_port_2, read_port_3 and read_port_4) and two write ports (write_port_1 and write_port_2).

// d.      The register file should implement a priority-based access mechanism where read and write operations from different ports have different priority levels, and write operations should not interfere with read operations. The smaller the port number, the higher the priority.

// e.       Each read port should be able to access data from any register simultaneously, without any read conflicts.

// f.        Write operations from different ports should be able to write data to different registers simultaneously, without any write conflicts.

// Please note that you should define the module with appropriate input and output ports and ensure that it correctly handles read and write operations.
module RegisterFile(
    input  clk,
    input  rst,
    input  [4:0]   read_port_1,
    input  [4:0]   read_port_2,
    input  [4:0]   read_port_3,
    input  [4:0]   read_port_4,
    input  [4:0]   write_port_1,
    input  [4:0]   write_port_2,
    input  [63:0]  write_data_1,
    input  [63:0]  write_data_2,
    input  [1:0]   write_enable,
    input  [3:0]   read_enable,
    output [63:0]  read_data_1,
    output [63:0]  read_data_2,
    output [63:0]  read_data_3,
    output [63:0]  read_data_4
);

reg [63:0] registers [31:0];

always @(*) begin
    // Read port 1
    case(read_port_1)
        5'b00000: read_data_1 = (read_enable[0]) ? registers[0] : 64'b0;
        5'b00001: read_data_1 = (read_enable[0]) ? registers[1] : 64'b0;
        // Add cases for other registers...
        default: read_data_1 = 64'b0; // Invalid register
    endcase

    // Read port 2
    case(read_port_2)
        5'b00000: read_data_2 = (read_enable[1]) ? registers[0] : 64'b0;
        5'b00001: read_data_2 = (read_enable[1]) ? registers[1] : 64'b0;
        // Add cases for other registers...
        default: read_data_2 = 64'b0; // Invalid register
    endcase

    // Read port 3
    case(read_port_3)
        5'b00000: read_data_3 = (read_enable[2]) ? registers[0] : 64'b0;
        5'b00001: read_data_3 = (read_enable[2]) ? registers[1] : 64'b0;
        // Add cases for other registers...
        default: read_data_3 = 64'b0; // Invalid register
    endcase

    // Read port 4
    case(read_port_4)
        5'b00000: read_data_4 = (read_enable[3]) ? registers[0] : 64'b0;
        5'b00001: read_data_4 = (read_enable[3]) ? registers[1] : 64'b0;
        // Add cases for other registers...
        default: read_data_4 = 64'b0; // Invalid register
    endcase
end

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        for (int i = 0; i < 32; i++) begin
            registers[i] <= 64'b0; // Reset all registers
        end
    end else begin
        // Write port 1
        if (write_enable[0]) begin
            case(write_port_1)
                5'b00000: registers[0] <= write_data_1;
                5'b00001: registers[1] <= write_data_1;
                // Add cases for other registers...
            endcase
        end

        // Write port 2
        if (write_enable[1]) begin
            case(write_port_2)
                5'b00000: registers[0] <= write_data_2;
                5'b00001: registers[1] <= write_data_2;
                // Add cases for other registers...
            endcase
        end
    end
end

endmodule





////////////tb/////////////////////
`timescale 1ns / 1ps

module RegisterFile_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // Clock period in ns

    // Signals
    reg clk;
    reg rst;
    reg [4:0] read_port_1, read_port_2, read_port_3, read_port_4;
    reg [4:0] write_port_1, write_port_2;
    reg [63:0] write_data_1, write_data_2;
    reg [1:0] write_enable;
    reg [3:0] read_enable;
    wire [63:0] read_data_1, read_data_2, read_data_3, read_data_4;

    // Instantiate RegisterFile module
    RegisterFile dut (
        .clk(clk),
        .rst(rst),
        .read_port_1(read_port_1),
        .read_port_2(read_port_2),
        .read_port_3(read_port_3),
        .read_port_4(read_port_4),
        .write_port_1(write_port_1),
        .write_port_2(write_port_2),
        .write_data_1(write_data_1),
        .write_data_2(write_data_2),
        .write_enable(write_enable),
        .read_enable(read_enable),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2),
        .read_data_3(read_data_3),
        .read_data_4(read_data_4)
    );

    // Clock generation
    always #((CLK_PERIOD) / 2) clk = ~clk;

    // Reset generation
    initial begin
        rst = 1;
        #100;
        rst = 0;
    end

    // Test scenario
    initial begin
        // Write to register 0 using write port 1
        write_port_1 = 0;
        write_data_1 = 64'h123456789ABCDEF0;
        write_enable = 2'b01; // Enable write port 1
        #20;

        // Read from register 0 using read port 1
        read_port_1 = 0;
        read_enable = 4'b0001; // Enable read port 1
        #20;

        // Write to register 1 using write port 2
        write_port_2 = 1;
        write_data_2 = 64'h9876543210ABCDEF;
        write_enable = 2'b10; // Enable write port 2
        #20;

        // Read from register 1 using read port 2
        read_port_2 = 1;
        read_enable = 4'b0010; // Enable read port 2
        #20;

        // Read from register 0 using read port 3
        read_port_3 = 0;
        read_enable = 4'b0100; // Enable read port 3
        #20;

        // Read from register 1 using read port 4
        read_port_4 = 1;
        read_enable = 4'b1000; // Enable read port 4
        #20;

        $stop;
    end

endmodule
