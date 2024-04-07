module MIPS_Processor(
    input wire clk,
    input wire reset,
    input wire [15:0] instruction,
    input wire [15:0] data_in,
    output reg [15:0] data_out,
    output reg [7:0] reg_file [0:7], // Registers R0 to R7
    output reg carry_flag,
    output reg zero_flag,
    output reg [15:0] pc
);

// Define opcode constants
parameter OP_ADD = 4'b0000;
parameter OP_NDU = 4'b0010;
parameter OP_LW = 4'b0100;
parameter OP_SW = 4'b0101;
parameter OP_BEQ = 4'b1100;
parameter OP_JAL = 4'b1000;

// Define opcode field widths
parameter OP_WIDTH = 4;
parameter RA_WIDTH = 3;
parameter RB_WIDTH = 3;
parameter RC_WIDTH = 3;
parameter IMM_WIDTH = 6;
parameter OFFSET_WIDTH = 9;

// Define instruction fields
reg [OP_WIDTH-1:0] opcode;
reg [RA_WIDTH-1:0] reg_a;
reg [RB_WIDTH-1:0] reg_b;
reg [RC_WIDTH-1:0] reg_c;
reg signed [IMM_WIDTH-1:0] immediate;
reg signed [OFFSET_WIDTH-1:0] offset;

// Decode instruction
always @(posedge clk or posedge reset) begin
    if (reset) begin
        opcode <= 0;
        reg_a <= 0;
        reg_b <= 0;
        reg_c <= 0;
        immediate <= 0;
        offset <= 0;
    end
    else begin
        opcode <= instruction[15:12];
        reg_a <= instruction[11:9];
        reg_b <= instruction[8:6];
        reg_c <= instruction[5:3];
        immediate <= { {IMM_WIDTH-6{instruction[5]}}, instruction[4:0] };
        offset <= { {OFFSET_WIDTH-9{instruction[8]}}, instruction[7:0] };
    end
end

// Execute instruction
always @(posedge clk or posedge reset) begin
    if (reset)
        carry_flag <= 0;
        zero_flag <= 0;
        pc <= 0;
    else begin
        case(opcode)
            // ADD instruction
            OP_ADD: begin
                reg_file[reg_c] <= reg_file[reg_a] + reg_file[reg_b];
                carry_flag <= reg_file[reg_c][16];
                zero_flag <= (reg_file[reg_c] == 0);
            end
            // NDU instruction
            OP_NDU: begin
                reg_file[reg_c] <= ~(reg_file[reg_a] & reg_file[reg_b]);
                carry_flag <= reg_file[reg_c][16];
                zero_flag <= (reg_file[reg_c] == 0);
            end
            // LW instruction
            OP_LW: begin
                data_out <= data_in;
                reg_file[reg_a] <= data_out;
                zero_flag <= (data_out == 0);
            end
            // SW instruction
            OP_SW: begin
                data_out <= reg_file[reg_a];
                // Store data_out to memory at address formed by adding immediate with content of reg B
            end
            // BEQ instruction
            OP_BEQ: begin
                if (reg_file[reg_a] == reg_file[reg_b])
                    pc <= pc + offset;
            end
            // JAL instruction
            OP_JAL: begin
                reg_file[reg_a] <= pc + 1;
                pc <= pc + immediate;
            end
        endcase
    end
end

endmodule
