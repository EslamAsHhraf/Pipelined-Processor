// WB|MW|MR|Data|Address
module EX_MEM(
    DataIn, Buffer, clk
);
    input [69:0] DataIn;
    input clk;
    output reg [69:0] Buffer;
    always @(posedge clk) begin
        Buffer = DataIn;
    end
endmodule