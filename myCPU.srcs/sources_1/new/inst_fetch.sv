`timescale 1ns / 1ps
// `include "rom.sv"
// `include "pc_reg.sv"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/24 23:13:56
// Design Name: 
// Module Name: inst_fetch
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

module inst_fetch (
    input logic clk,
    input logic rst,
    output logic [31:0] inst_o
);

  logic ce;
  logic [5:0] pc;

  pc_reg pc0 (
      .clk(clk),
      .rst(rst),
      .pc (pc),
      .ce(ce)
  );

  rom rom0 (
      .addr(pc),
      .ce  (ce),
      .inst(inst_o)
  );

endmodule
