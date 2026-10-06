`timescale 1ns/1ps

module top(
input CLK100MHZ,
input CPU_RESETN,

output LED
);

logic [24:0] count = 0;
assign LED = count[24];
logic clk;
logic clk_locked;

clk_wiz_0 u_clk_wiz(.clk_in1(CLK100MHZ), .clk_out1(clk), .reset(!CPU_RESETN), .locked (clk_locked));

always @(posedge(clk)) begin
  count <= count + 1;
end

endmodule
