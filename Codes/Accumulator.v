module Accumulator (clk,MR,flags,State_Machine_Out,in,Stack_PC,Stack_Flags,flag_selector,MemWSP,outPC); 
input clk, MR; 
input [1:0] State_Machine_Out;
input  [15:0] in;
input Stack_PC,Stack_Flags;
output reg flag_selector,MemWSP; 
output [31:0] outPC; 
output reg [2:0]flags;
reg [31:0] tmp; 
 
 initial begin
    flag_selector = 1'b0;
    MemWSP = 1'b0;
    flags = 3'd0;
 end


  always @(posedge clk) 
    begin 
      if(State_Machine_Out==2'b11 )
      begin
        flag_selector= 1'b0;
        tmp[15:0] = in; 
        if(MR==1'b1)
        begin 
          MemWSP= 1'b0;
        end
      end
      else if(State_Machine_Out==2'b10)
      begin
        if({Stack_PC,Stack_Flags}==2'b11)
        begin
          if(MR==1'b1)
          begin 
            MemWSP= 1'b1;
          end
          else
          begin
            MemWSP= 1'b0;
          end
          tmp[31:16] = in;
          flag_selector= 1'b0;
        end
        else begin
          MemWSP= 1'b0;
          tmp[15:0] = in;
          flag_selector= 1'b0;
        end 
      end
      else if(State_Machine_Out==2'b01 )
      begin
        if({Stack_PC,Stack_Flags}==2'b11)
        begin
        tmp = tmp;
        flags=in[2:0];
        if(MR==1'b1)
        begin 
          flag_selector= 1'b1;
          MemWSP= 1'b0;
        end
        else
        begin
          flag_selector= 1'b0;
          MemWSP= 1'b0;
        end
        end
        else begin
          tmp[31:16] = in;
          flag_selector= 1'b0;
          if(MR==1'b1)
          begin
            MemWSP= 1'b1;
          end
          else
          begin
            MemWSP= 1'b0;
          end
        end
      end
      else 
      begin
        tmp = tmp; 
        flag_selector= 1'b0;
        MemWSP= 1'b0;
      end
    end 
  assign outPC = tmp; 
endmodule