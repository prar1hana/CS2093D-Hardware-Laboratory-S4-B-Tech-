///////adder/////////////
`timescale 1ns / 1ps
module adder(input [31:0] a, b,
             output [31:0] y);

  assign y = a + b;
endmodule


////////////alu////////////
module alu(
input [31:0] a, b, 
input [4:0] shamt,
input [3:0] alu_control, 
output reg [31:0] result, wd0, wd1,
output zero
);

wire [31:0] b2, sum, slt, sra_sign, sra_aux;
wire [63:0] product, quotient, remainder;
assign b2 = alu_control[2] ? ~b:b; 
assign sum = a + b2 + alu_control[2];
assign slt = sum[31];
assign sra_sign = 32'b1111_1111_1111_1111 << (32 - shamt);
assign sra_aux = b >> shamt;
assign product = a * b;
assign quotient = a / b;
assign remainder = a % b;
always@(*)
    case(alu_control[3:0])
      4'b0000: result <= a & b;
      4'b0001: result <= a | b;
      4'b0010: result <= sum;
      4'b0011: result <= b << shamt;
      4'b1011: result <= b << a;
      4'b0100: result <= b >> shamt;
      4'b1100: result <= b >> a;
      4'b0101: result <= sra_sign | sra_aux;
      4'b0110: result <= sum;
      4'b0111: result <= slt;
      4'b1010: 
        begin
          result <= product[31:0]; 
          wd0 <= product[31:0];
          wd1 <= product[63:32];
        end
      4'b1110: 
        begin
          result <= quotient; 
          wd0 <= quotient;
          wd1 <= remainder;
        end
      4'b1000: result <= b << 5'd16;
    endcase

  assign zero = (result == 32'd0);
endmodule

//////aludec/////////
`timescale 1ns / 1ps
module aludec(
input [5:0] funct,
input [4:0] shamt,
input [3:0] aluop,
output reg [3:0] alucontrol,
output jumpreg
);

  always @(*)
    case(aluop)
      4'b0000: alucontrol <= 4'b0010;//addition
      4'b0001: alucontrol <= 4'b0110;//subtraction
      4'b0100: alucontrol <= 4'b0000;//and
      4'b0101: alucontrol <= 4'b0001;//or
      4'b0111: alucontrol <= 4'b0111;//slt
      default: case(funct)//RTYPE
          6'b100000: alucontrol <= 4'b0010;//ADD
          6'b100010: alucontrol <= 4'b0110;//SUB
          6'b100100: alucontrol <= 4'b0000;//AND
          6'b100101: alucontrol <= 4'b0001;//OR
          6'b101010: alucontrol <= 4'b0111;//SLT
          default:   alucontrol <= 4'bxxxx;//???
        endcase
    endcase
assign jumpreg = (funct == 6'b001000) ? 1 : 0;
endmodule

//////////controller///////////
`timescale 1ns / 1ps
module controller(
input [5:0] op, funct,
input [4:0] shamt,
input zero,
output memwrite,
output pcsrc, alusrc,
output regwrite, spregwrite,
output [1:0] regdst, 
output memtoreg,
output jump, jal, jumpreg,
output [3:0] alucontrol,
output spra, readhilo
);
wire [3:0] aluop;
wire branch;
maindec main_decoder(op, funct, memwrite, branch, alusrc, regwrite, spregwrite, regdst, memtoreg, jump, jal, aluop, spra, readhilo);
aludec alu_decoder(funct, shamt, aluop, alucontrol, jumpreg);
assign pcsrc = branch & zero;
endmodule

//////////////////datamemory//////////////////////
`timescale 1ns / 1ps
/*module data_memory(
input clk, we,
input [31:0] a, wd,
output [31:0] rd
 );
reg [7:0]ram_data_mem[1023:0]; //BYTE ADDRESSABLE 4-GiB DATA MEMORY
assign rd = ram_data_mem[a[31:2]];
always @(posedge clk)
if(we)
    ram_data_mem[a[31:2]] <= wd;
endmodule*/


module data_memory(
input clk, memwrite,
input [31:0] address,
input [31:0] write_data,
output reg [31:0] read_data
);
    reg [7:0] data_mem [1023:0];
    initial $readmemh("data_file.dat", data_mem);
    always@(*) read_data = {data_mem[address], data_mem[address+1], data_mem[address+2], data_mem[address+3]};
    always@(posedge clk)
    begin
    if(memwrite)
    begin
        data_mem[address+3] <= write_data[7:0];
        data_mem[address+2] <= write_data[15:8];
        data_mem[address+1] <= write_data[23:16];
        data_mem[address] <= write_data[31:24];
    end
    end
endmodule

////////////datapath//////////////////////
`timescale 1ns / 1ps
module datapath(
input clk, reset,
input memtoreg, 
input pcsrc,
input alusrc, 
input [1:0] regdst,
input regwrite, spregwrite, jump, jal, jumpreg,
input [4:0] shamt,
input [3:0] alucontrol,
output zero,
output [31:0] pc,
input [31:0] instr,
output [31:0] aluout, writedata,
input [31:0] readdata,
input spra, readhilo
);
wire [4:0]  writereg;
wire [31:0] pcnextjr, pcnext, pcnextbr, pcplus4, pcbranch;
wire [31:0] signimm, signimmsh;
wire [31:0] srca, srcb, wd0, wd1, sprd;
wire [31:0] result, resultjal, resulthilo;
flopr #(32) pcreg(clk, reset, pcnext, pc); //pc next
adder pcadd1(pc, 32'b100, pcplus4);
sl2  immsh(signimm, signimmsh);
adder pcadd2(pcplus4, signimmsh, pcbranch);
mux2 #(32)pcbrmux(pcplus4, pcbranch, pcsrc, pcnextbr);
mux2 #(32)pcmux(pcnextbr, {pcplus4[31:28], instr[25:0], 2'b00}, jump, pcnext);
mux2 #(32)pcmuxjr(pcnext, srca, jumpreg, pcnextjr);
regfile reg_file(clk, regwrite, instr[25:21], instr[20:16], writereg, resulthilo, srca, writedata); //register file
mux3 #(5) wrmux(instr[20:16], instr[15:11], 5'b11111, regdst, writereg);
mux2 #(32)resmux(aluout, readdata, memtoreg, result);
mux2 #(32)wrmuxjal(result, pcplus4, jal, resultjal);
mux2 #(32)wrmuxhilo(resultjal, sprd, readhilo, resulthilo);
signext se(instr[15:0], signimm);
mux2 #(32)srcbmux(writedata, signimm, alusrc, srcb); //ALU
alu alu(srca, srcb, shamt, alucontrol, aluout, wd0, wd1, zero);
spregfile sprf(clk, spregwrite, spra, wd0, wd1, sprd); //Special register file
endmodule


/////////flopr//////////
`timescale 1ns / 1ps
module flopr #(parameter WIDTH = 8)
              (
input clk, reset,
input [WIDTH-1:0] d, 
output reg [WIDTH-1:0] q
);
always @(posedge clk, posedge reset)
    if(reset)
        q <= 0;
    else
        q <= d;
endmodule

//////////// instruction_memory///////
`timescale 1ns / 1ps
module instruction_memory(
input [31:0] addr,
output [31:0] rd_data
);
reg [7:0]ram_memory[1023:0];  //BYTE ADDRESSABLE INSTRUCTION MEMORY
initial
begin
    $readmemh("ins_file.dat",ram_memory);
end
assign rd_data = {ram_memory[addr],ram_memory[addr+1],ram_memory[addr+2],ram_memory[addr+3]};
endmodule


/////////maindec///////////
`timescale 1ns / 1ps
module maindec(
input [5:0] op, funct,
output memwrite,
output branch, alusrc,
output regwrite, spregwrite,
output [1:0] regdst, 
output memtoreg,
output jump, jal,
output [3:0] aluop,
output reg spra,
output readhilo
);
reg [14:0] controls;
assign {regwrite, regdst, alusrc,branch, memwrite, memtoreg, jump, jal, aluop, spregwrite, readhilo} = controls;
always @(*)
   case(op)
      6'b000000: 
      	begin
      		case(funct)
      			6'b011000: controls <= 15'b101000000001010; //mult
      			6'b011010: controls <= 15'b101000000001010; //div
      			default:   
      			  begin
      			    case(funct)
      			      6'b010000: 
      			        begin
      			          spra <= 1'b1;
      			          controls <= 15'b101000000001001;
      			        end
      			      6'b010010: 
      			        begin
      			          spra <= 1'b0;
      			          controls <= 15'b101000000001001;
      			        end
      			      default: controls <= 15'b101000000001000; //other R-type
      			    endcase
      			  end
      		endcase
      	end
      6'b100011: controls <= 15'b100100100000000; //LW
      6'b101011: controls <= 15'b000101000000000; //SW
      6'b000100: controls <= 15'b000010000000100; //BEQ
      6'b001000: controls <= 15'b100100000000000; //ADDI
      6'b000010: controls <= 15'b000000010000000; //J
      6'b000011: controls <= 15'b111000011000000; //JAL
      6'b001100: controls <= 15'b100100000010000; //ANDI
      6'b001101: controls <= 15'b100100000010100; //ORI
      6'b001010: controls <= 15'b100100000011100; //SLTI
      6'b001111: controls <= 15'b100100000100000; //LUI
      default:   controls <= 15'bxxxxxxxxxxxxxx; //???
    endcase
endmodule

/////memfile.dat////////
20020005
2003000c
30660005
34690005
284a0003
286a000d
3c0b000f
00426004
200d0040
004d6806
01ac7018
00007810
00008012
018d701a
00007810
00008012
2067fff7
00e22025
00642824
00a42820
10a7000a
0064202a
10800001
20050000
00e2202a
00853820
00e23822
ac670044
8c020050
08000011
20020001
ac020054

////mux2//////////
`timescale 1ns / 1ps
module mux2 #(parameter WIDTH = 8)
             (input  [WIDTH-1:0] d0, d1, 
              input              s, 
              output [WIDTH-1:0] y);

  assign y = s ? d1 : d0; 
endmodule

////////mux3///////
`timescale 1ns / 1ps
module mux3 #(parameter WIDTH = 8)
             (input [WIDTH-1:0] d0, d1, d2,
              input [1:0] s, 
              output [WIDTH-1:0] y);

  assign y = (s == 2'b00) ? d0 : ((s == 2'b01) ? d1 : d2); 
endmodule


//////regfile///////
`timescale 1ns / 1ps
module regfile(
input clk, 
input we3, 
input [4:0] ra1, ra2, wa3, 
input [31:0] wd3, 
output [31:0] rd1, rd2
);
reg [31:0] rf[31:0];
always@(posedge clk)
    if (we3) rf[wa3] <= wd3;	
assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
endmodule


//////////signnect/////
`timescale 1ns / 1ps
module signext(input  [15:0] a,
               output [31:0] y);
       assign y = {{16{a[15]}}, a};
endmodule

///////single_cycle///////
`timescale 1ns / 1ps
module single_cycle(
input clk, reset,
output [31:0] pc,
input [31:0] instr,
output memwrite,
output [31:0] aluout, writedata,
input [31:0] readdata
);
wire branch, memtoreg, pcsrc, zero, spra, alusrc, regwrite, spregwrite, jump, jal, jumpreg, readhilo;
wire [1:0] regdst;
wire [3:0] alucontrol;
controller controller(instr[31:26], instr[5:0], instr[10:6], zero, memwrite, pcsrc, alusrc, regwrite, spregwrite, regdst, memtoreg, jump, jal, jumpreg,alucontrol, spra, readhilo);
datapath datapath(clk, reset, memtoreg, pcsrc, alusrc, regdst, regwrite, spregwrite, jump, jal, jumpreg, instr[10:6], alucontrol, zero, pc, instr, aluout, writedata, readdata, spra, readhilo);
endmodule

/////////sl2/////////
`timescale 1ns / 1ps
module sl2(input  [31:0] a,
           output [31:0] y);
  assign y = {a[29:0], 2'b00};
endmodule

//////spregfile/////////
`timescale 1ns / 1ps
module spregfile(
input clk, 
input we, 
input ra, 
input  [31:0] wd0, wd1, 
output [31:0] rd
);
reg [31:0] rf[1:0];
always @(posedge clk)
    if (we == 1'b1)
      begin
        rf[1'b0] <= wd0;
        rf[1'b1] <= wd1;
      end
   assign rd = (ra != 1'b0) ? rf[1'b1] : rf[1'b0];
endmodule

/////////testbecnch//////////



///////////upper_module///////////
`timescale 1ns / 1ps
module upper_module(
input clk, reset, 
output [31:0] writedata, dataadr, 
output memwrite
);
wire [31:0] pc, instr, readdata;
single_cycle single_cycle(clk, reset, pc, instr, memwrite, dataadr, writedata, readdata);
instruction_memory instruction_memory(pc, instr);
data_memory data_memory(clk, memwrite, dataadr, writedata, readdata);
endmodule
