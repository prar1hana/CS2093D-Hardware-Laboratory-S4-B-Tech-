// 1. Design and implement a register in Verilog for a custom processor's architecture with the following specifications:
// a.   	It should be a 16-bit register.
// b.  	It should have one read port (read_port_1) and one write port (write_port_1).
// c.   	Only one operation, either read or write, can be performed at a time on the register.
// d.  	Each read port should be able to access data from the register without any conflicts with write operations.
// Please note that you should define the module with appropriate input and output ports and ensure that it meets all the specified requirements above.

module register(input [15:0]write_data,input read_write,clk,rst,output reg[15:0]read_data);
  reg [15:0]reg_data = 16'bx;
  reg [15:0]old_data = 16'bx;
  always@(posedge clk)
    begin
      if( rst )
        read_data <= 16'bx;
      else
        begin
          if( read_write == 1 )
            begin
              read_data = reg_data; 
              reg_data <= write_data;
              
            end
          else 
            begin
              read_data <= reg_data;  
            end
        end
    end  
endmodule

module testbench;
  reg [15:0]write_data;
  reg clk=1;
  reg rst=0;
  reg read_write;
  wire [15:0]read_data;
  register test(.write_data(write_data),.clk(clk),.rst(rst),.read_write(read_write),.read_data(read_data));
  integer i;
  always begin
    clk = ~clk;
    #5;
  end
  initial begin
    for(i=0;i<=50;i=i+1)
      begin
        write_data = $random;
        read_write = $random;
        #5;
      end
    
    $finish;
  end
endmodule
