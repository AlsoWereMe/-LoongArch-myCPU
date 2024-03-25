`timescale 1ns / 1ps
// `include "../../sources_1/new/inst_fetch.sv"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/24 23:33:35
// Design Name: 
// Module Name: inst_fetch_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module inst_fetch_tb ();
  logic CLOCK;
  logic rst;
  logic [31:0] inst_o;

  initial begin
    CLOCK = 1'b0;
    forever begin
      #10 CLOCK = ~CLOCK;  /* 50MHz */
    end
  end

  initial begin
    rst = 1'b1;
    #195 rst = ~rst;
    #1000 $stop(2);
  end

  inst_fetch inst_fetch0 (
      .clk(CLOCK),
      .rst(rst),
      .inst_o(inst_o)
  );
endmodule
